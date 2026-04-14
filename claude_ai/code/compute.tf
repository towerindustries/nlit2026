####################################
## Create the EC2 Instance        ##
####################################
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2023.id   ## Pulled dynamically from data.tf
  instance_type = "t3.micro"                          ## Free tier eligible: 2 vCPU, 1 GB RAM
  key_name      = var.key_name                        ## SSH key pair (from variables.tf)
  subnet_id     = aws_subnet.public.id                ## Place it in the public subnet

  associate_public_ip_address = true   ## Give it a public IP so we can reach it

  vpc_security_group_ids = [
    aws_security_group.web_server.id   ## Attach the security group
  ]

  ## Configure the root disk
  root_block_device {
    volume_size = 30         ## 30 GB of storage
    volume_type = "gp3"      ## General Purpose SSD (faster and cheaper than gp2)
    encrypted   = true       ## Encrypt the disk at rest
  }

  ## Run this script automatically on first boot
  user_data = file("${path.module}/scripts/nginx_https_install.sh")

  tags = {
    Name = var.instance_name
  }
}
