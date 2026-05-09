"""
db_bootstrap Lambda - idempotently provisions the application MySQL user.

Triggered by terraform_data.db_bootstrap on RDS replacement or app-user
secret rotation (see infra/envs/prod/db_bootstrap.tf). Re-invocation is
safe: CREATE USER IF NOT EXISTS is a no-op when the row already exists,
and ALTER USER deterministically syncs the password to whatever the
current /java-app/<env>/db/app-user secret holds.

Required env vars (Terraform sets all of these):
  DB_HOST              - RDS writer endpoint (private DNS).
  DB_PORT              - 3306.
  DB_NAME              - logical schema name to grant on.
  APP_USER             - MySQL username to provision.
  MASTER_SECRET_ARN    - Secrets Manager ARN of the RDS-managed master
                         credential (rotated by RDS).
  APPUSER_SECRET_ARN   - Secrets Manager ARN of the app-user credential
                         (rotated manually per ops guide section 5).

Connection security:
  PyMySQL's `ssl={"ssl": {}}` enables TLS without CA verification.
  Intra-VPC traffic to RDS is the only path that can reach the
  endpoint (see aws_security_group.rds: ingress is referenced-SG only),
  so the absence of CA pinning here does not widen the attack surface
  beyond what the SG already enforces. Tighten to `ca=` pointing at the
  RDS CA bundle if compliance demands explicit cert validation.
"""

import json
import logging
import os

import boto3
import pymysql

LOG = logging.getLogger()
LOG.setLevel(logging.INFO)

_sm = boto3.client("secretsmanager")


def _secret(arn: str) -> dict:
    """Fetch a Secrets Manager secret and decode its JSON SecretString."""
    return json.loads(_sm.get_secret_value(SecretId=arn)["SecretString"])


def handler(event, _context):
    db_host = os.environ["DB_HOST"]
    db_port = int(os.environ["DB_PORT"])
    db_name = os.environ["DB_NAME"]
    app_user = os.environ["APP_USER"]

    master = _secret(os.environ["MASTER_SECRET_ARN"])
    appsec = _secret(os.environ["APPUSER_SECRET_ARN"])

    # The app secret is canonical for the app username too; if it ever
    # drifts from the APP_USER env var, prefer the secret so a manual
    # rotation that also renames the user (rare but possible) does not
    # require a Terraform change to converge.
    secret_user = appsec.get("username", app_user)
    if secret_user != app_user:
        LOG.warning(
            "app_user mismatch: env=%s secret=%s; using secret value",
            app_user, secret_user,
        )
    app_user = secret_user
    app_pw = appsec["password"]

    LOG.info(
        "connecting host=%s port=%s db=%s as master=%s",
        db_host, db_port, db_name, master["username"],
    )

    conn = pymysql.connect(
        host=db_host,
        port=db_port,
        user=master["username"],
        password=master["password"],
        ssl={"ssl": {}},
        connect_timeout=10,
        read_timeout=15,
        write_timeout=15,
        autocommit=True,
    )

    # CREATE USER and GRANT in MySQL grammar do not accept parameter
    # binding for identifiers (user, host, schema). Identifiers are
    # constrained: user/host come from controlled sources (env + the
    # backing secret), schema comes from a controlled Terraform variable.
    # The password IS bound via parameter substitution so it never
    # appears in the rendered SQL or any log.
    user_lit = f"'{_escape_ident(app_user)}'@'%'"
    schema_lit = f"`{_escape_ident(db_name)}`"

    # PyMySQL.cursor.execute() does Python `%`-formatting on the query when
    # bind args are passed (cursors.py mogrify -> `query % args`). Any
    # literal `%` in the SQL must therefore be doubled to `%%` for the
    # parameterised path. user_lit contains the host wildcard `'%'`, so
    # it would otherwise be parsed as a format spec and crash with
    # "unsupported format character"). Queries WITHOUT bind args (GRANT
    # below) skip mogrify entirely and use user_lit unchanged.
    user_lit_param = user_lit.replace("%", "%%")

    try:
        with conn.cursor() as cur:
            LOG.info("CREATE USER IF NOT EXISTS %s", user_lit)
            cur.execute(
                f"CREATE USER IF NOT EXISTS {user_lit_param} "
                f"IDENTIFIED WITH caching_sha2_password BY %s",
                (app_pw,),
            )

            LOG.info(
                "ALTER USER %s (sync password + plugin to caching_sha2_password)",
                user_lit,
            )
            cur.execute(
                f"ALTER USER {user_lit_param} "
                f"IDENTIFIED WITH caching_sha2_password BY %s",
                (app_pw,),
            )

            LOG.info("GRANT ALL PRIVILEGES ON %s.* TO %s", schema_lit, user_lit)
            cur.execute(
                f"GRANT ALL PRIVILEGES ON {schema_lit}.* TO {user_lit}"
            )

            cur.execute("FLUSH PRIVILEGES")

            cur.execute(
                "SELECT plugin FROM mysql.user WHERE user=%s AND host='%%'",
                (app_user,),
            )
            row = cur.fetchone()
            plugin = row[0] if row else None
    finally:
        conn.close()

    LOG.info("done; user=%s plugin=%s", app_user, plugin)
    return {
        "status": "ok",
        "user": app_user,
        "host": "%",
        "schema": db_name,
        "plugin": plugin,
    }


def _escape_ident(value: str) -> str:
    """
    Escape an identifier for safe inclusion in MySQL DDL.

    Backticks inside an identifier must be doubled; same for single
    quotes when the identifier is wrapped in single quotes (user names).
    Returning the inner content only - the caller wraps in the
    appropriate quote style.
    """
    if value is None:
        raise ValueError("identifier must not be None")
    return value.replace("`", "``").replace("'", "''")
