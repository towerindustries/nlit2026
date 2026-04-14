# Intro to AWS and Terraform
## A Two-Hour Hands-On Workshop

This course teaches you how to deploy a real web server on AWS from scratch using Terraform.
By the end of class you will have a running EC2 instance serving a webpage over both HTTP and HTTPS.

---

## What You Will Build

```
                          Internet
                              |
                    [ Internet Gateway ]
                              |
                    [ Public Subnet ]  10.0.1.0/24
                              |
                 [ Security Group ] SSH/HTTP/HTTPS
                              |
                    [ EC2 t3.micro ]
                      Amazon Linux 2023
                      30 GB gp3 disk
                      nginx + HTTPS
```

---

## Course Outline  (~2 hours)

| # | Topic | Time |
|---|-------|------|
| 00 | Welcome and Environment Setup | 15 min |
| 01 | AWS GUI Walkthrough | 15 min |
| 02 | Terraform Provider Setup | 10 min |
| 03 | Networking (VPC, Subnet, Routes) | 20 min |
| 04 | Security Groups | 10 min |
| 05 | AMI Data Lookup | 10 min |
| 06 | EC2 Compute Instance | 10 min |
| 07 | User Data and Nginx HTTPS | 10 min |
| 08 | Outputs | 5 min |
| 09 | Deploy and Verify | 15 min |

---

## Workbooks (follow in order)

1. [00 - Welcome](workbook/00-welcome.md)
2. [01 - Environment Setup](workbook/01-environment-setup.md)
3. [02 - AWS GUI Walkthrough](workbook/02-aws-gui-walkthrough.md)
4. [03 - Provider Setup](workbook/03-provider-setup.md)
5. [04 - Networking](workbook/04-network.md)
6. [05 - Security Groups](workbook/05-security.md)
7. [06 - AMI Data Lookup](workbook/06-ami-data-lookup.md)
8. [07 - Compute (EC2)](workbook/07-compute.md)
9. [08 - User Data and Nginx HTTPS](workbook/08-user-data-nginx.md)
10. [09 - Outputs](workbook/09-outputs.md)
11. [10 - Deploy and Verify](workbook/10-deploy-and-verify.md)

---

## Completed Code

The finished Terraform code for the entire lab lives in [code/](code/).

| File | Purpose |
|------|---------|
| [provider.tf](code/provider.tf) | Terraform and AWS provider configuration |
| [variables.tf](code/variables.tf) | Input variables (your IP, key name) |
| [network.tf](code/network.tf) | VPC, Internet Gateway, Subnet, Route Table |
| [security.tf](code/security.tf) | Security Group firewall rules |
| [data.tf](code/data.tf) | Dynamic AMI lookup for Amazon Linux 2023 |
| [compute.tf](code/compute.tf) | EC2 instance definition |
| [outputs.tf](code/outputs.tf) | Values printed after apply |
| [terraform.tfvars.example](code/terraform.tfvars.example) | Template for your personal variable values |
| [scripts/nginx_https_install.sh](code/scripts/nginx_https_install.sh) | Boot script that installs and configures nginx |

---

## Free Tier Notice

All resources created in this lab are AWS Free Tier eligible:
- **EC2**: t3.micro (750 hours/month free)
- **Storage**: 30 GB gp3 EBS (30 GB/month free)
- **Networking**: VPC, subnets, internet gateway (free)

**Always run `terraform destroy` at the end of class to avoid charges.**
