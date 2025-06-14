# Understanding AWS Access Keys

When you create an IAM user in AWS with programmatic access, you receive:

1. **Access Key ID**: This is like a username for API access. It identifies your IAM user or role.

2. **Secret Access Key**: This is like a password for API access. It must be kept secure.

These are **NOT** the same as your AWS Console username and password. They are specifically for programmatic access to AWS services via API calls.

## How to Get Your Access Keys

1. After creating an IAM user with programmatic access, AWS will show you the Access Key ID and Secret Access Key **only once**.

2. You can download these as a CSV file. The CSV contains:
   - Access Key ID
   - Secret Access Key

3. If you lose your Secret Access Key, you cannot retrieve it. You must create a new access key and delete the old one.

## How to Use Access Keys in Your Application

In your `.env` file:
```
accessKeyId=YOUR_ACCESS_KEY_ID
secretAccessKey=YOUR_SECRET_ACCESS_KEY
```

These credentials allow your application to authenticate with AWS services like S3.

## Security Best Practices

- Never share your Secret Access Key
- Never commit access keys to version control
- Rotate access keys regularly
- Use IAM roles instead of access keys when possible (for EC2 instances, Lambda functions, etc.)