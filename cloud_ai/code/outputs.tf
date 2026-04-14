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
  description = "URL to visit your nginx web page over HTTPS (self-signed cert - browser warning is expected)"
  value       = "https://${aws_instance.web_server.public_ip}"
}
