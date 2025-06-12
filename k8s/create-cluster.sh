#!/bin/bash

# Create DigitalOcean Kubernetes Cluster for E-commerce App
# This script creates a production-ready Kubernetes cluster

echo "🚀 Creating DigitalOcean Kubernetes Cluster..."

# Cluster configuration
CLUSTER_NAME="ecommerce-k8s"
REGION="nyc1"  # You can change this to your preferred region
NODE_POOL_SIZE="s-2vcpu-4gb"  # 2 vCPU, 4GB RAM nodes
NODE_COUNT=3
K8S_VERSION="1.32.2-do.3"  # Latest stable Kubernetes version

echo "📋 Cluster Details:"
echo "   Name: $CLUSTER_NAME"
echo "   Region: $REGION"
echo "   Node Size: $NODE_POOL_SIZE"
echo "   Node Count: $NODE_COUNT"
echo "   Kubernetes Version: $K8S_VERSION"
echo ""

# Create the cluster
echo "🔧 Creating cluster (this may take 5-10 minutes)..."
doctl kubernetes cluster create $CLUSTER_NAME \
  --region $REGION \
  --node-pool "name=worker-pool;size=$NODE_POOL_SIZE;count=$NODE_COUNT;auto-scale=true;min-nodes=2;max-nodes=5" \
  --version $K8S_VERSION \
  --tag ecommerce

echo "⚙️  Configuring kubectl..."
doctl kubernetes cluster kubeconfig save $CLUSTER_NAME

echo "✅ Cluster created successfully!"
echo ""
echo "🔍 Checking cluster status..."
kubectl cluster-info
kubectl get nodes

echo ""
echo "📝 Next steps:"
echo "1. Install NGINX Ingress Controller"
echo "2. Update your DNS settings"
echo "3. Deploy your application"
echo ""
echo "💡 Useful commands:"
echo "   doctl kubernetes cluster list"
echo "   doctl kubernetes cluster get $CLUSTER_NAME"
echo "   kubectl get pods --all-namespaces"
