#!/usr/bin/env bash
set -euo pipefail

printf '\n==> Prebuilding workshop dependencies\n'
terraform version
aws --version
gh --version

mkdir -p ~/.workshop/bin ~/.aws
chmod 700 ~/.aws

# Install terraform-docs for nicer demos.
if ! command -v terraform-docs >/dev/null 2>&1; then
  curl -sSLo /tmp/terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.20.0/terraform-docs-v0.20.0-linux-amd64.tar.gz
  tar -xzf /tmp/terraform-docs.tar.gz -C /tmp
  install /tmp/terraform-docs ~/.workshop/bin/terraform-docs
fi

grep -qxF 'export PATH="$HOME/.workshop/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.workshop/bin:$PATH"' >> ~/.bashrc

echo "Prebuild setup complete."
