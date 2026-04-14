# Provider Setup

## What is a Terraform Provider?

A **provider** is a plugin that allows Terraform to communicate with a specific platform.
Without a provider, Terraform does not know how to talk to AWS.

Think of a provider like a device driver:
- Your operating system does not know how to talk to a printer directly
- A printer driver gives the OS instructions on how to do it
- A Terraform provider gives Terraform instructions on how to talk to AWS

### Official Providers (maintained by HashiCorp or cloud vendors)
- `hashicorp/aws` → Amazon Web Services
- `hashicorp/azurerm` → Microsoft Azure
- `hashicorp/google` → Google Cloud Platform
- `hashicorp/docker` → Docker containers

---

## Set Up Your Working Directory

Make sure you are in your lab directory:
```
cd /opt/lab_env
```

Create the provider file:
```
touch provider.tf
```

Open the file in VS Code and paste in the following code:

---

## The Provider Block

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"     ## Where to download the provider from
      version = "6.40.0"            ## Exact version to use
    }
  }
}

provider "aws" {
  region = "us-east-1"              ## AWS region where resources will be created
}
```

### Breaking It Down

**`terraform { }` block**
The outer block tells Terraform what plugins it needs.

**`required_providers { }`**
Lists every provider plugin this configuration depends on.

**`source = "hashicorp/aws"`**
Tells Terraform to download the AWS provider from the official HashiCorp registry at `registry.terraform.io`.

**`version = "6.40.0"`**
Pins the provider to a specific version.
- Providers release updates that can sometimes break existing code
- Pinning ensures your code works the same way today and six months from now
- In a team environment everyone uses the same version

**`provider "aws" { }`**
Configures the AWS provider itself.

**`region = "us-east-1"`**
All AWS resources will be created in the US East (N. Virginia) region.
This is the same region you used in the GUI walkthrough.

---

## Initialize Terraform

After writing `provider.tf`, run:
```
terraform init
```

### What terraform init does
1. Reads the `required_providers` block
2. Downloads the AWS provider plugin from `registry.terraform.io`
3. Saves it to a `.terraform/` folder in your working directory
4. Creates a `.terraform.lock.hcl` file that records the exact version downloaded

### Expected Output
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "6.40.0"...
- Installing hashicorp/aws v6.40.0...
- Installed hashicorp/aws v6.40.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository.

Terraform has been successfully initialized!
```

> **If you see errors here:** Make sure your internet connection is active.
> The Codespace needs to download the provider from the internet.

---

## Format Your Code

Terraform has a built-in formatter.  Run it any time you want clean, consistent indentation:
```
terraform fmt
```

This is safe to run at any time -- it only changes whitespace.

---

## Also Create Your Variables File

Create a `variables.tf` file:
```
touch variables.tf
```

Paste in this content:
```
##################################
## Input Variables for the Lab  ##
##################################

variable "my_ip" {
  description = "Your public IP address in CIDR notation.  Example: 1.2.3.4/32"
  type        = string
}

variable "key_name" {
  description = "The name of the AWS Key Pair for SSH access"
  type        = string
  default     = "dev-example-key"
}

variable "instance_name" {
  description = "The Name tag applied to your EC2 instance"
  type        = string
  default     = "terraform-nginx-server"
}
```

### Create Your tfvars File

Variables with no default value (like `my_ip`) **must** be supplied before you can run `terraform apply`.
The recommended way is a `terraform.tfvars` file:

```
touch terraform.tfvars
```

Add the following -- replacing `YOUR_IP` with the IP you found at `whatismyip.com`:
```
my_ip         = "YOUR_IP/32"
key_name      = "dev-example-key"
instance_name = "terraform-nginx-server"
```

> **Example:** If your IP is `68.4.12.99`, your file would contain:
> `my_ip = "68.4.12.99/32"`

> **Security note:** Never commit `terraform.tfvars` to a public git repository if it contains
> sensitive values.  Add it to `.gitignore` for real projects.

---

**Next:** [04 - Networking](04-network.md)
