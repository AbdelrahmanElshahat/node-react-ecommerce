#!/bin/bash

# Script to install ArgoCD on Kubernetes cluster
# This script installs ArgoCD using the official installation method

set -e

echo "🚀 Installing ArgoCD on Kubernetes cluster"
echo "=========================================="

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "Please check your kubeconfig and cluster connection"
    exit 1
fi

echo "✅ Kubernetes cluster is accessible"

# Create ArgoCD namespace
echo "📦 Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "⬇️  Installing ArgoCD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for ArgoCD components to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-dex-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-redis -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-repo-server -n argocd
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "✅ ArgoCD installation completed!"

# Get initial admin password
echo ""
echo "🔐 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "🎉 ArgoCD Installation Summary:"
echo "================================"
echo "✅ ArgoCD is installed in 'argocd' namespace"
echo "✅ Admin username: admin"
echo "✅ Admin password: $ARGOCD_PASSWORD"
echo ""
echo "📋 Next steps:"
echo "1. Expose ArgoCD server (choose one method):"
echo ""
echo "   Method 1 - Port Forward (for testing):"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Then access: https://localhost:8080"
echo ""
echo "   Method 2 - LoadBalancer Service:"
echo "   kubectl patch svc argocd-server -n argocd -p '{\"spec\": {\"type\": \"LoadBalancer\"}}'"
echo ""
echo "   Method 3 - Ingress (recommended for production):"
echo "   Create an ingress resource to expose ArgoCD"
echo ""
echo "2. Login with:"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "3. Install ArgoCD CLI (optional):"
echo "   curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
echo "   sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd"
echo ""

# Show pod status
echo "📊 ArgoCD Pods Status:"
kubectl get pods -n argocd

echo ""
echo "🔍 ArgoCD Services:"
kubectl get svc -n argocd
