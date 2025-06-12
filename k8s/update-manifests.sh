#!/bin/bash

# Update Kubernetes manifests with actual Docker image URLs
# Run this script after building and pushing your images

set -e

# Source the image URLs
if [ ! -f "image-urls.txt" ]; then
    echo "❌ image-urls.txt not found. Please run build-and-push.sh first."
    exit 1
fi

source image-urls.txt

echo "🔄 Updating Kubernetes manifests with image URLs..."

# Update backend deployment
echo "📝 Updating backend.yaml..."
sed -i "s|image: ecommerce-backend:latest.*|image: $BACKEND_IMAGE|g" backend.yaml

# Update frontend deployment  
echo "📝 Updating frontend.yaml..."
sed -i "s|image: ecommerce-frontend:latest.*|image: $FRONTEND_IMAGE|g" frontend.yaml

echo "✅ Kubernetes manifests updated successfully!"
echo ""
echo "🔍 Updated images:"
echo "   Backend:  $BACKEND_IMAGE"
echo "   Frontend: $FRONTEND_IMAGE"
