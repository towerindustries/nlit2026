# Lab 2: Variables and Outputs

## Goal

Modify a Terraform variable and observe how outputs change.

## Edit

Open `starter-code/terraform/terraform.tfvars.example` and adjust the values.

## Run

```bash
cp starter-code/terraform/terraform.tfvars.example starter-code/terraform/terraform.tfvars
terraform -chdir=starter-code/terraform plan
terraform -chdir=starter-code/terraform apply -auto-approve
terraform -chdir=starter-code/terraform output
```
