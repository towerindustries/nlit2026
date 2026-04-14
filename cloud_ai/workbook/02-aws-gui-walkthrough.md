# AWS GUI Walkthrough

Before writing any Terraform code, you will launch an EC2 instance manually using the AWS Console.
This helps you understand every piece that Terraform will build for you automatically.

> **Goal:** Launch a server by clicking, understand what each option means, then delete it.

---

## Open the AWS Console

1. Open your browser and go to `https://console.aws.amazon.com`
2. Sign in with your AWS credentials

> **Screenshot:** You will land on the **AWS Management Console** home page.
> It shows a search bar at the top and a grid of AWS service icons.
> Make sure the region in the **top-right corner** says **N. Virginia (us-east-1)**.
> If it shows a different region, click it and select **US East (N. Virginia)**.

---

## Navigate to EC2

1. Click the **search bar** at the top of the page (or press `Alt + S`)
2. Type `EC2`
3. Click **EC2** in the results under "Services"

> **Screenshot:** You will see the **EC2 Dashboard**.  The left sidebar shows:
> Instances, Images, Elastic Block Store, Network & Security, and more.
> The main panel shows a summary of your running resources (all zeros if this is a new account).

---

## Launch Instance - Start the Wizard

1. In the left sidebar, click **Instances**
2. Click the orange **Launch instances** button in the upper right

> **Screenshot:** You are now on the **Launch an instance** page.
> This is a single long page with multiple sections you will fill out from top to bottom.

---

## Section 1: Name Your Instance

1. Find the field labeled **Name and tags** at the top
2. In the **Name** text box, type: `gui-walkthrough`

> **Screenshot:** A text box with a placeholder that says "Enter value here".
> After typing, you will see "gui-walkthrough" appear in the Name field.

---

## Section 2: Choose an Operating System (AMI)

1. Under **Application and OS Images (Amazon Machine Image)**, look for the tabs:
   - Quick Start | My AMIs | AWS Marketplace | Community AMIs
2. Make sure **Quick Start** is selected (it should be by default)
3. Find the **Amazon Linux** tile and click it
4. In the dropdown below the tile, make sure it shows **Amazon Linux 2023 AMI**

> **Screenshot:** You will see several OS tiles: Amazon Linux, macOS, Ubuntu, Windows, etc.
> The Amazon Linux tile has an orange AWS logo.  Once selected it turns blue/highlighted.
> Below the tile a dropdown appears listing available versions.
> Select the option that says "Amazon Linux 2023 AMI" with "64-bit (x86)" architecture.

> **What is an AMI?**
> An AMI (Amazon Machine Image) is a pre-built snapshot of an operating system.
> Think of it as a USB drive with the OS already installed.
> AWS has thousands of them.  Amazon Linux 2023 is Amazon's own Linux distribution optimized for EC2.

---

## Section 3: Choose Instance Type

1. Find the **Instance type** section
2. Click the dropdown (it likely shows `t2.micro` by default)
3. Type `t3.micro` in the search box
4. Select **t3.micro**

> **Screenshot:** A searchable dropdown listing hundreds of instance types.
> After selecting t3.micro you will see:
> - Family: t3
> - vCPUs: 2
> - Memory: 1 GiB
> The label **Free tier eligible** appears in green next to it.

> **What is an instance type?**
> Instance types define how much CPU and memory your server has.
> `t3.micro` = 2 virtual CPUs + 1 GB of RAM.  Small but free!
> The `t` stands for "burstable" performance -- good for workloads with occasional spikes.

---

## Section 4: Create a Key Pair (SSH Access)

1. Find the **Key pair (login)** section
2. Click **Create new key pair**

> **Screenshot:** A popup modal window appears with these fields:
> - Key pair name (text input)
> - Key pair type (RSA selected)
> - Private key file format (.pem selected for Mac/Linux, .ppk for PuTTY/Windows)

3. In the **Key pair name** field, type: `dev-example-key`
4. Leave **RSA** selected as the Key pair type
5. Leave **.pem** selected as the Private key file format
6. Click the orange **Create key pair** button

> **Screenshot:** Your browser will automatically download a file called `dev-example-key.pem`
> Save this file somewhere safe on your computer -- you cannot download it again!
> The modal closes and you are back on the launch page.
> The Key pair dropdown now shows **dev-example-key**.

> **What is a key pair?**
> SSH key pairs are how you securely log into Linux servers without a password.
> AWS stores the public key.  You keep the private key (.pem file).
> Anyone with the .pem file can log into your server -- keep it private.

---

## Section 5: Network Settings (Security Group)

1. Find the **Network settings** section
2. Click **Edit** in the upper right of that section

