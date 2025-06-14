#!/bin/bash

# This script creates a direct IP access version of the ingress
# for testing and sharing with others without DNS configuration

INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$INGRESS_IP" ]; then
    echo "❌ Could not find ingress IP address!"
    echo "Trying alternative method..."
    INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    if [ -z "$INGRESS_IP" ]; then
        echo "❌ Could not find ingress IP or hostname!"
        exit 1
    fi
fi

echo "✅ Found ingress IP: $INGRESS_IP"

# Create a version of the ingress that doesn't require DNS
cat <<EOF > ip-access-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ecommerce-ip-ingress
  namespace: ecommerce
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "300"
    
    # Enable CORS for API calls
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "*"
    nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
    nginx.ingress.kubernetes.io/cors-allow-headers: "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization"
    
    # Rewrite host header for direct IP access
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header Host amazona.com;
spec:
  rules:
  - http:
      paths:
      # API routes - must come first for proper matching
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 5000
      # Static uploads path
      - path: /uploads
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 5000
      # Frontend routes - catch-all for SPA routing
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
EOF

# Apply the new ingress
kubectl apply -f ip-access-ingress.yaml

echo ""
echo "✅ Created IP-based ingress for direct access"
echo ""
echo "🌐 Share these links with others to access your application:"
echo ""
echo "- Main Application: http://$INGRESS_IP"
echo "- Products API:     http://$INGRESS_IP/api/products"
echo ""
echo "No DNS configuration or hosts file modification needed for these links!"
