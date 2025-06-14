#!/bin/bash

# Script to port-forward MongoDB and check products

echo "🔄 Setting up port-forwarding to MongoDB in Kubernetes..."
kubectl port-forward -n ecommerce svc/mongodb-service 27017:27017 &
PF_PID=$!

# Wait for port-forwarding to be established
sleep 3

echo "📊 Checking for products in the database..."
echo "show dbs; use amazona; db.products.count();" | mongo mongodb://admin:password@localhost:27017/amazona?authSource=admin

# Clean up port-forwarding
kill $PF_PID
wait $PF_PID 2>/dev/null || true
echo "✅ Port-forwarding terminated."
