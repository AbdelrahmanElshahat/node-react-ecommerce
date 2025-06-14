#!/bin/bash

# Build and Push Docker Images to DigitalOcean Container Registry
# This script builds your frontend and backend images and pushes them to DO registry

set -e  # Exit on any error

# Configuration
REGISTRY_NAME="ecommerce-registry"  # Change this to your preferred registry name
BACKEND_IMAGE="ecommerce-backend"
FRONTEND_IMAGE="ecommerce-frontend"
TAG="latest"

echo "🚀 Building and pushing Docker images to DigitalOcean Container Registry"
echo ""

# Check if doctl is authenticated
echo "🔍 Checking authentication..."
if ! doctl auth list &>/dev/null; then
    echo "❌ Please authenticate with DigitalOcean first: doctl auth init"
    exit 1
fi

# Create container registry if it doesn't exist
echo "📦 Creating container registry..."
doctl registry create $REGISTRY_NAME --region nyc3 || echo "Registry might already exist"

# Login to the registry
echo "🔐 Logging into container registry..."
doctl registry login

# Get registry endpoint
REGISTRY_ENDPOINT=$(doctl registry get $REGISTRY_NAME --format Endpoint --no-header)
echo "📍 Registry endpoint: $REGISTRY_ENDPOINT"

# Build backend image
echo ""
echo "🔨 Building backend image..."
docker build -f Dockerfile.backend -t $BACKEND_IMAGE:$TAG ./backend/

# Tag for registry
docker tag $BACKEND_IMAGE:$TAG $REGISTRY_ENDPOINT/$BACKEND_IMAGE:$TAG

# Build frontend image
echo ""
echo "🔨 Building frontend image..."
docker build -f Dockerfile.frontend -t $FRONTEND_IMAGE:$TAG ./frontend/

# Tag for registry  
docker tag $FRONTEND_IMAGE:$TAG $REGISTRY_ENDPOINT/$FRONTEND_IMAGE:$TAG

# Push images
echo ""
echo "📤 Pushing backend image..."
docker push $REGISTRY_ENDPOINT/$BACKEND_IMAGE:$TAG

echo ""
echo "📤 Pushing frontend image..."
docker push $REGISTRY_ENDPOINT/$FRONTEND_IMAGE:$TAG

echo ""
echo "✅ Images pushed successfully!"
echo ""
echo "📋 Image URLs:"
echo "   Backend:  $REGISTRY_ENDPOINT/$BACKEND_IMAGE:$TAG"
echo "   Frontend: $REGISTRY_ENDPOINT/$FRONTEND_IMAGE:$TAG"
echo ""
echo "📝 Next steps:"
echo "1. Update your Kubernetes manifests with these image URLs"
echo "2. Deploy to your Kubernetes cluster"
echo ""

# Save image URLs to a file for later use
cat > k8s/image-urls.txt << EOF
BACKEND_IMAGE=$REGISTRY_ENDPOINT/$BACKEND_IMAGE:$TAG
FRONTEND_IMAGE=$REGISTRY_ENDPOINT/$FRONTEND_IMAGE:$TAG
EOF

echo "💾 Image URLs saved to k8s/image-urls.txt"
