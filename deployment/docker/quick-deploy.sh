#!/bin/bash

# Quick Start Deployment Script for DigitalOcean Kubernetes
# This script automates the entire deployment process

set -e

echo "🚀 Quick Start: Deploy E-commerce App to DigitalOcean Kubernetes"
echo "================================================================"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "\n${BLUE}📋 Step $1: $2${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check prerequisites
print_step "1" "Checking Prerequisites"

# Check if required tools are installed
REQUIRED_TOOLS=("docker" "kubectl" "doctl")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        print_error "$tool is not installed"
        exit 1
    fi
done
print_success "All required tools are installed"

# Check if doctl is authenticated
if ! doctl auth list &>/dev/null; then
    print_error "Please authenticate with DigitalOcean first:"
    echo "doctl auth init"
    exit 1
fi
print_success "DigitalOcean CLI is authenticated"

# Prompt for configuration
print_step "2" "Configuration Setup"

read -p "Enter your domain name (e.g., myapp.com): " DOMAIN
read -p "Enter your email for SSL certificates: " EMAIL
read -p "Enter cluster name [ecommerce-k8s]: " CLUSTER_NAME
CLUSTER_NAME=${CLUSTER_NAME:-ecommerce-k8s}

read -p "Enter registry name [ecommerce-registry]: " REGISTRY_NAME
REGISTRY_NAME=${REGISTRY_NAME:-ecommerce-registry}

echo ""
echo "📋 Configuration Summary:"
echo "   Domain: $DOMAIN"
echo "   Email: $EMAIL"
echo "   Cluster: $CLUSTER_NAME"
echo "   Registry: $REGISTRY_NAME"
echo ""

read -p "Continue with this configuration? (y/N): " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\nOperation cancelled."
    exit 0
fi

# Step 3: Create Kubernetes cluster
print_step "3" "Creating Kubernetes Cluster"
if doctl kubernetes cluster get $CLUSTER_NAME &>/dev/null; then
    print_warning "Cluster $CLUSTER_NAME already exists"
else
    echo "Creating cluster (this may take 5-10 minutes)..."
    doctl kubernetes cluster create $CLUSTER_NAME \
      --region nyc1 \
      --node-pool "name=worker-pool;size=s-2vcpu-4gb;count=3;auto-scale=true;min-nodes=2;max-nodes=5" \
      --version 1.28.2-do.0 \
      --tag ecommerce
    
    print_success "Cluster created successfully"
fi

# Configure kubectl
doctl kubernetes cluster kubeconfig save $CLUSTER_NAME
print_success "kubectl configured"

# Step 4: Update configuration files
print_step "4" "Updating Configuration Files"

# Update configmap with domain
sed -i "s|REACT_APP_API_URL: \"https://your-domain.com\"|REACT_APP_API_URL: \"https://$DOMAIN\"|g" k8s/configmap-secret.yaml

# Update cert-manager with email
sed -i "s|email: your-email@example.com|email: $EMAIL|g" k8s/cert-manager.yaml

# Update ingress with domain
sed -i "s|host: your-domain.com|host: $DOMAIN|g" k8s/ingress.yaml
sed -i "s|- your-domain.com|- $DOMAIN|g" k8s/ingress.yaml

print_success "Configuration files updated"

# Step 5: Build and push images
print_step "5" "Building and Pushing Docker Images"

# Create registry
doctl registry create $REGISTRY_NAME --region nyc3 || echo "Registry might already exist"
doctl registry login

# Get registry endpoint
REGISTRY_ENDPOINT=$(doctl registry get $REGISTRY_NAME --format Endpoint --no-header)

# Build and push backend
echo "Building backend image..."
docker build -f Dockerfile.backend -t ecommerce-backend:latest ./backend/
docker tag ecommerce-backend:latest $REGISTRY_ENDPOINT/ecommerce-backend:latest
docker push $REGISTRY_ENDPOINT/ecommerce-backend:latest

# Build and push frontend
echo "Building frontend image..."
docker build -f Dockerfile.frontend -t ecommerce-frontend:latest ./frontend/
docker tag ecommerce-frontend:latest $REGISTRY_ENDPOINT/ecommerce-frontend:latest
docker push $REGISTRY_ENDPOINT/ecommerce-frontend:latest

print_success "Docker images built and pushed"

# Step 6: Update Kubernetes manifests with image URLs
print_step "6" "Updating Kubernetes Manifests"

sed -i "s|image: ecommerce-backend:latest.*|image: $REGISTRY_ENDPOINT/ecommerce-backend:latest|g" k8s/backend.yaml
sed -i "s|image: ecommerce-frontend:latest.*|image: $REGISTRY_ENDPOINT/ecommerce-frontend:latest|g" k8s/frontend.yaml

print_success "Kubernetes manifests updated"

# Step 7: Deploy to Kubernetes
print_step "7" "Deploying to Kubernetes"

cd k8s
./deploy.sh

print_success "Application deployed to Kubernetes"

# Step 8: Get deployment information
print_step "8" "Deployment Information"

echo "Waiting for LoadBalancer IP assignment..."
sleep 30

LB_IP=$(kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")

echo ""
print_success "🎉 Deployment Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Configure DNS:"
echo "   - Create A record: $DOMAIN → $LB_IP"
echo "   - Create CNAME record: www.$DOMAIN → $DOMAIN"
echo ""
echo "2. Wait for SSL certificate (5-10 minutes)"
echo ""
echo "3. Test your application:"
echo "   - Website: https://$DOMAIN"
echo "   - API Health: https://$DOMAIN/api/health"
echo ""
echo "📊 Monitoring Commands:"
echo "   kubectl get pods -n ecommerce"
echo "   kubectl logs -f deployment/backend-deployment -n ecommerce"
echo "   ./test-ingress.sh"
echo ""
echo "🔧 Useful Information:"
echo "   Cluster: $CLUSTER_NAME"
echo "   Registry: $REGISTRY_ENDPOINT"
echo "   LoadBalancer IP: $LB_IP"
