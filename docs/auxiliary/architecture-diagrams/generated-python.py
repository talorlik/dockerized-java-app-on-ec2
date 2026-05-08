#!/usr/bin/env python3
"""
Generate a unified AWS architecture diagram for this repository.

Outputs:
- docs/auxiliary/architecture-diagrams/diagrams/java_app_architecture.png
- docs/auxiliary/architecture-diagrams/diagrams/java_app_architecture.dot
- docs/auxiliary/architecture-diagrams/diagrams/java_app_architecture.drawio
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import AutoScaling, EC2, ECR
from diagrams.aws.database import RDS
from diagrams.aws.management import Cloudwatch, CloudwatchLogs
from diagrams.aws.management import SystemsManagerParameterStore
from diagrams.aws.network import (
    InternetGateway,
    NATGateway,
    PrivateSubnet,
    PublicSubnet,
    Route53,
    Route53HostedZone,
    VPC,
    ElbApplicationLoadBalancer,
)
from diagrams.aws.security import CertificateManager, IAMRole, SecretsManager, WAF
from diagrams.aws.storage import S3
from diagrams.generic.compute import Rack
from diagrams.generic.database import SQL
from diagrams.generic.network import Firewall
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.client import Users

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent.parent.parent
OUTPUT_DIR = SCRIPT_DIR / "diagrams"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

TIER_COLORS = {
    "EDGE_DNS": "#E3F2FD",
    "INGRESS": "#E8EAF6",
    "NETWORK": "#E0F7FA",
    "COMPUTE": "#E8F5E9",
    "DELIVERY_RELEASE": "#F3E5F5",
    "DATA": "#FFF3E0",
    "STORAGE": "#FFF8E1",
    "SECURITY_CONFIG": "#FFEBEE",
    "OBSERVABILITY": "#ECEFF1",
}


def cluster_attrs(bg: str) -> dict:
    return {"style": "filled", "color": bg}


def _load_plan(path: Path) -> dict:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return {}


def _extract_type_set(plan: dict) -> set[str]:
    resource_types: set[str] = set()
    for change in plan.get("resource_changes", []):
        rtype = change.get("type")
        if rtype:
            resource_types.add(rtype)
    return resource_types


def _collect_plan_context() -> dict:
    bootstrap_plan = _load_plan(REPO_ROOT / "infra/bootstrap/tfplan.bootstrap.json")
    prod_plan = _load_plan(REPO_ROOT / "infra/envs/prod/tfplan.prod.json")
    bootstrap_types = _extract_type_set(bootstrap_plan)
    prod_types = _extract_type_set(prod_plan)
    return {
        "bootstrap_present": bool(bootstrap_plan),
        "prod_present": bool(prod_plan),
        "bootstrap_types": bootstrap_types,
        "prod_types": prod_types,
    }


def _convert_dot_to_drawio(dot_path: Path, drawio_path: Path) -> None:
    try:
        subprocess.run(
            ["graphviz2drawio", str(dot_path), "-o", str(drawio_path)],
            check=True,
            capture_output=True,
            text=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        pass


def build_diagram() -> str:
    context = _collect_plan_context()
    filename = "java_app_architecture"
    previous_cwd = Path.cwd()
    os.chdir(OUTPUT_DIR)
    try:
        with Diagram(
            "Dockerized Java App on AWS EC2 (Unified Architecture)",
            filename=filename,
            outformat=["png", "dot"],
            show=False,
            direction="TB",
            graph_attr={"splines": "ortho", "nodesep": "0.7", "ranksep": "0.9"},
        ):
            users = Users("End Users")
            github = GithubActions("GitHub Actions\n(ci/infra/app-deploy)")

            with Cluster("DOMAIN ACCOUNT", graph_attr=cluster_attrs(TIER_COLORS["EDGE_DNS"])):
                registered_domain = Firewall("Registered Domain\n(talorlik.com)")
                hosted_zone = Route53HostedZone("Route 53 Hosted Zone")
                domain_dns_role = IAMRole("Route 53 DNS Role\n(cross-account)")

            with Cluster(
                "DEPLOYMENT ACCOUNT",
                graph_attr=cluster_attrs(TIER_COLORS["NETWORK"]),
            ):
                with Cluster(
                    "EDGE AND DNS",
                    graph_attr=cluster_attrs(TIER_COLORS["EDGE_DNS"]),
                ):
                    route53_alias = Route53("java.talorlik.com")
                    acm = CertificateManager("ACM Certificate")
                    waf = WAF("WAFv2 Web ACL")
                    alb = ElbApplicationLoadBalancer("ALB\nHTTPS 443 -> HTTP 8080")

                with Cluster(
                    "SECURITY AND CONFIG",
                    graph_attr=cluster_attrs(TIER_COLORS["SECURITY_CONFIG"]),
                ):
                    oidc_role = IAMRole("github-role\n(OIDC trusted)")
                    ec2_profile = IAMRole("EC2 Instance Profile")
                    secrets = SecretsManager("Secrets Manager")
                    ssm_params = SystemsManagerParameterStore("Parameter Store")

                with Cluster("DELIVERY", graph_attr=cluster_attrs(TIER_COLORS["DELIVERY_RELEASE"])):
                    ecr = ECR("ECR backend/frontend")

                with Cluster("NETWORK", graph_attr=cluster_attrs(TIER_COLORS["NETWORK"])):
                    vpc = VPC("VPC")
                    igw = InternetGateway("Internet Gateway")
                    nat = NATGateway("NAT Gateway")
                    with Cluster("Public Subnets", graph_attr=cluster_attrs(TIER_COLORS["INGRESS"])):
                        pub_a = PublicSubnet("Public Subnet A")
                        pub_b = PublicSubnet("Public Subnet B")
                    with Cluster("Private App Subnets", graph_attr=cluster_attrs(TIER_COLORS["COMPUTE"])):
                        app_a = PrivateSubnet("Private App A")
                        app_b = PrivateSubnet("Private App B")
                        asg = AutoScaling("EC2 Auto Scaling Group")
                        ec2 = EC2("EC2 Instances")
                        containers = Rack("Docker Compose\nNginx + Spring Boot")
                    with Cluster("DB Subnets", graph_attr=cluster_attrs(TIER_COLORS["DATA"])):
                        db_a = PrivateSubnet("Private DB A")
                        db_b = PrivateSubnet("Private DB B")
                        rds = RDS("RDS MySQL")

                with Cluster(
                    "OBSERVABILITY AND STORAGE",
                    graph_attr=cluster_attrs(TIER_COLORS["OBSERVABILITY"]),
                ):
                    cloudwatch = Cloudwatch("CloudWatch")
                    cloudwatch_logs = CloudwatchLogs("CloudWatch Logs")
                    alb_logs = S3("S3 ALB Access Logs")

                with Cluster("MESSAGING", graph_attr=cluster_attrs(TIER_COLORS["DATA"])):
                    ses = SQL("Amazon SES")

            users >> Edge(label="DNS lookup") >> route53_alias
            route53_alias >> Edge(label="A/ALIAS") >> hosted_zone
            route53_alias >> Edge(label="HTTPS 443") >> waf >> alb
            acm >> Edge(label="TLS cert") >> alb
            alb >> Edge(label="HTTP 8080") >> asg >> ec2 >> containers
            containers >> Edge(label="/api -> backend") >> containers
            containers >> Edge(label="MySQL 3306") >> rds
            containers >> Edge(label="read secrets") >> secrets
            containers >> Edge(label="read release/config") >> ssm_params
            containers >> Edge(label="send emails") >> ses
            ec2 >> Edge(label="image pull") >> ecr
            ec2_profile >> ec2

            github >> Edge(label="OIDC") >> oidc_role
            oidc_role >> Edge(label="AssumeRole") >> domain_dns_role
            github >> Edge(label="build/push") >> ecr
            github >> Edge(label="update release pointers") >> ssm_params
            github >> Edge(label="instance refresh") >> asg
            domain_dns_role >> hosted_zone

            registered_domain >> hosted_zone
            igw >> pub_a
            igw >> pub_b
            nat >> app_a
            nat >> app_b
            vpc >> pub_a
            vpc >> pub_b
            vpc >> app_a
            vpc >> app_b
            vpc >> db_a
            vpc >> db_b
            alb >> Edge(label="access logs") >> alb_logs
            ec2 >> cloudwatch_logs >> cloudwatch
            rds >> cloudwatch
            alb >> cloudwatch

            if context["bootstrap_present"]:
                tf_bootstrap = Rack("Terraform Root\ninfra/bootstrap")
                tf_bootstrap >> Edge(label="state foundation") >> alb_logs
            if context["prod_present"]:
                tf_prod = Rack("Terraform Root\ninfra/envs/prod")
                github >> Edge(label="terraform plan/apply") >> tf_prod
                tf_prod >> vpc
                tf_prod >> ssm_params
                tf_prod >> secrets
    finally:
        os.chdir(previous_cwd)

    dot_path = OUTPUT_DIR / f"{filename}.dot"
    drawio_path = OUTPUT_DIR / f"{filename}.drawio"
    _convert_dot_to_drawio(dot_path, drawio_path)
    return filename


def main() -> int:
    generated = build_diagram()
    print(f"Generated diagram artifacts under: {OUTPUT_DIR / generated}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
