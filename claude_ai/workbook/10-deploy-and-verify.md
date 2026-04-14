# Deploy and Verify

You have written all the Terraform files.  Now it is time to deploy your infrastructure
and verify that nginx is running with HTTPS.

---

## Your Lab Directory Should Look Like This

Before deploying, confirm all files are present:

```
ls /opt/lab_env
```

Expected output:
```
data.tf
compute.tf
network.tf
outputs.tf
provider.tf
security.tf
terraform.tfvars
variables.tf
scripts/
    nginx_https_install.sh
```

If any files are missing, go back to the relevant workbook section and create them.

---

## Step 1: Format Your Code

Clean up whitespace and indentation:
```
cd /opt/lab_env
terraform fmt
```

This command only changes whitespace.  It is safe to run at any time.

---

## Step 2: Initialize Terraform

If you have not already initialized, run:
```
terraform init
```

Expected output includes:
```
Terraform has been successfully initialized!
```

> If you already ran `terraform init` earlier you do not need to run it again
> unless you add new providers.

---

## Step 3: Plan Your Deployment

Before creating anything, ask Terraform to show you what it will do:
```
terraform plan
```

Terraform will:
1. Read your `.tf` files
2. Query AWS for the latest Amazon Linux 2023 AMI
3. Compare what you want to what currently exists
4. Print a list of actions it will take

### Reading the Plan Output

Each resource shows one of these symbols:

| Symbol | Meaning |
|--------|---------|
| `+` | Will be **created** |
| `-` | Will be **destroyed** |
| `~` | Will be **modified** |

Expected output (abbreviated):
```
Terraform will perform the following actions:

  # aws_instance.web_server will be created
  + resource "aws_instance" "web_server" {
      + ami                         = "ami-0abc1234..."
      + instance_type               = "t3.micro"
      + public_ip                   = (known after apply)
      ...
    }

  # aws_vpc.main will be created
  + resource "aws_vpc" "main" {
      + cidr_block = "10.0.0.0/16"
      ...
    }

  ... (6 more resources)

Plan: 8 to add, 0 to change, 0 to destroy.
```

> **The public IP shows "(known after apply)"** because AWS assigns it at creation time.
> Terraform does not know it yet, but it will be captured and shown in outputs after apply.

### Common Errors at Plan Stage

**Missing credentials:**
```
Error: No valid credential sources found
```
Solution: Run `aws login --remote` and try again.

**Missing tfvars:**
```
Error: No value for required variable
  var.my_ip is not set
```
Solution: Make sure you created `terraform.tfvars` with your IP address.

---

## Step 4: Apply

Deploy everything:
```
terraform apply
```

Terraform will display the plan again and ask for confirmation:
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Type `yes` and press Enter.

### What Happens During Apply

Terraform creates resources in the correct order (respecting dependencies):

```
1. aws_vpc.main                           (VPC first)
2. aws_internet_gateway.main              (needs VPC)
3. aws_subnet.public                      (needs VPC)
4. aws_route_table.public                 (needs VPC)
5. aws_security_group.web_server          (needs VPC)
6. aws_route.default_route                (needs IGW + route table)
7. aws_route_table_association.public     (needs subnet + route table)
8. aws_instance.web_server                (needs everything above)
```

Expected output after success:
```
aws_vpc.main: Creating...
aws_vpc.main: Creation complete after 2s [id=vpc-0abc1234...]
aws_internet_gateway.main: Creating...
aws_subnet.public: Creating...
...
aws_instance.web_server: Still creating... [10s elapsed]
aws_instance.web_server: Still creating... [20s elapsed]
aws_instance.web_server: Creation complete after 32s [id=i-0abc1234...]

Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

ami_used            = "ami-0abc1234def56789a"
http_url            = "http://54.201.32.88"
https_url           = "https://54.201.32.88"
instance_id         = "i-0abc1234ef5678901"
instance_name       = "terraform-nginx-server"
instance_private_ip = "10.0.1.42"
instance_public_ip  = "54.201.32.88"
ssh_command         = "ssh -i dev-example-key.pem ec2-user@54.201.32.88"
vpc_id              = "vpc-0abc1234ef5678901"
```

---

## Step 5: Wait for User Data to Finish

Your instance is now **running** but the nginx installation script is still executing in the background.

Wait **3-5 minutes** before trying to connect.

You can check progress by SSH-ing in and watching the log:
```
ssh -i dev-example-key.pem ec2-user@YOUR_PUBLIC_IP
sudo tail -f /var/log/user-data.log
```

