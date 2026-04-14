# Compute -- EC2 Instance

This is the main event.  The `aws_instance` resource is the actual virtual server.
Everything you built before this (VPC, subnet, security group, AMI lookup) feeds into it.

---

## What is EC2?

**EC2 (Elastic Compute Cloud)** is AWS's virtual machine service.
You rent a server by the hour and pay only for what you use.

An EC2 instance is defined by:

| Component | What You Are Choosing |
|-----------|----------------------|
| **AMI** | What operating system runs on the server |
| **Instance type** | How much CPU and RAM the server has |
| **Subnet** | Which network the server lives in |
| **Security Group** | What traffic the server accepts |
| **Key Pair** | How you log in via SSH |
| **Storage** | How much disk space the server has |
| **User Data** | A script that runs automatically on first boot |

---

## Create the File

```
touch compute.tf
```

---

## The EC2 Instance Block

```
####################################
## Create the EC2 Instance        ##
####################################
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  key_name      = var.key_name
  subnet_id     = aws_subnet.public.id

  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.web_server.id
  ]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = file("${path.module}/scripts/nginx_https_install.sh")

  tags = {
    Name = var.instance_name
  }
}
```

---

## Breaking It Down

### `ami = data.aws_ami.amazon_linux_2023.id`
Uses the AMI ID returned by the data source you created in `data.tf`.
Terraform runs the query, gets the latest Amazon Linux 2023 AMI ID, and uses it here.
No hard-coded AMI ID needed.

### `instance_type = "t3.micro"`
The server size.  `t3.micro` is:
- **Free tier eligible** (750 hours/month)
- 2 virtual CPUs
- 1 GB of RAM
- Burstable CPU performance for occasional spikes

### `key_name = var.key_name`
The SSH key pair to use.  This references the variable defined in `variables.tf`.
Default value is `"dev-example-key"` which is the key you created in the GUI walkthrough.

> **Important:** The `.pem` file you downloaded during the GUI walkthrough must be kept.
> This is how you will SSH into the server.

### `subnet_id = aws_subnet.public.id`
Launches the instance into the public subnet created in `network.tf`.
This determines what VPC the instance belongs to (subnet → VPC).

### `associate_public_ip_address = true`
AWS assigns a public IPv4 address to the instance automatically.
Without this, the instance only has a private IP and you cannot reach it from the internet.

### `vpc_security_group_ids = [ aws_security_group.web_server.id ]`
Attaches the security group you created in `security.tf`.
The brackets `[ ]` indicate a list -- you can attach multiple security groups if needed.

---

## Storage Block

```
root_block_device {
  volume_size = 30      ## 30 GB
  volume_type = "gp3"  ## General Purpose SSD v3
  encrypted   = true   ## Encrypt the disk at rest
}
```

| Parameter | Value | Meaning |
|-----------|-------|---------|
| `volume_size` | `30` | 30 GB disk -- free tier allows up to 30 GB |
| `volume_type` | `"gp3"` | Third-generation general purpose SSD (faster and cheaper than gp2) |
| `encrypted` | `true` | Data on disk is encrypted using AES-256 |

> **Free tier note:** AWS Free Tier includes 30 GB of EBS storage.
> Setting `volume_size = 30` is exactly the free tier limit -- do not go over.

---

## User Data

```
user_data = file("${path.module}/scripts/nginx_https_install.sh")
```

`user_data` is a script that runs **once** the very first time the instance boots.
This is how you automate software installation without ever logging in manually.

- `file()` -- a Terraform function that reads the contents of a file
- `${path.module}` -- the directory where this `.tf` file lives
- The full path becomes: `./scripts/nginx_https_install.sh`

When AWS launches the instance, it:
1. Boots into Amazon Linux 2023
2. Passes your script to the cloud-init service
3. Runs the script as root before anything else

> **Note on timing:** User data scripts run in the background after boot.
> Your instance will show "Running" in the console within 1-2 minutes,
> but the nginx installation takes 3-5 more minutes to complete.

---

## Tags

```
tags = {
  Name = var.instance_name
}
```

Tags are key-value labels attached to AWS resources.
The `Name` tag is displayed in the AWS Console as the human-readable name of the instance.
Using a variable means students can customize their instance name in `terraform.tfvars`.

---

## How All Files Connect

```
data.tf         → provides ami ID
variables.tf    → provides key_name, instance_name, my_ip
network.tf      → provides subnet_id
security.tf     → provides vpc_security_group_ids
scripts/        → provides user_data script
        │
        └──> compute.tf (aws_instance.web_server)
                    │
                    └──> outputs.tf (reads .public_ip, .private_ip, .id)
```

---

## AWS Console: Viewing Your Instance

After `terraform apply` you can verify in the console:
```
EC2 → Instances → Instances
```

> **Screenshot:** The Instances list shows a table.
> Your instance appears with:
> - Instance ID: i-0abc1234...
> - Instance state: Running (green dot)
> - Instance type: t3.micro
> - Public IPv4 address: displayed in the column
> - Name: terraform-nginx-server (from your Name tag)

Click the instance ID to see full details including:
- The AMI ID that was used
- The security groups attached
- The subnet and VPC it lives in
- The storage volumes attached

---

**Next:** [08 - User Data and Nginx HTTPS](08-user-data-nginx.md)
