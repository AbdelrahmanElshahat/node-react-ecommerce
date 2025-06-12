#!/bin/bash

# Cleanup script to remove all deployed resources
# Use this to completely remove the e-commerce application from your cluster

set -e

echo "🗑️  Cleaning up E-commerce Application Resources"
echo "=============================================="

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Confirmation prompt
echo -e "${RED}WARNING: This will delete all application resources!${NC}"
echo "This includes:"
echo "- All pods, services, and ingress"
echo "- MongoDB data (if not backed up)"
echo "- SSL certificates"
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
print_warning "Starting cleanup process..."

# Delete application resources
echo "🔧 Deleting application resources..."
kubectl delete namespace ecommerce --ignore-not-found=true

# Wait for namespace deletion
echo "⏳ Waiting for namespace deletion..."
kubectl wait --for=delete namespace/ecommerce --timeout=300s 2>/dev/null || true

# Optional: Remove cert-manager if not used by other applications
read -p "Remove cert-manager? (only if not used by other apps) (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔧 Removing cert-manager..."
    kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml --ignore-not-found=true
fi

# Optional: Remove NGINX ingress controller
read -p "Remove NGINX Ingress Controller? (only if not used by other apps) (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔧 Removing NGINX Ingress Controller..."
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml --ignore-not-found=true
fi

print_success "Cleanup completed!"

echo ""
echo "📋 Manual cleanup tasks:"
echo "1. Delete DigitalOcean Container Registry (if no longer needed)"
echo "   doctl registry delete <registry-name>"
echo ""
echo "2. Delete DigitalOcean Kubernetes cluster (if no longer needed)"
echo "   doctl kubernetes cluster delete <cluster-name>"
echo ""
echo "3. Remove local Docker images (optional)"
echo "   docker image prune -a"
