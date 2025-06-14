#!/bin/bash

# This script will help check the application, products, and AWS configuration

echo "🔍 Checking your e-commerce application components..."

# 1. Check ingress
echo -e "\n📊 INGRESS STATUS:"
kubectl get ingress -n ecommerce

# 2. Check all services
echo -e "\n📊 SERVICES STATUS:"
kubectl get svc -n ecommerce

# 3. Check all pods
echo -e "\n📊 PODS STATUS:"
kubectl get pods -n ecommerce

# 4. Check backend logs for any errors
echo -e "\n📊 BACKEND LOGS (recent):"
BACKEND_POD=$(kubectl get pods -n ecommerce -l app=backend -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n ecommerce $BACKEND_POD --tail=30

# 5. Check frontend logs
echo -e "\n📊 FRONTEND LOGS (recent):"
FRONTEND_POD=$(kubectl get pods -n ecommerce -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n ecommerce $FRONTEND_POD --tail=30

# 6. Print access information
echo -e "\n✅ ACCESS INFORMATION:"
INGRESS_IP=$(kubectl get ingress -n ecommerce ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
INGRESS_HOST=$(kubectl get ingress -n ecommerce ecommerce-ingress -o jsonpath='{.spec.rules[0].host}')

echo "Your application should be accessible at:"
echo "- Using domain: https://$INGRESS_HOST"
echo "- Using IP: http://$INGRESS_IP"
echo ""
echo "To access the application via domain name, add this entry to your /etc/hosts file:"
echo "$INGRESS_IP $INGRESS_HOST"
echo ""
echo "API Endpoints:"
echo "- Products API: http://$INGRESS_IP/api/products"
echo "- User API: http://$INGRESS_IP/api/users"
