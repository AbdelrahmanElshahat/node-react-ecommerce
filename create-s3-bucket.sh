#!/bin/bash

# Create S3 bucket with public access
aws s3api create-bucket \
  --bucket amazona \
  --region eu-north-1 \
  --create-bucket-configuration LocationConstraint=eu-north-1

# Set bucket policy to allow public read access
cat > bucket-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::amazona/*"
    }
  ]
}
EOF

# Apply the bucket policy
aws s3api put-bucket-policy --bucket amazona --policy file://bucket-policy.json

# Enable static website hosting (optional for serving files directly)
aws s3 website s3://amazona/ --index-document index.html

echo "S3 bucket 'amazona' created successfully in eu-north-1 region with public read access."