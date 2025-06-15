#!/bin/bash

# Script to build and push Frontend Docker image to Docker Hub

set -e  # Exit on any error

echo "🐳 Building and pushing Frontend Docker image to Docker Hub"
echo ""

# Configuration
IMAGE_NAME="elshahat20/my-app"
TAG="frontlatest"
DOCKERFILE_PATH="/home/elshahat/Documents/project/node-react-ecommerce/frontend/Dockerfile"
CONTEXT_PATH="/home/elshahat/Documents/project/node-react-ecommerce/frontend"

# Full image name
FULL_IMAGE_NAME="$IMAGE_NAME:$TAG"

# Check if Docker is running
if ! docker info &>/dev/null; then
  echo "❌ Docker is not running."
  echo "Please start Docker and try again."
  exit 1
fi

# Build the image
echo "🔨 Building Frontend Docker image: $FULL_IMAGE_NAME"
docker build -t "$FULL_IMAGE_NAME" -f "$DOCKERFILE_PATH" "$CONTEXT_PATH"

# Verify build success
if [ $? -ne 0 ]; then
  echo "❌ Docker build failed."
  exit 1
fi

echo "✅ Frontend Docker image built successfully."

# Push to Docker Hub
echo "📤 Pushing frontend image to Docker Hub..."
docker push "$FULL_IMAGE_NAME"

# Verify push success
if [ $? -ne 0 ]; then
  echo "❌ Failed to push frontend image to Docker Hub."
  exit 1
fi

echo "✅ Frontend image pushed successfully to Docker Hub: $FULL_IMAGE_NAME"
echo ""
echo "To use this image in your Kubernetes deployment:"
echo "1. Make sure your frontend.yaml file has the correct image: $FULL_IMAGE_NAME"
echo "2. Deploy with: kubectl apply -f frontend.yaml"