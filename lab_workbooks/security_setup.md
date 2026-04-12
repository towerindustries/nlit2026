# Security Groups



## aws_security_group
Creates the Security Group
* Controls inbound traffic (e.g., allow SSH on port 22)
* Controls outbound traffic
* Acts like a virtual firewall
* Example is not the AWS name.  It is Terraform's Internal label so you can reference it elsewhere:

```
resource "aws_security_group" "example" {
  name_prefix = "dev-ssh-access"
```

### Ingress
Defines incoming traffic rules to your server.
```
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
```
### Egress
Defines outgoing traffic rules from your server.
```
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] ## Allow all outbound traffic
  }
```
### Tags
Adding tags allows one to easily identify things both inside the code and inside the AWS Console GUI.
```
  tags = {
    Name = "dev-security-group"
  }
```

### VPC_ID
Ties the Security Group to the VPC we created earlier.  If you called it something besides example above you will need to make sure it matches here.
```
  vpc_id = aws_vpc.example.id
}
```

# Full Security Group Code Section
Paste this code into your ```main.tf``` file add the security group.
```
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
```