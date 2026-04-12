# Intro to Cloud Automation with Terraform
# Instructions:  Gui Walkthough

## 1: GUI Walk-Through
AWS Console URL:  https://console.aws.amazon.com

Click: EC2 -> Instances -> Launch Instance

1. Name: terraform_gui
2. Choose Operating System: Amazon Linux
3. Instance Type: t3.micro
4. Create New Key Pair:  dev-example-key
5. Create Security Group:  dev-example-key
6: Save pem file to your hard drive
6. Allow SSH from "anywhere"
7. Configure Storage: 30gb
8. gp3
9. Launch Instances

## Optional
Click: Ec2 > Instances > Instance ID i-0248ed7b010e36600
* Example: i-0248ed7b010e36609
Copy > Auto-Assigned IP Address
# SSH:
Username = ec2user  
Certificate = dev-example-key.pem
* Example: ssh -i dev-example-key.pem  ec2-user@184.72.131.29