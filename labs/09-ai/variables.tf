variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_key_name" {
  description = "SSH key pair name for EC2"
  type        = string
  default     = "dev-example-key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_ip" {
  description = "IP allowed to SSH into the instance"
  type        = string
  default     = "68.0.0.20/32"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30
}
