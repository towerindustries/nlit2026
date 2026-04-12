# Providers
https://registry.terraform.io/namespaces/hashicorp

The ```Providers``` section is broken into the following sections:

1. Required Terraform Version -- ```required_version```
2. Required Providers -- ```required_providers```
3. Define Provider Version -- ```version = "~> 5.0"```
2. Provider Special Config Options


Plugin for Terraform to make API calls

Offical Providers
Maintained by HashiCorp or vendors
* AWS
* Azure
* Google Cloud
* Docker
* VMware

Partner Providers -- Maintained by Companies

* Cloudflare
* Datadog
* Kong Inc.

Community Providers -- Open-source, not officially supported

Specialized Providers -- Not cloud-based at all:
* Docker → Docker
* Kubernetes → Kubernetes
* Local → filesystem operations
* Random → generates random values

Example Provider Block

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"     ##
      version = "6.39.0"            ## Version of the Provider to run
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"              ## Optional AWS configuration
}
```
When providers change they can break your code.  By restricting the configuration to a specific version it will allow your code to continue to work.

Multiple Providers (Advanced)
You can use multiple providers in one config:
```
provider "aws" {
  region = "us-east-1"
}

provider "docker" {}

resource "aws_instance" "vm" { ... }

resource "docker_container" "nginx" { ... }
```

## How Providers Get Installed
```
terraform init
```
Terraform:

1. Reads required providers
2. Downloads them from the registry
3. Caches them locally

# Full Provider Code Section
Paste this code into your ```main.tf``` file.
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}
```
