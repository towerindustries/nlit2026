terraform {
  required_version = ">= 1.6.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "local" {}

resource "local_file" "workshop_file" {
  filename = "${path.module}/workshop.txt"
  content  = <<EOT
Workshop: ${var.workshop_name}
Owner: ${var.student_name}
Environment: ${var.environment}
EOT
}
