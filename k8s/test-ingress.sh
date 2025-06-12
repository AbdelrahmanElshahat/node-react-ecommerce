#!/bin/bash

# Test script for ingress configuration
# This script helps validate that the ingress is working correctly

echo "🔍 Testing Ingress Configuration..."

# Check if ingress controller is installed
echo "📋 Checking for ingress controller..."
kubectl get pods -n ingress-nginx 2>/dev/null || echo "⚠️  NGINX Ingress Controller not found. Install with:"
echo "   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml"

echo ""

# Check ingress status
echo "📋 Checking ingress status..."
kubectl get ingress -n ecommerce 2>/dev/null || echo "⚠️  Ingress not deployed yet. Run: kubectl apply -f ingress.yaml"

echo ""

# Check services
echo "📋 Checking services..."
kubectl get services -n ecommerce 2>/dev/null || echo "⚠️  Services not found. Deploy other manifests first."

echo ""

# Setup hosts file entry
echo "🔧 Setting up /etc/hosts entry..."
INGRESS_IP=$(kubectl get ingress ecommerce-ingress -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -z "$INGRESS_IP" ]; then
    echo "⚠️  Ingress IP not available yet. For local testing, add this to /etc/hosts:"
    echo "   127.0.0.1 ecommerce.local"
else
    echo "✅ Ingress IP: $INGRESS_IP"
    echo "   Add to /etc/hosts: $INGRESS_IP ecommerce.local"
fi

echo ""

# Test endpoints
echo "🧪 Test these endpoints after deployment:"
echo "   Frontend: http://ecommerce.local"
echo "   API Health: http://ecommerce.local/api/health"
echo "   API Products: http://ecommerce.local/api/products"

echo ""

# Troubleshooting commands
echo "🔧 Troubleshooting commands:"
echo "   kubectl describe ingress ecommerce-ingress -n ecommerce"
echo "   kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx"
echo "   kubectl get events -n ecommerce --sort-by='.lastTimestamp'"
