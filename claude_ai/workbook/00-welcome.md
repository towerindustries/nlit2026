# Welcome to Intro to AWS and Terraform

## What is this class?

This is a two-hour hands-on workshop.  You will deploy a real web server running on Amazon Web Services using a tool called Terraform.  No prior experience with AWS or Terraform is required.

---

## What is AWS?

Amazon Web Services (AWS) is a cloud computing platform.  Instead of buying a physical server, you rent computing resources from Amazon and pay only for what you use.

Key concepts you will use today:

| Concept | What It Is | Real World Analogy |
|---------|-----------|-------------------|
| **Region** | Geographic location of the datacenters | A city |
| **VPC** | Your private network inside AWS | A gated neighborhood |
| **Subnet** | A slice of the network | A street in the neighborhood |
| **EC2 Instance** | A virtual server | A house on that street |
| **Security Group** | Firewall rules for the server | Deadbolt lock on the door |
| **Internet Gateway** | On-ramp to the public internet | The neighborhood gate |
| **AMI** | A server image (OS snapshot) | A house blueprint |

---

## What is Terraform?

Terraform is an **Infrastructure as Code** tool made by HashiCorp.  Instead of clicking around in the AWS web console, you write a few text files that describe exactly what you want, and Terraform creates it for you.

**Benefits:**
- Repeatable -- run the same code 100 times, get the same result
- Version controlled -- tracked in git like any other code
- Destroyable -- one command tears everything down cleanly

---

## What You Will Build Today

By the end of this class you will have:

- A **VPC** with a public subnet in AWS `us-east-1`
- An **EC2 t3.micro** instance running **Amazon Linux 2023**
- A **30 GB encrypted gp3** root disk
- **nginx** web server running on HTTP (port 80) and HTTPS (port 443)
- A self-signed SSL certificate generated on first boot
- All resources described as **Terraform code** you can reuse

---

## Class Flow

```
Step 1 -- AWS GUI    : Launch a server by clicking (so you understand the parts)
Step 2 -- Terraform  : Rebuild the same server using code (the right way)
Step 3 -- Verify     : Open your browser and visit your server
Step 4 -- Destroy    : Tear everything down with one command
```

---

## Important: Clean Up After Class

AWS charges by the hour.  At the end of class you will run:

```
terraform destroy
```

This removes everything Terraform created.  Do not forget this step.

---

**Next:** [01 - Environment Setup](01-environment-setup.md)
