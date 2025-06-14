#!/bin/bash

# Script to check AWS SDK configuration in backend pod

echo "🔍 Checking AWS SDK configuration in backend pod..."

# Get a backend pod name
BACKEND_POD=$(kubectl get pods -n ecommerce -l app=backend -o jsonpath='{.items[0].metadata.name}')

if [ -z "$BACKEND_POD" ]; then
    echo "❌ No backend pods found!"
    exit 1
fi

echo "✅ Using backend pod: $BACKEND_POD"

# Create test script for AWS S3
cat <<EOF > test-aws.js
const AWS = require('aws-sdk');

// Configure AWS
AWS.config.update({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1'
});

// Test S3 connection
async function testS3() {
  console.log('Testing AWS S3 connection...');
  
  // Check environment variables
  console.log('AWS_ACCESS_KEY_ID:', process.env.AWS_ACCESS_KEY_ID ? '✓ Set' : '✗ Not set');
  console.log('AWS_SECRET_ACCESS_KEY:', process.env.AWS_SECRET_ACCESS_KEY ? '✓ Set' : '✗ Not set');
  console.log('AWS_REGION:', process.env.AWS_REGION || 'us-east-1 (default)');
  console.log('AWS_BUCKET_NAME:', process.env.AWS_BUCKET_NAME || '✗ Not set');
  
  const s3 = new AWS.S3();
  
  try {
    // List buckets to test credentials
    const listBuckets = await s3.listBuckets().promise();
    console.log('✅ Successfully connected to AWS S3');
    console.log('Available buckets:', listBuckets.Buckets.map(b => b.Name).join(', '));
    
    // If bucket name is provided, check if it exists
    if (process.env.AWS_BUCKET_NAME) {
      try {
        await s3.headBucket({ Bucket: process.env.AWS_BUCKET_NAME }).promise();
        console.log(\`✅ Bucket "\${process.env.AWS_BUCKET_NAME}" exists and is accessible\`);
      } catch (error) {
        console.error(\`❌ Bucket "\${process.env.AWS_BUCKET_NAME}" error: \${error.message}\`);
      }
    }
  } catch (error) {
    console.error('❌ AWS S3 connection failed:', error.message);
  }
}

testS3();
EOF

# Copy the script to the pod
echo "📦 Copying AWS test script to pod..."
kubectl cp test-aws.js ecommerce/$BACKEND_POD:/app/test-aws.js

# Execute the script in the pod
echo "🚀 Testing AWS SDK configuration..."
kubectl exec -n ecommerce $BACKEND_POD -- node /app/test-aws.js

# Clean up
rm test-aws.js

echo "✅ AWS SDK configuration check completed."
