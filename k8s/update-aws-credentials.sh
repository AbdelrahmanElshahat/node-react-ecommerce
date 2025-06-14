#!/bin/bash

# This script helps verify and update AWS credentials in the Kubernetes deployment

echo "🔍 Checking backend deployment pods..."
BACKEND_PODS=$(kubectl get pods -n ecommerce -l app=backend -o jsonpath='{.items[*].metadata.name}')

if [ -z "$BACKEND_PODS" ]; then
    echo "❌ No backend pods found in the ecommerce namespace!"
    exit 1
fi

echo "✅ Found backend pods: $BACKEND_PODS"

# Check if AWS credentials are properly set in the secret
echo "🔍 Checking AWS credentials in secret..."
AWS_ACCESS_KEY=$(kubectl get secret ecommerce-secrets -n ecommerce -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' 2>/dev/null | base64 --decode)
AWS_SECRET_KEY=$(kubectl get secret ecommerce-secrets -n ecommerce -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' 2>/dev/null | base64 --decode)

if [ -z "$AWS_ACCESS_KEY" ] || [ -z "$AWS_SECRET_KEY" ]; then
    echo "⚠️ AWS credentials are not properly set in the Kubernetes secret!"
    
    echo "Would you like to update the AWS credentials? (y/n)"
    read -r answer
    
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "Enter your AWS Access Key ID:"
        read -r NEW_ACCESS_KEY
        
        echo "Enter your AWS Secret Access Key:"
        read -r NEW_SECRET_KEY
        
        # Encode the credentials
        ENCODED_ACCESS_KEY=$(echo -n "$NEW_ACCESS_KEY" | base64)
        ENCODED_SECRET_KEY=$(echo -n "$NEW_SECRET_KEY" | base64)
        
        # Update the secret
        kubectl patch secret ecommerce-secrets -n ecommerce --type='json' -p="[
            {\"op\": \"replace\", \"path\": \"/data/AWS_ACCESS_KEY_ID\", \"value\": \"$ENCODED_ACCESS_KEY\"},
            {\"op\": \"replace\", \"path\": \"/data/AWS_SECRET_ACCESS_KEY\", \"value\": \"$ENCODED_SECRET_KEY\"}
        ]"
        
        echo "✅ AWS credentials updated in the secret!"
    else
        echo "❌ Aborted. AWS credentials were not updated."
    fi
else
    echo "✅ AWS credentials are set in the Kubernetes secret."
fi

# Restart the backend pods to apply changes
echo "🔄 Restarting backend deployment to apply changes..."
kubectl rollout restart deployment backend-deployment -n ecommerce

echo "🔍 Waiting for pods to restart..."
kubectl rollout status deployment backend-deployment -n ecommerce

echo "✅ Backend pods restarted successfully!"
echo "Your e-commerce application should now have:"
echo "1. AWS SDK integration for image uploads"
echo "2. Sample products in the database"
echo ""
echo "Access your application through the configured ingress and verify functionality."
