# AWS S3 Setup for Amazona E-commerce

This guide explains how to set up AWS S3 for image uploads in the Amazona e-commerce application using the AWS Management Console.

## Step 1: Create S3 Bucket

1. Go to the [Amazon S3 Console](https://s3.console.aws.amazon.com/)
2. Click "Create bucket"
3. Enter "amazona" as the bucket name
4. Select "eu-north-1" (Stockholm) as the region
5. Under "Block Public Access settings", uncheck "Block all public access" (Note: Only do this for files that need to be publicly accessible)
6. Acknowledge the warning about making the bucket public
7. Keep other settings as default and click "Create bucket"

## Step 2: Configure Bucket for Public Access

1. Click on your newly created "amazona" bucket
2. Go to the "Permissions" tab
3. Scroll down to "Bucket policy" and click "Edit"
4. Paste the following policy (this allows public read access to all objects):

```json
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
```

5. Click "Save changes"

## Step 3: Create IAM User and Access Keys

1. Go to the [IAM Console](https://console.aws.amazon.com/iam/)
2. In the navigation pane, choose "Users" and then "Add users"
3. Enter "amazona-app-user" as the user name
4. Select "Access key - Programmatic access" as the access type
5. Click "Next: Permissions"
6. Click "Attach existing policies directly"
7. Click "Create policy"
8. In the new tab that opens, select the "JSON" tab
9. Paste the following policy:

```json
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
```

10. Click "Next: Tags" (no tags needed)
11. Click "Next: Review"
12. Name the policy "AmazonaS3Access" and click "Create policy"
13. Go back to the user creation tab and refresh the policy list
14. Search for and select your "AmazonaS3Access" policy
15. Click "Next: Tags" (no tags needed)
16. Click "Next: Review"
17. Click "Create user"
18. **IMPORTANT**: Download the CSV file which contains the Access Key ID and Secret Access Key (not username and password). You will not be able to see the Secret Access Key again after this step.

## Step 4: Configure Your Application

1. Create a `.env` file in the root directory of your project:

```
PORT=5000
MONGODB_URL=mongodb://localhost/amazona
JWT_SECRET=somethingsecret
PAYPAL_CLIENT_ID=sb
accessKeyId=YOUR_ACCESS_KEY_ID
secretAccessKey=YOUR_SECRET_ACCESS_KEY
```

2. Replace `YOUR_ACCESS_KEY_ID` and `YOUR_SECRET_ACCESS_KEY` with the values from Step 3

3. Update your config.js file to use these environment variables:

```javascript
import dotenv from 'dotenv';

dotenv.config();

export default {
  PORT: process.env.PORT || 5000,
  MONGODB_URL: process.env.MONGODB_URL || 'mongodb://localhost/amazona',
  JWT_SECRET: process.env.JWT_SECRET || 'somethingsecret',
  PAYPAL_CLIENT_ID: process.env.PAYPAL_CLIENT_ID || 'sb',
  accessKeyId: process.env.accessKeyId || 'YOUR_ACCESS_KEY_ID',
  secretAccessKey: process.env.secretAccessKey || 'YOUR_SECRET_ACCESS_KEY',
};
```

## Step 5: Implement S3 Upload in Your Application

Update your `routes/uploadRoute.js` file to use AWS S3:

```javascript
import express from 'express';
import multer from 'multer';
import multerS3 from 'multer-s3';
import aws from 'aws-sdk';
import config from '../config.js';

const router = express.Router();

// Configure AWS
aws.config.update({
  accessKeyId: config.accessKeyId,
  secretAccessKey: config.secretAccessKey,
  region: 'eu-north-1',
});

const s3 = new aws.S3();

const storageS3 = multerS3({
  s3,
  bucket: 'amazona',
  acl: 'public-read',
  contentType: multerS3.AUTO_CONTENT_TYPE,
  key(req, file, cb) {
    cb(null, `${Date.now().toString()}-${file.originalname}`);
  },
});

const uploadS3 = multer({ storage: storageS3 });

router.post('/s3', uploadS3.single('image'), (req, res) => {
  res.send(req.file.location);
});

export default router;
```

## Security Considerations

- Never commit your AWS credentials to version control
- Consider using IAM roles for EC2 instances in production
- Regularly rotate your access keys
- Use bucket policies that restrict access to only what's necessary