> **Screenshot:** The Network settings section expands to show:
> - VPC dropdown (showing your default VPC)
> - Subnet dropdown
> - Auto-assign public IP toggle
> - Firewall (security groups) options

3. Under **Firewall (security groups)**, select **Create security group**
4. In the **Security group name** field, type: `dev-web-sg`
5. In the **Description** field, type: `Allow SSH HTTP HTTPS`

### Add SSH Rule
The first rule (SSH on port 22) is added by default.

6. In the **Source type** dropdown for the SSH rule, click the dropdown and select **My IP**

> **Screenshot:** The CIDR box auto-fills with your current public IP address and /32.
> Example: `68.4.12.99/32`
> This restricts SSH access to your machine only.

### Add HTTP Rule
7. Click **Add security group rule**
8. Set **Type** to `HTTP`
9. Set **Source type** to **My IP**

### Add HTTPS Rule
10. Click **Add security group rule**
11. Set **Type** to `HTTPS`
12. Set **Source type** to **My IP**

> **Screenshot:** You should now see three inbound rules listed:
> - SSH    Port 22   Your-IP/32
> - HTTP   Port 80   Your-IP/32
> - HTTPS  Port 443  Your-IP/32

---

## Section 6: Configure Storage

1. Find the **Configure storage** section
2. You will see a default entry like `1x  8 GiB  gp3  Root volume`
3. Change the **8** to `30`
4. The storage type should already show **gp3** -- leave it as is

> **Screenshot:** The storage row shows:
> - Size field (change from 8 to 30)
> - Volume type dropdown (leave as gp3)
> - Encrypted toggle
>
> After changing to 30, you will see "30 GiB gp3" confirmed.

> **Why gp3?**
> gp3 is AWS General Purpose SSD storage.  It is faster and cheaper than the older gp2 type.
> 30 GB is the free tier maximum.

---

## Section 7: Launch!

1. Review the **Summary** panel on the right side of the page
   - Number of instances: 1
   - Software Image (AMI): Amazon Linux 2023
   - Instance type: t3.micro
   - Key pair: dev-example-key
2. Click the orange **Launch instance** button

> **Screenshot:** A green success banner appears at the top:
> "Successfully initiated launch of instance (i-0abc1234...)"
> Below it is a blue link to the instance ID.

3. Click the instance ID link (it starts with `i-`)

---

## Watch Your Instance Start

> **Screenshot:** You are now on the **Instances** list page.
> Your new instance is listed.  The **Instance state** column shows:
> - `Pending` -- AWS is setting it up (orange dot)
> - `Running` -- the server is live (green dot) -- takes about 1-2 minutes

4. Click the **refresh** button (circular arrow icon) every 30 seconds
5. Wait until the state shows **Running** with a green dot

---

## Explore the Instance Details

With your instance selected (checkbox checked), look at the details panel at the bottom of the page.

> **Screenshot:** The bottom panel has several tabs: Details, Security, Networking, Storage.

Explore the **Details** tab and find:
| Field | What It Means |
|-------|--------------|
| **Instance ID** | Unique ID AWS assigned to your server |
| **Public IPv4 address** | Your server's internet-facing IP |
| **Private IPv4 address** | IP inside your VPC (only reachable internally) |
| **Instance state** | Current status |
| **Instance type** | t3.micro |
| **AMI ID** | The image that was used to build this server |
| **VPC ID** | The virtual network this server lives in |
| **Subnet ID** | The specific subnet within the VPC |

Click the **Networking** tab and find:
| Field | What It Means |
|-------|--------------|
| **Public IPv4 DNS** | A DNS hostname for the public IP |
| **Security groups** | The firewall rules attached to this instance |

---

## Delete the Instance

You created this instance to learn the console.  Now delete it so it does not cost money.
Terraform will recreate everything for you with code shortly.

1. Check the checkbox next to your instance
2. Click **Instance state** in the top toolbar
3. Click **Terminate (delete) instance**

> **Screenshot:** A confirmation popup appears asking you to confirm termination.
> The warning says: "Are you sure you want to terminate these instances? This action cannot be undone."

4. Click the orange **Terminate** button

> **Screenshot:** The Instance state changes to `Shutting down` (orange dot), then eventually `Terminated` (grey dot).
> A terminated instance disappears from the list after a few minutes.

---

## What You Just Learned

You manually configured every component that makes up a running EC2 server:

```
AMI          →  Operating System
Instance Type →  CPU + Memory
Key Pair      →  SSH Access
Security Group →  Firewall Rules
Storage       →  Hard Drive
```

In the next steps you will define all of these in Terraform code -- so you can create them
in seconds with a single command instead of clicking through 7 screens.

---

**Next:** [03 - Provider Setup](03-provider-setup.md)
