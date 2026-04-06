
# Working EC2 Deploy

## SSH Key Pair
From The CLI Create

* EC2 > Key Pairs > Create Key Pair
* Name: dev-example-key
* Key Pair Type: RSA
* Private Key File Format: OpenSSH
Add New Tag:
* Key: Terraform_101
* Value: 'Todays Date'

```
terraform init
terraform plan

```

## SSH into the server
```
ssh -i /path/to/private/key username@remote_host
```

### Example SSH login
```
ssh -i dev-example-key.pem ec2-user@52.91.230.7
```