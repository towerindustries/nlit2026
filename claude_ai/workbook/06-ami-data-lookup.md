# AMI Data Lookup

## What is an AMI?

An **AMI (Amazon Machine Image)** is a pre-built snapshot of an operating system.
When you launch an EC2 instance, AWS copies the AMI onto your instance's disk and boots from it.

Think of it like a USB drive with the OS pre-installed.

---

## The Problem with Hard-Coded AMI IDs

In the GUI walkthrough, AWS picked an AMI for you automatically.
If you had hard-coded that AMI ID into Terraform it would look like this:

```
ami = "ami-0ea87431b78a82070"  # Hard-coded -- BAD practice
```

Problems with this approach:
- AMI IDs are **region-specific** -- this ID only works in `us-east-1`
- Amazon publishes **new AMIs** every few weeks with security patches
- Hard-coded IDs get stale and eventually break

---

## The Solution: Data Sources

Terraform **data sources** let you query live information from AWS at plan time.
Instead of hard-coding an AMI ID, you ask AWS: "What is the latest Amazon Linux 2023 AMI?"

---

## Create the File

```
touch data.tf
```

---

## The Data Block

```
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
```

---

## Breaking It Down

### `data "aws_ami" "amazon_linux_2023"`
Unlike a `resource` block which **creates** something, a `data` block **reads** existing information.

- `data` -- this is a read-only query, nothing is created
- `"aws_ami"` -- the type of thing being queried
- `"amazon_linux_2023"` -- Terraform's internal label for this data source

### `most_recent = true`
If the filters match multiple AMIs, return the newest one.
Amazon publishes new AMI versions regularly.  This ensures you always get a patched, up-to-date image.

### `owners = ["amazon"]`
Only return AMIs that Amazon itself published.
This prevents accidentally using a community AMI from an untrusted source.

> The owner ID for Amazon is the string `"amazon"`.
> For third-party AMIs you would use a numeric account ID like `"099720109477"` (Canonical/Ubuntu).

### `filter { }` blocks
Filters narrow down which AMI is returned.

**Name filter:**
```
filter {
  name   = "name"
  values = ["al2023-ami-*-x86_64"]
}
```
- `al2023-ami-*-x86_64` uses a wildcard (`*`) to match any Amazon Linux 2023 x86_64 AMI
- Examples of matching AMI names:
  - `al2023-ami-2023.6.20250101.1-kernel-6.1-x86_64`
  - `al2023-ami-2023.5.20241101.0-kernel-6.1-x86_64`

**State filter:**
```
filter {
  name   = "state"
  values = ["available"]
}
```
Only return AMIs that are fully available (not deprecated, not failed).

---

## How to Reference It

In your `compute.tf` (coming next), you will use the data source result like this:

```
ami = data.aws_ami.amazon_linux_2023.id
```

- `data` -- tells Terraform this is from a data source
- `aws_ami` -- the resource type
- `amazon_linux_2023` -- the label you gave it
- `.id` -- the AMI ID returned by AWS

---

## Verify the Lookup Manually (Optional)

You can see the same AMI lookup using the AWS CLI:

```
aws ec2 describe-images \
  --region us-east-1 \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" \
            "Name=state,Values=available" \
  --query "Images | sort_by(@, &CreationDate)[-1].{Name:Name,ImageId:ImageId}" \
  --output table
```

Expected output:
```
----------------------------------------------------------------------
|                         DescribeImages                             |
+-----------------------------+--------------------------------------+
|          ImageId            |               Name                   |
+-----------------------------+--------------------------------------+
|  ami-0abc1234def56789a      |  al2023-ami-2023.6.20250101.1-...   |
+-----------------------------+--------------------------------------+
```

The `ImageId` here is what Terraform will use when you run `terraform apply`.

---

## AWS Console: Where to Find AMIs

In the AWS Console:
```
EC2 → Images → AMIs
```

To browse public Amazon AMIs:
1. In the left sidebar click **AMIs**
2. Change the filter at the top from **Owned by me** to **Public images**
3. In the search bar type `al2023-ami` and press Enter
4. Sort by **Creation date** descending to see the newest

> **Screenshot:** The AMI list shows columns:
> AMI ID | Name | Source | Owner | Visibility | Status | Creation date
>
> The AMI IDs look like: `ami-0abc1234ef567890a`
> They are region-specific -- the same AMI has a different ID in each AWS region.

---

**Next:** [07 - Compute (EC2)](07-compute.md)
