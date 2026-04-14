# Networking

Before you can launch an EC2 instance you need a network for it to live in.
In AWS, that network is called a **VPC (Virtual Private Cloud)**.

---

## The Network Stack (in order)

```
Internet
    |
Internet Gateway    ← On-ramp to the public internet
    |
Route Table         ← Traffic map: where does each destination go?
    |
Subnet              ← A slice of the VPC's IP address space
    |
VPC                 ← Your private network container
```

You will create all of these in `network.tf`.

---

## Create the File

```
touch network.tf
```

---

## 1. VPC (Virtual Private Cloud)

```
############################################
## Create the VPC (Virtual Private Cloud) ##
############################################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}
```

### What is a CIDR block?

`10.0.0.0/16` defines the **total IP address space** available inside your VPC.

- The `/16` means the first 16 bits are fixed, the last 16 are flexible
- This gives you 65,536 possible IP addresses inside the VPC (10.0.0.0 through 10.0.255.255)
- Your servers, databases, and other resources will each get an IP from this range

> **Analogy:** The VPC is a neighborhood. `10.0.0.0/16` defines the zip code -- it tells AWS
> "everything in the 10.0.x.x range belongs to my network."

### The `"main"` label

`resource "aws_vpc" "main"` -- the word `"main"` is **Terraform's internal name** for this resource.
It is not the AWS name.  You use it to reference this VPC from other resources like this:
```
aws_vpc.main.id
```

---

## 2. Internet Gateway

```
#################################
## Create the Internet Gateway ##
#################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
```

An Internet Gateway (IGW) connects your VPC to the public internet.

- Without it, your VPC is completely isolated -- no inbound or outbound internet traffic
- `vpc_id = aws_vpc.main.id` attaches this gateway to the VPC you just created
- The `.id` at the end tells Terraform to use the **actual ID** that AWS assigns to the VPC

> **Important:** `aws_vpc.main.id` creates a **dependency**.
> Terraform knows it must create the VPC first, then attach the gateway to it.
> You do not have to manage this order yourself.

---

## 3. Subnet

```
#######################
## Create the Subnet ##
#######################
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dev-public-subnet"
  }
}
```

A subnet is a **slice** of the VPC's address space where you actually place resources.

| Parameter | Value | Meaning |
|-----------|-------|---------|
| `vpc_id` | `aws_vpc.main.id` | This subnet belongs to the VPC above |
| `cidr_block` | `10.0.1.0/24` | Gives ~251 usable IPs (10.0.1.1 - 10.0.1.254) |
| `availability_zone` | `us-east-1a` | Physical datacenter location |

> **Why /24?**
> A `/24` is a common subnet size.  It gives you 256 addresses (AWS reserves 5, so 251 usable).
> The subnet `10.0.1.0/24` must fit inside the VPC `10.0.0.0/16` -- it does.

> **Availability Zones:** Each AWS region has multiple isolated datacenters called AZs.
> `us-east-1a`, `us-east-1b`, `us-east-1c` are the AZs in Virginia.
> Subnets are AZ-specific and cannot span multiple AZs.

---

## 4. Route Table

```
############################
## Create the Route Table ##
############################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "dev-public-route-table"
  }
}
```

A route table is a set of rules (routes) that determine where network traffic is sent.

Think of it like a GPS: "If I want to go to address X, I should turn onto road Y."

The route table itself is empty at first.  You add routes to it next.

---

## 5. Default Route

```
##############################
## Create the Default Route ##
##############################
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
```

This rule says:

> "Send ALL internet-bound traffic (0.0.0.0/0 means everything) to the Internet Gateway."

| Parameter | Meaning |
|-----------|---------|
| `route_table_id` | Which route table this rule belongs to |
| `destination_cidr_block = "0.0.0.0/0"` | Match any destination address |
| `gateway_id` | Send matching traffic to the Internet Gateway |

---

## 6. Route Table Association

```
##################################
## Associate Subnet to Route Table ##
##################################
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

Subnets in AWS do not automatically use custom route tables -- you must explicitly link them.
This block says: "use this route table for traffic coming from this subnet."

Without this association, your route table exists but has no effect.

---

## Full network.tf

Paste the complete file content:

```
############################################
## Create the VPC (Virtual Private Cloud) ##
############################################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}

#################################
## Create the Internet Gateway ##
#################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

#######################
## Create the Subnet ##
#######################
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
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
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

##################################
## Associate Subnet to Route Table ##
##################################
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

---

## Dependency Chain

Terraform figures out the correct creation order automatically from the references in your code:

```
aws_vpc.main
    ├── aws_internet_gateway.main
    ├── aws_subnet.public
    └── aws_route_table.public
            ├── aws_route.default_route
            │       └── (also depends on aws_internet_gateway.main)
            └── aws_route_table_association.public
                    └── (also depends on aws_subnet.public)
```

---

**Next:** [05 - Security Groups](05-security.md)
