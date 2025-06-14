#!/bin/bash

# Script to check if products are accessible through the API

echo "🔍 Testing product API access..."

# Make request to the products API via ingress
echo "📊 Querying products API through ingress..."
curl -s http://159.203.156.201/api/products | jq

echo ""
echo "✅ Verification complete."
echo ""
echo "If you see products listed above, it means:"
echo "1. Products are successfully loaded in the MongoDB database"
echo "2. The backend API is correctly serving product data"
echo ""
echo "To access the full application, open a browser and go to:"
echo "- http://159.203.156.201"
echo "- https://amazona.com (if you've added it to your hosts file)"
echo ""
echo "For uploading product images, make sure AWS S3 credentials are correctly configured"
echo "in your Kubernetes secrets."
