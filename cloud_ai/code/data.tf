###############################################################
## Data Source: Look Up the Latest Amazon Linux 2023 AMI    ##
## Terraform queries AWS at plan time and gets the most      ##
## recent available AMI so you never need to hard-code one   ##
###############################################################
data "aws_ami" "amazon_linux_2023" {
  most_recent = true        ## Always grab the newest one
  owners      = ["amazon"]  ## Only trust AMIs published by Amazon

  ## Filter by AMI name pattern matching Amazon Linux 2023 x86_64
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  ## Only return AMIs that are in the available state
  filter {
    name   = "state"
    values = ["available"]
  }
}
