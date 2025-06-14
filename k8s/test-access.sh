#!/bin/bash

# This script tests both domain and IP-based access to the application

# Get the ingress IP
INGRESS_IP=$(kubectl get ingress -n ecommerce ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "✅ Testing access methods for your application"
echo ""
echo "💻 Domain-based access (for your PC with hosts file entry):"
echo "   https://amazona.com"
echo ""
echo "📱 IP-based access (for any device without hosts file entry):"
echo "   http://$INGRESS_IP"
echo ""
echo "📱 API access:"
echo "   http://$INGRESS_IP/api/products"
echo ""

# Test domain-based access
echo "🔍 Testing domain-based access (curl amazona.com)..."
curl -s -I -L amazona.com | head -1

# Test IP-based access
echo ""
echo "🔍 Testing IP-based access (curl $INGRESS_IP)..."
curl -s -I $INGRESS_IP | head -1

# Test API access
echo ""
echo "🔍 Testing API access (curl $INGRESS_IP/api/products)..."
PRODUCTS=$(curl -s $INGRESS_IP/api/products)
PRODUCT_COUNT=$(echo $PRODUCTS | grep -o "_id" | wc -l)
echo "Found $PRODUCT_COUNT products"

echo ""
echo "✅ Share this link with others: http://$INGRESS_IP"
echo "   They can access your application without any DNS or hosts file configuration"
