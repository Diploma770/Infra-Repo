#!/usr/bin/env bash
set -euo pipefail

TFVARS_FILE="${1:-dev.tfvars}"
ADDONS_TFVARS_FILE="${2:-dev-addons.tfvars}"

echo "[1/3] terraform init"
terraform init

echo "[2/3] apply core infrastructure (dev)"
terraform apply -var-file "$TFVARS_FILE" -auto-approve

echo "[3/3] apply k8s addons (dev-addons)"
pushd ../dev-addons >/dev/null
terraform init
terraform apply -var-file "$ADDONS_TFVARS_FILE" -auto-approve
popd >/dev/null

echo "Done: infrastructure + ArgoCD + ESO applied."
