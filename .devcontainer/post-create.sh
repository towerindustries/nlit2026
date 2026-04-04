#!/usr/bin/env bash
set -euo pipefail

printf '\n==> Finalizing attendee workspace\n'
mkdir -p .workshop-state

echo "WORKSHOP_READY=true" > .workshop-state/env

cat > ~/.aws/config <<CFG
[default]
region = ${AWS_DEFAULT_REGION:-us-east-1}
output = json
CFG

cat > .workshop-state/next-steps.txt <<TXT
1. Open labs/00-welcome.md
2. Run: terraform -chdir=starter-code/terraform init
3. Run: terraform -chdir=starter-code/terraform plan
TXT

echo "Workspace ready."
