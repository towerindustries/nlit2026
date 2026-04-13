# Outline

1. Environment Setup
2. Providers
3. Initializing Terraform
4. Network Setup
5. Security Setup
6. Compute Setup

# Environment Setup
1. Load Github Codespace
2. ```mkdir /opt/dev_lab```
3. ```touch /opt/dev_lab/main.tf```


# Providers
1. Copy AWS Provider info from the Terraform website
2. Paste AWS provider code into ```main.tf```

# Initiliazing Terraform
1. Run ```terraform init``` inside /opt/dev_lab
2. login to aws ```aws login --remote```
3. Visit AWS link for authentication
4. Copy Authentication code into terminal
5. Test Authentication ```aws s3 ls```

# Network Setup
1. Copy ```nlit2026/tree/main/labs/02-network/main.tf``` network code into ```/opt/dev_lab/main.tf```


# Security Setup
1. Copy ```nlit2026/tree/main/labs/03-security/main.tf``` network code into ```/opt/dev_lab/main.tf```

# Compute Setup
1. Copy ```nlit2026/tree/main/labs/04-compute/main.tf``` compute/ec2 code into ```/opt/dev_lab/main.tf```


# Outputs
1. Copy ```nlit2026/tree/main/labs/05-outputs/main.tf``` outputs code into ```/opt/dev_lab/main.tf```

# User Data
1. Append ```nlit2026/tree/main/labs/06-userdata/main.tf``` outputs code into ```/opt/dev_lab/main.tf``` under ```resource "aws_instance" "example"```
