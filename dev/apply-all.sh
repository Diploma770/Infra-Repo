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

MAX_RETRIES=10
SLEEP_SECONDS=30
ATTEMPT=1

until terraform apply -var-file "$ADDONS_TFVARS_FILE" -auto-approve; do
	if [[ "$ATTEMPT" -ge "$MAX_RETRIES" ]]; then
		echo "k8s addons apply failed after $MAX_RETRIES attempts."
		popd >/dev/null
		exit 1
	fi

	echo "k8s addons not ready yet (attempt $ATTEMPT/$MAX_RETRIES). Retrying in ${SLEEP_SECONDS}s..."
	ATTEMPT=$((ATTEMPT + 1))
	sleep "$SLEEP_SECONDS"
done
popd >/dev/null

echo "Done: infrastructure + ArgoCD + ESO applied."
