# Outputs

**Outputs** are values that Terraform prints to the terminal after a successful `terraform apply`.
They are also accessible via `terraform output` any time after deployment.

---

## Why Use Outputs?

After deploying infrastructure you often need to know things like:
- What IP address was assigned to my server?
- What is my VPC ID?
- What SSH command do I use to log in?

Without outputs you would have to dig through the AWS Console or run AWS CLI commands.
Outputs surface the most useful values directly in your terminal.

---

## Create the File

```
touch outputs.tf
```

---

## The Outputs Block

```
######################################################
## Outputs -- Values printed after terraform apply ##
######################################################

output "instance_public_ip" {
  description = "Public IP address to access your server from the internet"
  value       = aws_instance.web_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the server inside the VPC"
  value       = aws_instance.web_server.private_ip
}

output "instance_id" {
  description = "The unique EC2 instance ID assigned by AWS"
  value       = aws_instance.web_server.id
}

output "instance_name" {
  description = "The Name tag on the EC2 instance"
  value       = var.instance_name
}

output "vpc_id" {
  description = "The ID of the VPC that contains all your resources"
  value       = aws_vpc.main.id
}

output "ami_used" {
  description = "The Amazon Linux 2023 AMI ID that was selected by the data source"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "ssh_command" {
  description = "Copy and paste this command to SSH into your server"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.web_server.public_ip}"
}

output "http_url" {
  description = "URL to visit your nginx web page over HTTP"
  value       = "http://${aws_instance.web_server.public_ip}"
}

output "https_url" {
  description = "URL to visit your nginx web page over HTTPS"
  value       = "https://${aws_instance.web_server.public_ip}"
}
```

---

## Breaking It Down

### Output Block Structure
Each output follows this pattern:
```
output "output_name" {
  description = "Human-readable explanation of this value"
  value       = expression_that_produces_the_value
}
```

### How Values Are Referenced

| Reference | What It Returns |
|-----------|----------------|
| `aws_instance.web_server.public_ip` | The public IP AWS assigned |
| `aws_instance.web_server.private_ip` | The VPC-internal IP |
| `aws_instance.web_server.id` | The instance ID (`i-0abc1234...`) |
| `aws_vpc.main.id` | The VPC ID (`vpc-0abc1234...`) |
| `data.aws_ami.amazon_linux_2023.id` | The AMI ID that was used |
| `var.instance_name` | The variable value from your tfvars |

### String Interpolation
The `ssh_command`, `http_url`, and `https_url` outputs use **string interpolation**:
```
"ssh -i ${var.key_name}.pem ec2-user@${aws_instance.web_server.public_ip}"
```
`${ }` embeds a Terraform expression inside a string.
At apply time this becomes something like:
```
ssh -i dev-example-key.pem ec2-user@54.201.32.88
```

---

## What You Will See After Apply

After `terraform apply` succeeds, Terraform prints all outputs:

```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

ami_used           = "ami-0abc1234def56789a"
http_url           = "http://54.201.32.88"
https_url          = "https://54.201.32.88"
instance_id        = "i-0abc1234ef5678901"
instance_name      = "terraform-nginx-server"
instance_private_ip = "10.0.1.42"
instance_public_ip  = "54.201.32.88"
ssh_command        = "ssh -i dev-example-key.pem ec2-user@54.201.32.88"
vpc_id             = "vpc-0abc1234ef5678901"
```

---

## Accessing Outputs Later

You can query outputs any time without re-applying:

```
terraform output
```

To get just one value:
```
terraform output instance_public_ip
```

To get it without quotes (useful in scripts):
```
terraform output -raw instance_public_ip
```

---

## Where Outputs Are Stored

Terraform stores all output values in the **state file** (`terraform.tfstate`).
This is the file Terraform uses to track what it has created.

> **Important:** The state file contains sensitive information (IPs, IDs, etc.).
> In production, store the state file in an encrypted S3 bucket, not on your local machine.
> For this lab, the local state file is fine.

---

**Next:** [10 - Deploy and Verify](10-deploy-and-verify.md)
