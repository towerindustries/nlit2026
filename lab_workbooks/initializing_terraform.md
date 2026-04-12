# Initializing Terraform
1. Copy Code to lab_env folder
2. run ```terraform init```
3. login to aws ```aws login --remote```
4. Visit AWS link for authentication
5. Copy Authentication code into terminal
6. Test Authentication ```aws s3 ls```

## Copy Terraform Code into a lab environment folder
```
mkdir /opt/lab_env
cp /workspaces/nlit2026/lab_workbooks/code/* /opt/lab_env
cd /opt/lab_env
```
## Your code looks like garbage
Clean up your terraform formatting
```
terraform fmt
```

## Run the Terraform initilization Command
```
terraform init
```

### Expected output
root ➜ /opt/lab_env $ terraform init
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "6.40.0"...
- Installing hashicorp/aws v6.40.0...
- Installed hashicorp/aws v6.40.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```


```
terraform plan

```
### Errors out
root ➜ /opt/lab_env $ terraform plan
```
Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: No valid credential sources found
│
│   with provider["registry.terraform.io/hashicorp/aws"],
│   on provider.tf line 10, in provider "aws":
│   10: provider "aws" {
│
│ Please see https://registry.terraform.io/providers/hashicorp/aws
│ for more information about providing credentials.
│
│ Error: failed to refresh cached credentials, no EC2 IMDS role found, operation error ec2imds: GetMetadata, failed to
│ get API token, operation error ec2imds: getToken, http response error StatusCode: 400, request to EC2 IMDS failed
```
# AWS Autentication is missing

## Terminal login
1. aws login --remote
2. AWS Region: us-east-1
2. control + right click url
3. select your user in the web browser
4. copy verification code
5. paste code into Codespace terminal

### Example Output
root ➜ /opt/lab_env $ aws login --remote
```
No AWS region has been configured. The AWS region is the geographic location of your AWS resources.

If you have used AWS before and already have resources in your account, specify which region they were created in. If you have not created resources in your account before, you can pick the region closest to you: https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html.

You are able to change the region in the CLI at any time with the command "aws configure set region NEW_REGION".
AWS Region [us-east-1]:
Browser will not be automatically opened.
Please visit the following URL:

https://us-east-1.signin.aws.amazon.com/v1/authorize?response_type=code&client_id=arn%3Aaws%3Asignin%3A%3A%3Adevtools%2Fcross-device&state=a09ac00d-156f-4ae3-8145-4831522ca176&code_challenge_method=SHA-256&scope=openid&redirect_uri=https%3A%2F%2Fus-east-1.signin.aws.amazon.com%2Fv1%2Fsessions%2Fconfirmation&code_challenge=yQCCA0rM6gL---t7Ze9cp5Jh3FnUPZ1p-dLd-ZELvFQ

Enter the authorization code displayed in your browser: Y29kZT1leUo2YVhBaU9pSkVSVVlpTENKbGJtTWlPaUpCTWpVMlIwTk5JaXdpWVd4b<oUlFEamtnZzUxRFlYWE5KLjl2ZVVhdVR1ajFZZDhzTklYTVNhZXcmc3RhdGU9YTA5YWMwMGQtMTU2Zi00YWUzLTgxNDUtNDgzMTUyMmNhMTc2

Updated profile default to use arn:aws:iam::941897908476:root credentials.
```

## Test Authentication
List any s3 buckets you have. (probably none though)
```
aws s3 ls
```
