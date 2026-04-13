

```
aws ec2 describe-images \
  --region us-east-1 \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*-x86_64" \
            "Name=state,Values=available" \
  --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
  --output text
```