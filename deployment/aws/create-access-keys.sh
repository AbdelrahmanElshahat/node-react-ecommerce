#!/bin/bash

# Create IAM user for accessing S3
aws iam create-user --user-name amazona-app-user

# Create access policy for S3 bucket
cat > amazona-s3-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::amazona",
        "arn:aws:s3:::amazona/*"
      ]
    }
  ]
}
EOF

# Create policy
aws iam create-policy \
  --policy-name AmazonaS3Access \
  --policy-document file://amazona-s3-policy.json

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Attach policy to user
aws iam attach-user-policy \
  --user-name amazona-app-user \
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/AmazonaS3Access

# Create access key
aws iam create-access-key --user-name amazona-app-user

echo "Access keys created for user 'amazona-app-user'"
echo "IMPORTANT: Save the AccessKeyId and SecretAccessKey shown above. You won't be able to retrieve the secret key again."