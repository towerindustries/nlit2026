############################################
## Create the VPC (Virtual Private Cloud) ##
############################################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"   ## The entire IP space available inside this VPC
  tags = {
    Name = "dev-vpc"
  }
}

#################################
## Create the Internet Gateway ##
#################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id   ## Attach the gateway to our VPC
}

#######################
## Create the Subnet ##
#######################
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"   ## A slice of the VPC address space (~251 usable IPs)
  availability_zone = "us-east-1a"    ## Physical datacenter location inside the region
  tags = {
    Name = "dev-public-subnet"
  }
}

############################
## Create the Route Table ##
############################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "dev-public-route-table"
  }
}

##############################
## Create the Default Route ##
##############################
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"                    ## Match ALL internet-bound traffic
  gateway_id             = aws_internet_gateway.main.id   ## Send it to the internet gateway
}

##################################
## Associate Subnet to Route Table ##
##################################
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
