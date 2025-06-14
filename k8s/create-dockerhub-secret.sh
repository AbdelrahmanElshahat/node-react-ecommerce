#!/bin/bash

# Script to create a Docker Hub secret for Kubernetes
# This script will create the dockerhub-secret in the ecommerce namespace

set -e  # Exit on any error

echo "🔐 Creating Docker Hub secret for Kubernetes"
echo ""
echo "To create a Docker Hub access token (recommended over using your password):"
echo "1. Go to https://hub.docker.com/settings/security"
echo "2. Click 'New Access Token'"
echo "3. Give it a description like 'Kubernetes'"
echo "4. Select 'Read & Write' permissions"
echo "5. Click 'Generate'"
echo "6. Copy the token to use in this script"
echo ""

# Prompt for Docker Hub credentials
read -p "Enter your Docker Hub username [elshahat20]: " DOCKER_USERNAME
DOCKER_USERNAME=${DOCKER_USERNAME:-elshahat20}

read -sp "Enter your Docker Hub token (not your password): " DOCKER_TOKEN
echo ""
read -p "Enter your Docker Hub email: " DOCKER_EMAIL

# Check if namespace exists, create if it doesn't
if ! kubectl get namespace ecommerce &>/dev/null; then
  echo "Creating ecommerce namespace..."
  kubectl create namespace ecommerce
fi

# Delete the secret if it already exists
kubectl delete secret dockerhub-secret --namespace=ecommerce 2>/dev/null || true

# Create the secret
echo "Creating Docker Hub secret..."
kubectl create secret docker-registry dockerhub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username="$DOCKER_USERNAME" \
  --docker-password="$DOCKER_TOKEN" \
  --docker-email="$DOCKER_EMAIL" \
  --namespace=ecommerce

echo ""
echo "✅ Docker Hub secret created successfully!"
echo "You can now deploy your application with 'kubectl apply -f backend.yaml'"
