# Network Setup
The network section is broken into the following sections:

1. VPC -- aws_vpc
2. Internet Gateway -- aws_internet_gateway
3. Subnet -- aws_subnet
4. Route Table -- aws_route_table
5. Default Route -- aws_route
6. Route Association -- aws_route_table_association



# aws_vpc
Creates the Virtual Private Cloud
* Where your server and all its dependencies reside:
    * Network
    * Security Groups
    * EC2 Server
* Example is not the AWS name.  It is Terraform's Internal label so you can reference it elsewhere:

```
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"      ## Define the ENTIRE IP space for the VPC instance
  tags = {
    Name = "dev-vpc"              ## Allows for easy identification
  }
}
```

# aws_internet_gateway
An Internet Gateway (IGW) is what allows a VPC to communicate with the public internet.  It attaches the gateway to the VPC defined as ```aws_vpc.example```.
* Enables inbound/outbound internet traffic
* Required for public subnets
* Works with route tables (0.0.0.0/0 → IGW)

Without it, your VPC is isolated (no internet)
```
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}
```
* aws_vpc → resource type
* example → resource name
* id → attribute exported by that resource

This is Terraform saying:

“Take the ID of the VPC we created earlier and use it here.”
#### Internet Gateway is connected to the VPC
> aws_vpc.example → aws_internet_gateway.example

# aws_subnet
Creates the subnet inside the VPC.
* VPC = entire network (e.g., 10.0.0.0/16)
* Subnet = slice of that network (e.g., 10.0.1.0/24)
* AZ = physical location/datacenter


```
resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id  ## Connects to the VPC created above
  cidr_block        = "10.0.1.0/24"       ## The subnet's CIDR block
  availability_zone = "us-east-1a"        ## AWS Availability zone you want it in
  tags = {
    Name = "dev-subnet"
  }
}
```
### vpc_id
* Connects back to the VPC we created above
* vpc_id = aws_vpc.example.id
###  cidr_block
* You only get ~251 usable IPs from AWS
* Must be inside the VPC CIDR block (10.0.0.0/16)
### availability_zone
* Subnets are AZ specific.  You can not span across AZs.

#### Subnet is connect to the VPC
> aws_vpc.example  → aws_subnet.example

## Visual Example
* VPC = neighborhood
* Subnet = street
* CIDR = address range on that street
* AZ = which city block the street is in

# aws_route_table
Create a set of routing rules.
>"If traffic is goign to X, where should I send it."

Examples:

* 10.0.0.0/16 → local (stay inside VPC)
* 0.0.0.0/0 → Internet Gateway (go to internet)

```
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-route-table"
  }
}
```
### vpc_id = aws_vpc.example.id
* Attach this route to the VPC.
* Creates an implicit dependency (VPC must exist first)

# aws_route
“Send all internet-bound traffic to the Internet Gateway."

```
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.example.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}
```

### route_table_id
Connects the default route to the aws_route_table we created above.

### destination_cidr_block
“Match all IPv4 traffic, regardless of destination.”

### gateway_id
“Send matching traffic to the Internet Gateway we created.”

Route Table → Internet Gateway → Internet

# aws_route_table_association
In Amazon Web Services, subnets don’t automatically use your custom route tables—you must explicitly associate them.  This block is what actually makes your routing take effect. Without it, your route table just exists—but isn’t used by anything.

```
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.example.id
}
```
Subnet → Route Table → Routes → Gateway


# Full Network Code Section
Paste this code into your ```main.tf``` file.

```
############################################
## Create the VPC (Virtual Private Cloud) ##
############################################
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}
#################################
## Create the Internet Gateway ##
#################################
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}
#######################
## Create the Subnet ##
#######################
resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dev-subnet"
  }
}
############################
## Create the Route Table ##
############################
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "example-route-table"
  }
}
##############################
## Create the Default Route ##
##############################
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.example.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.example.id
}
##################################
## Create the Route Association ##
##################################
resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.example.id
}
```