Press `Ctrl + C` to stop watching the log.

When you see this line the setup is complete:
```
Nginx setup complete. HTTP and HTTPS are now active.
```

---

## Step 6: Test HTTP

Copy the `http_url` from your outputs.  Example: `http://54.201.32.88`

Open it in your browser.

> **Screenshot:** You should see a web page that says:
> "You deployed this with Terraform!"
> with your public IP address displayed on the page.

If you see a connection refused error, wait another minute and try again.
The user data script may still be running.

---

## Step 7: Test HTTPS

Copy the `https_url` from your outputs.  Example: `https://54.201.32.88`

Open it in your browser.

> **Screenshot:** Your browser will show a security warning page.
> In Chrome it says: "Your connection is not private"
> In Firefox it says: "Warning: Potential Security Risk Ahead"

This is **expected behavior** for a self-signed certificate.
The connection is encrypted -- the browser just does not trust the certificate authority.

To proceed:
- **Chrome:** Click **Advanced** → **Proceed to 54.201.32.88 (unsafe)**
- **Firefox:** Click **Advanced...** → **Accept the Risk and Continue**

> **Screenshot:** After accepting the warning you see the same nginx page as HTTP,
> but the URL bar now shows `https://` and a padlock icon (sometimes with a warning triangle
> because the cert is self-signed).

---

## Step 8: SSH Into Your Server (Optional)

Use the `ssh_command` from your outputs:
```
ssh -i dev-example-key.pem ec2-user@YOUR_PUBLIC_IP
```

Once logged in, explore:
```
## Check nginx status
sudo systemctl status nginx

## View access logs
sudo tail /var/log/nginx/access.log

## View the SSL certificate
sudo openssl x509 -in /etc/pki/nginx/server.crt -text -noout | grep -E "Subject:|Validity"

## Check what ports nginx is listening on
sudo ss -tlnp | grep nginx
```

---

## Step 9: Verify in the AWS Console

Go to `https://console.aws.amazon.com` → **EC2** → **Instances**

> **Screenshot:** Your instance appears in the list with:
> - Name: terraform-nginx-server
> - Instance state: Running (green dot)
> - Instance type: t3.micro
> - Public IPv4 address: your public IP

Explore:
- Click the instance ID
- Check the **Details** tab (AMI, VPC, subnet)
- Check the **Security** tab (security group rules)
- Check the **Storage** tab (30 GB gp3 volume)

Also check:
- **EC2 → Network & Security → Security Groups** -- see your security group rules
- **VPC → Your VPCs** -- see your VPC with the `dev-vpc` name tag
- **VPC → Subnets** -- see your `dev-public-subnet`
- **VPC → Internet Gateways** -- see the gateway attached to your VPC

---

## Step 10: Clean Up (REQUIRED)

When you are done, destroy everything to avoid AWS charges:

```
terraform destroy
```

Terraform will show you everything it plans to delete and ask for confirmation:
```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

Type `yes` and press Enter.

Expected output:
```
aws_instance.web_server: Destroying... [id=i-0abc1234...]
aws_instance.web_server: Still destroying... [10s elapsed]
...
aws_instance.web_server: Destruction complete after 32s
aws_route_table_association.public: Destroying...
...
aws_vpc.main: Destruction complete after 1s

Destroy complete! Resources: 8 destroyed.
```

> **Verify in the console:** Go to EC2 → Instances.
> Your instance should show state "Shutting down" then "Terminated".
> All VPC resources should be removed from VPC → Your VPCs.

---

## Congratulations!

You have:
- Learned the key components of AWS networking and compute
- Written Terraform code that provisions a complete VPC + EC2 stack
- Used a data source to dynamically look up the latest AMI
- Auto-installed nginx with HTTP and HTTPS using user data
- Deployed real infrastructure with `terraform apply`
- Cleaned up with `terraform destroy`

---

## What to Explore Next

| Topic | What You Will Learn |
|-------|-------------------|
| Terraform modules | Reuse code across projects |
| Terraform variables files | Manage multiple environments (dev/staging/prod) |
| AWS S3 remote state | Share state across a team |
| AWS IAM | Control who can do what in your account |
| Let's Encrypt | Real trusted HTTPS certificates (no browser warning) |
| AWS Certificate Manager | Free managed SSL certificates for AWS resources |
| Terraform Cloud | Managed state, runs, and collaboration |
