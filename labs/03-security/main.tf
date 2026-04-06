#############################################
## Create the Security Group to allow SSH  ##
## Modify the cider_blocks to your home IP ##
#############################################
resource "aws_security_group" "example" {
  name_prefix = "dev-ssh-access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["68.0.0.20/32"] # Change this to your home ip
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["68.0.0.20/32"] # Change this to your home ip
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["68.0.0.20/32"] # Change this to your home ip
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] ## Allow all outbound traffic
  }
  tags = {
    Name = "dev-security-group"
  }

  vpc_id = aws_vpc.example.id
}