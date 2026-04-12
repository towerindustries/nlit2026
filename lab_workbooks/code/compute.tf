####################################
## Create the actual Ec2 Instance ##
####################################
resource "aws_instance" "example" {
  ami           = "ami-03a6eaae9938c858c" # Feed it the AMI you found
  instance_type = "t3.micro"              # Choose the size/type of compute you want
  key_name      = "dev-example-key"       # Here is the public key you want for ssh.
  subnet_id     = aws_subnet.example.id   # Put it on the Subnet you created.
  tags = {
    Name = "dev-amazon2023"
  }

  root_block_device {
    volume_size = 30    # If you wanted to increase the hard drive space here it is.
    volume_type = "gp3" # The type of storage you want to use.
    encrypted   = true
  }
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.example.id # Add the security group you created.
  ]
}