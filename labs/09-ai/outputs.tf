output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.example.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.example.id
}

output "subnet_id" {
  description = "Subnet ID used for the instance"
  value       = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "Security group ID for SSH access"
  value       = aws_security_group.allow_ssh.id
}
