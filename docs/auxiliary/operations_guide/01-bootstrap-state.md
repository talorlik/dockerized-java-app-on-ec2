# 01 - Bootstrap remote Terraform state

`infra/bootstrap` provisions the encrypted, versioned, TLS-only S3 bucket
plus a KMS CMK that the rest of the project's state lives in.

## Steps

```bash
cd infra/bootstrap

# Use admin-level credentials in DEPLOYMENT account for this run only.
export AWS_REGION=us-east-1

terraform init

terraform apply \
  -var aws_region=us-east-1 \
  -var state_bucket_name="java-app-tfstate-<DEPLOYMENT_ACCOUNT_ID>-us-east-1"
```

After apply:

```bash
terraform output backend_block_example
```

Copy the printed block into `infra/envs/prod/backend.tf`, replacing the two
`REPLACE_WITH_BOOTSTRAP_OUTPUT_*` placeholders. Commit the change.

## Notes

- Locking uses S3 native lockfile (`use_lockfile = true`). DynamoDB is not
  required.
- Bucket has versioning, public-access-block, SSE-KMS, TLS-only policy, and
  90-day noncurrent-version lifecycle.
- The bootstrap module itself uses **local state** because it runs before the
  remote state exists. Keep its `.terraform/` directory off your filesystem
  after the bootstrap run, or commit nothing from it (it's already in
  `.gitignore`).
