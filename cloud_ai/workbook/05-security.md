# Security Groups

A **Security Group** is a virtual firewall that controls what network traffic is allowed
to reach your EC2 instance and what traffic it can send out.

---

## Inbound vs Outbound

| Direction | Term | Controlled By |
|-----------|------|--------------|
| Traffic coming **into** your server | **Ingress** | Inbound rules |
| Traffic leaving **from** your server | **Egress** | Outbound rules |

AWS Security Groups are **deny by default**.
Nothing is allowed in unless you explicitly create a rule to permit it.
All outbound traffic is allowed by default (but you can restrict it).

---

## Ports You Will Open

| Port | Protocol | Purpose |
|------|----------|---------|
| 22 | TCP | SSH -- log in to manage your server via command line |
| 80 | TCP | HTTP -- web traffic (unencrypted) |
| 443 | TCP | HTTPS -- web traffic (encrypted / SSL) |

---

## Create the File

```
touch security.tf
```

---

## The Security Group Block

```
####################################################
## Create the Security Group                      ##
## Controls what traffic can reach your server    ##
####################################################
resource "aws_security_group" "web_server" {
  name_prefix = "dev-web-access-"
  vpc_id      = aws_vpc.main.id

  ## Allow SSH from your IP only
  ingress {
    description = "SSH from my machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ## Allow HTTP from your IP
  ingress {
    description = "HTTP from my machine"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ## Allow HTTPS from your IP
  ingress {
    description = "HTTPS from my machine"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ## Allow ALL outbound traffic (updates, downloads, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-web-security-group"
  }
}
```

---

## Breaking It Down

### `name_prefix = "dev-web-access-"`
AWS generates the actual security group name by appending a random suffix to this prefix.
Example result: `dev-web-access-20250412141532`
This prevents name collisions if you create and destroy the group multiple times.

### `vpc_id = aws_vpc.main.id`
Security groups are VPC-specific.  This ties the security group to the VPC you created.

### `ingress { }` blocks
Each block defines one **inbound** rule.

| Parameter | Meaning |
|-----------|---------|
| `from_port` | Starting port (for a single port, same as `to_port`) |
| `to_port` | Ending port |
| `protocol = "tcp"` | TCP is required for SSH, HTTP, and HTTPS |
| `cidr_blocks = [var.my_ip]` | Only allow traffic from your IP address |

### `var.my_ip`
This references the `my_ip` variable you defined in `variables.tf`.
Terraform substitutes the actual value from your `terraform.tfvars` file at apply time.

### `egress { }` block
The egress rule allows all outbound traffic so the server can:
- Install software (dnf update, dnf install)
- Download packages from the internet
- Respond to your HTTP/HTTPS requests

```
from_port   = 0
to_port     = 0
protocol    = "-1"    ## -1 means ALL protocols
cidr_blocks = ["0.0.0.0/0"]  ## Allow to any destination
```

---

## Why Lock Down to Your IP?

`cidr_blocks = [var.my_ip]` restricts access to your specific IP address.

If you used `"0.0.0.0/0"` (allow from anywhere):
- Your SSH port would be exposed to the entire internet
- Automated bots constantly scan the internet for open port 22
- Within minutes of launch your server would receive brute-force login attempts

Restricting to your IP is a key security practice.

> **Note for the lab:** If your IP address changes (e.g. you move from home to a coffee shop),
> you will need to update `terraform.tfvars` and run `terraform apply` again.

---

## AWS Console: Where Security Groups Live

In the AWS Console you can see your security groups at:
```
EC2 → Network & Security → Security Groups
```

> **Screenshot:** The Security Groups page shows a table with columns:
> Security group ID | Security group name | VPC ID | Description
>
> Clicking a security group shows two tabs at the bottom:
> - **Inbound rules** -- what is allowed IN
> - **Outbound rules** -- what is allowed OUT

---

**Next:** [06 - AMI Data Lookup](06-ami-data-lookup.md)
