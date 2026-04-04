# Lab 1: First Terraform Apply

## Goal

Create a simple local-file resource so you can learn the Terraform workflow without needing cloud credentials.

## Commands

```bash
terraform -chdir=starter-code/terraform init
terraform -chdir=starter-code/terraform plan
terraform -chdir=starter-code/terraform apply -auto-approve
```

## Verify

```bash
cat starter-code/terraform/workshop.txt
```

## Clean up

```bash
terraform -chdir=starter-code/terraform destroy -auto-approve
```
