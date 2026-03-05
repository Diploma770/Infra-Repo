# Terraform CI/CD Setup (Best Practice for this repo)

This repo now includes:
- PR plans: [.github/workflows/terraform-plan.yml](.github/workflows/terraform-plan.yml)
- Merge apply: [.github/workflows/terraform-apply.yml](.github/workflows/terraform-apply.yml)

Current automated stacks:
- `dev` (core infra)
- `dev-addons` (k8s addons)

Execution order is enforced:
1) `dev`
2) `dev-addons`

## 1) Organization secrets (OIDC + TF_VAR sensitive inputs)

Create these **organization secrets**:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
  - Example: `projects/123456789/locations/global/workloadIdentityPools/github/providers/github`
- `GCP_TERRAFORM_SERVICE_ACCOUNT`
  - Example: `terraform-ci@my-dev-770.iam.gserviceaccount.com`
- `BILLING_ACCOUNT_ID`
- `TERRAFORM_GITHUB_PRINCIPAL`
- `CICD_GITHUB_PRINCIPAL`
- `DB_PASSWORD`
- `SMTP_APP_PASSWORD`
- `ARGOCD_REPO_PASSWORD`
- `ARGOCD_REPO_SSH_PRIVATE_KEY` (optional if using HTTPS auth)

## 2) Organization/repository variables

Create these variables:

- `TF_STATE_BUCKET`
  - Shared GCS bucket for Terraform remote state
- `GCP_PROJECT_ID`
  - Project used for CI auth/cluster lookup
- `GKE_DEV_CLUSTER_NAME`
  - Example: `dev-gke`
- `GKE_DEV_CLUSTER_LOCATION`
  - Example: `europe-west3-a`

## 3) GCS remote backend migration

Backends are now `gcs` in:
- [dev/backend.tf](dev/backend.tf)
- [dev-addons/backend.tf](dev-addons/backend.tf)
- [prod/backend.tf](prod/backend.tf)

CI initializes backend using:
- `bucket=${TF_STATE_BUCKET}`
- `prefix=terraform/<stack>`

If migrating existing local state manually, run once per stack:

```bash
cd dev
terraform init -migrate-state -reconfigure -backend-config="bucket=<BUCKET>" -backend-config="prefix=terraform/dev"

cd ../dev-addons
terraform init -migrate-state -reconfigure -backend-config="bucket=<BUCKET>" -backend-config="prefix=terraform/dev-addons"
```

## 4) OIDC IAM best practice

Grant your CI service account only required roles (least privilege), typically:
- Terraform infra roles (compute/container/iam/serviceusage/storage as needed)
- Workload Identity role bindings from GitHub OIDC principal to service account

## 5) Stage/Prod with manual approval

Recommended when you add `stage`, `stage-addons`, `prod`, `prod-addons` roots:
- Add GitHub Environments: `stage`, `prod`
- Configure required reviewers in environment protection rules
- Add jobs in workflow in sequence:
  - `stage` -> `stage-addons` (environment: `stage`)
  - `prod` -> `prod-addons` (environment: `prod`)
- Keep PR = `plan`, merge/manual promotion = `apply`

## 6) Security notes

- Never commit `*.tfvars`, `*.tfstate`, `.terraform/`
- Rotate any exposed PATs or keys immediately
- Prefer immutable image digests in app repo promotion flow
