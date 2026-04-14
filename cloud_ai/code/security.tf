####################################################
## Create the Security Group                      ##
## Controls what traffic can reach your server    ##
####################################################
resource "aws_security_group" "web_server" {
  name_prefix = "dev-web-access-"
  vpc_id      = aws_vpc.main.id

  ## Allow SSH from your IP only
  ingress {
    description = "SSH from my machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]   ## Restrict to your IP only (from variables.tf)
  }

  ## Allow HTTP from your IP
  ingress {
    description = "HTTP from my machine"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ## Allow HTTPS from your IP
  ingress {
    description = "HTTPS from my machine"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ## Allow ALL outbound traffic (updates, downloads, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-web-security-group"
  }
}
