#!/bin/bash

# Script to check products directly from the backend API

echo "🔍 Checking products from backend API..."

# Get the name of one of the backend pods
BACKEND_POD=$(kubectl get pods -n ecommerce -l app=backend -o jsonpath='{.items[0].metadata.name}')

if [ -z "$BACKEND_POD" ]; then
    echo "❌ No backend pods found!"
    exit 1
fi

echo "✅ Using backend pod: $BACKEND_POD"

# Forward port from the backend pod
echo "🔄 Setting up port-forwarding to backend pod..."
kubectl port-forward -n ecommerce $BACKEND_POD 5000:5000 &
PF_PID=$!

# Wait for port-forwarding to be established
sleep 3

# Query the products API
echo "📊 Querying products API..."
curl -s http://localhost:5000/api/products | jq

# Clean up port-forwarding
kill $PF_PID 2>/dev/null || true
wait $PF_PID 2>/dev/null || true
echo "✅ Port-forwarding terminated."
