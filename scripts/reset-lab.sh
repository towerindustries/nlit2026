#!/usr/bin/env bash
set -euo pipefail

rm -rf starter-code/terraform/.terraform \
       starter-code/terraform/.terraform.lock.hcl \
       starter-code/terraform/terraform.tfstate \
       starter-code/terraform/terraform.tfstate.backup \
       starter-code/terraform/workshop.txt \
       starter-code/terraform/terraform.tfvars

echo "Lab reset complete."
