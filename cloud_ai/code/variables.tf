##################################
## Input Variables for the Lab  ##
##################################

variable "my_ip" {
  description = "Your public IP address in CIDR notation.  Find yours at https://whatismyip.com  Example: 1.2.3.4/32"
  type        = string
  # Replace with your own IP before running terraform apply
  # Example: my_ip = "68.0.0.20/32"
}

variable "key_name" {
  description = "The name of the AWS Key Pair used for SSH access (created during the GUI walkthrough)"
  type        = string
  default     = "dev-example-key"
}

variable "instance_name" {
  description = "The Name tag applied to your EC2 instance"
  type        = string
  default     = "terraform-nginx-server"
}
