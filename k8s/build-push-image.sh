#!/bin/bash

# Script to build and push Docker image to Docker Hub
# This script builds and pushes your backend Docker image to Docker Hub

set -e  # Exit on any error

echo "🐳 Building and pushing Docker image to Docker Hub"
echo ""

# Configuration (customize these variables)
IMAGE_NAME="elshahat20/my-app"
TAG="itiBack-1.0.4"
DOCKERFILE_PATH="/home/elshahat/Documents/project/node-react-ecommerce/Dockerfile"
CONTEXT_PATH="/home/elshahat/Documents/project/node-react-ecommerce"

# Full image name
FULL_IMAGE_NAME="$IMAGE_NAME:$TAG"

# Check if Docker is running
if ! docker info &>/dev/null; then
  echo "❌ Docker is not running."
  echo "Please start Docker and try again."
  exit 1
fi

# Check if logged in to Docker Hub
if ! docker info | grep -q "Username"; then
  echo "You are not logged in to Docker Hub."
  echo "Please login with 'docker login' first."
  docker login
fi

# Build the image
echo "🔨 Building Docker image: $FULL_IMAGE_NAME"
docker build -t "$FULL_IMAGE_NAME" -f "$DOCKERFILE_PATH" "$CONTEXT_PATH"

# Verify build success
if [ $? -ne 0 ]; then
  echo "❌ Docker build failed."
  exit 1
fi

echo "✅ Docker image built successfully."

# Push to Docker Hub
echo "📤 Pushing image to Docker Hub..."
docker push "$FULL_IMAGE_NAME"

# Verify push success
if [ $? -ne 0 ]; then
  echo "❌ Failed to push image to Docker Hub."
  exit 1
fi

echo "✅ Image pushed successfully to Docker Hub: $FULL_IMAGE_NAME"
echo ""
echo "To use this image in your Kubernetes deployment:"
echo "1. Make sure your backend.yaml file has the correct image: $FULL_IMAGE_NAME"
echo "2. Make sure your dockerhub-secret is configured correctly"
echo "3. Deploy with: kubectl apply -f backend.yaml"
