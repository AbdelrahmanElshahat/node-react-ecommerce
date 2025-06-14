#!/bin/bash

# Script to test the file upload functionality

echo "🔍 Testing file upload to AWS S3..."

# Get the name of one of the backend pods
BACKEND_POD=$(kubectl get pods -n ecommerce -l app=backend -o jsonpath='{.items[0].metadata.name}')

if [ -z "$BACKEND_POD" ]; then
    echo "❌ No backend pods found!"
    exit 1
fi

echo "✅ Using backend pod: $BACKEND_POD"

# Check the AWS configuration in the pod
echo "🔍 Checking AWS configuration in the pod..."
kubectl exec -n ecommerce $BACKEND_POD -- env | grep AWS

# Create a test file
TEST_FILE="/tmp/test-upload-$RANDOM.jpg"
echo "📝 Creating test file: $TEST_FILE"
cp ../uploads/1747843604960.jpg $TEST_FILE 2>/dev/null || {
    echo "❌ Failed to copy test file. Creating a simple file instead."
    echo "This is a test file" > $TEST_FILE
}

# Test the upload
echo "🚀 Testing upload to backend API..."
curl -v -F "image=@$TEST_FILE" http://$(kubectl get ingress -n ecommerce ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/api/uploads || {
    echo "❌ Upload failed through ingress. Trying direct pod access..."
    
    # Forward port from the backend pod
    kubectl port-forward -n ecommerce $BACKEND_POD 5000:5000 &
    PF_PID=$!
    
    # Wait for port-forwarding to be established
    sleep 3
    
    # Test the upload via port-forwarding
    curl -v -F "image=@$TEST_FILE" http://localhost:5000/api/uploads
    
    # Clean up port-forwarding
    kill $PF_PID 2>/dev/null || true
    wait $PF_PID 2>/dev/null || true
}

# Clean up test file
rm -f $TEST_FILE

echo "✅ Test completed."
