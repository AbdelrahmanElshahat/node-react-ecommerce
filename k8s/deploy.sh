#!/bin/bash

# Complete deployment script for E-commerce application on DigitalOcean Kubernetes
# This script deploys all components needed for the ecommerce application

set -e  # Exit on any error

echo "🚀 Deploying E-commerce Application to Kubernetes..."
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if kubectl is configured
print_status "Checking kubectl configuration..."
if ! kubectl cluster-info &>/dev/null; then
    print_error "kubectl is not configured or cluster is not accessible"
    print_warning "Please run: doctl kubernetes cluster kubeconfig save <cluster-name>"
    exit 1
fi
print_success "kubectl is configured"

# Check for required tools
print_status "Checking required tools..."
for tool in kubectl helm; do
    if ! command -v $tool &>/dev/null; then
        print_error "$tool is not installed"
        exit 1
    fi
done
print_success "All required tools are available"

# Install NGINX Ingress Controller
print_status "Checking for NGINX Ingress Controller..."
if ! kubectl get namespace ingress-nginx &>/dev/null; then
    print_status "Installing NGINX Ingress Controller..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
    
    print_status "Waiting for ingress controller to be ready..."
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    print_success "NGINX Ingress Controller installed"
else
    print_success "NGINX Ingress Controller already exists"
fi

# Install cert-manager for SSL certificates
print_status "Checking for cert-manager..."
if ! kubectl get namespace cert-manager &>/dev/null; then
    print_status "Installing cert-manager..."
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
    
    print_status "Waiting for cert-manager to be ready..."
    kubectl wait --namespace cert-manager \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    print_success "cert-manager installed"
else
    print_success "cert-manager already exists"
fi

echo ""
print_status "Deploying application components..."

# Apply manifests in the correct order
print_status "Creating namespace..."
kubectl apply -f namespace.yaml

print_status "Creating SSL certificate issuers..."
kubectl apply -f cert-manager.yaml

print_status "Creating ConfigMap and Secrets..."
kubectl apply -f configmap-secret.yaml

print_status "Deploying MongoDB..."
kubectl apply -f mongodb.yaml

print_status "Waiting for MongoDB to be ready..."
kubectl wait --namespace ecommerce \
    --for=condition=ready pod \
    --selector=app=mongodb \
    --timeout=300s

print_status "Deploying Backend API..."
kubectl apply -f backend.yaml

print_status "Waiting for Backend to be ready..."
kubectl wait --namespace ecommerce \
    --for=condition=ready pod \
    --selector=app=backend \
    --timeout=300s

print_status "Deploying Frontend..."
kubectl apply -f frontend.yaml

print_status "Waiting for Frontend to be ready..."
kubectl wait --namespace ecommerce \
    --for=condition=ready pod \
    --selector=app=frontend \
    --timeout=300s

print_status "Creating Ingress..."
kubectl apply -f ingress.yaml

echo ""
print_success "🎉 Deployment completed successfully!"
echo ""

# Display deployment status
print_status "Deployment Status:"
kubectl get pods -n ecommerce
echo ""
kubectl get services -n ecommerce
echo ""
kubectl get ingress -n ecommerce

echo ""
print_status "📋 Next Steps:"
echo "1. Point your domain to the LoadBalancer IP"
echo "2. Wait for SSL certificate to be issued (may take a few minutes)"
echo "3. Update your DNS records"
echo "4. Test your application"
echo ""

# Get LoadBalancer IP
LB_IP=$(kubectl get service -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
if [ "$LB_IP" != "pending" ] && [ ! -z "$LB_IP" ]; then
    print_success "🌐 LoadBalancer IP: $LB_IP"
    echo "   Point your domain DNS A record to this IP"
else
    print_warning "LoadBalancer IP is still being assigned. Check with:"
    echo "   kubectl get service -n ingress-nginx ingress-nginx-controller"
fi

echo ""
print_status "🔍 Useful monitoring commands:"
echo "   kubectl get pods -n ecommerce -w"
echo "   kubectl logs -f deployment/backend-deployment -n ecommerce"
echo "   kubectl logs -f deployment/frontend-deployment -n ecommerce"
echo "   kubectl describe ingress ecommerce-ingress -n ecommerce"

echo ""
print_status "📖 To check logs:"
echo "  kubectl logs -n ecommerce -l app=backend"
echo "  kubectl logs -n ecommerce -l app=frontend"
echo "  kubectl logs -n ecommerce -l app=mongodb"

echo ""
print_status "🗑️ To delete everything:"
echo "  kubectl delete namespace ecommerce"
