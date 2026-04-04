# Lab 0: Welcome

## Goal

Confirm that your Codespace is working and that Terraform is ready.

## Checks

Run these commands in the terminal:

```bash
terraform version
aws --version
gh --version
```

## Validate the starter config

```bash
terraform -chdir=starter-code/terraform init
terraform -chdir=starter-code/terraform plan
```

You should see Terraform initialize successfully and produce an execution plan.
