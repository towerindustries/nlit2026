# Environment Setup

Your development environment runs inside **GitHub Codespaces** -- a cloud-based VS Code editor that already has all the tools installed.

---

## Launch Your Codespace

1. Open your browser and go to the class repository on GitHub
2. Click the green **`< > Code`** button
3. Click the **Codespaces** tab
4. Click the **`+`** button to create a new Codespace

> **Screenshot:** You will see a loading screen that says "Setting up your codespace".
> This takes **5-10 minutes** on first launch.  This is normal -- ignore any pop-up notifications.

---

## What Gets Installed Automatically

The Codespace sets up the following tools for you:

| Tool | Purpose |
|------|---------|
| **Terraform** | Creates and manages AWS infrastructure |
| **AWS CLI** | Command-line interface for Amazon Web Services |
| **GitHub CLI** | Used for authentication |
| **VS Code** | The editor you are working in right now |

---

## Verify Your Tools

Once the Codespace finishes loading, open the terminal:

- **Menu:** View → Terminal
- **Keyboard shortcut:** `` Ctrl + ` ``

Run the following commands to confirm everything is installed:

### Check Terraform
```
terraform version
```
Expected output:
```
Terraform v1.x.x
on linux_amd64
```

### Check AWS CLI
```
aws --version
```
Expected output:
```
aws-cli/2.x.x Python/3.x.x Linux/...
```

---

## Set Up Your Lab Directory

Create a fresh working directory for your Terraform code:

```
mkdir /opt/lab_env
cd /opt/lab_env
```

All your Terraform files will go into this folder.

---

## Enable Dark Mode (Optional)

1. Click the gear icon in the **lower-left corner** of the Codespace window
2. Click **Settings**
3. Type `dark` in the search bar
4. Under **Commonly Used**, select **Dark (Visual Studio)**

---

## Log In to AWS

Your AWS credentials are provided via Codespace environment secrets.  Authenticate with:

```
aws login --remote
```

Follow the prompts:
1. When asked for **AWS Region**, type `us-east-1` and press Enter
2. A URL will be displayed in the terminal
3. Hold **Ctrl** and **right-click** the URL, then choose **Open Link**
4. Select your AWS account in the browser
5. Copy the **verification code** shown in the browser
6. Paste it back into the terminal and press Enter

### Test Authentication
```
aws s3 ls
```

This lists any S3 buckets in your account.  An empty result (no error) means you are logged in successfully.

---

## Find Your Public IP

You need your home/office IP to restrict access to your server later.

1. Open a browser tab
2. Go to `https://whatismyip.com`
3. Copy the **IPv4 address** shown (example: `68.4.12.99`)
4. Save it somewhere -- you will use it in the security group step

> **Note:** You will add `/32` to the end when entering it in Terraform.
> So `68.4.12.99` becomes `68.4.12.99/32`

---

**Next:** [02 - AWS GUI Walkthrough](02-aws-gui-walkthrough.md)
