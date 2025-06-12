# Kubernetes Deployment Guide for DigitalOcean

This guide walks you through deploying your e-commerce application on DigitalOcean Kubernetes Service (DOKS).

## Prerequisites

1. **DigitalOcean Account** with billing enabled
2. **Domain name** (for SSL certificates)
3. **Local tools installed**:
   - Docker
   - kubectl
   - doctl (DigitalOcean CLI)

## Step-by-Step Deployment

### 1. Setup DigitalOcean CLI

```bash
# Install doctl (if not already done)
curl -sL https://github.com/digitalocean/doctl/releases/download/v1.94.0/doctl-1.94.0-linux-amd64.tar.gz | tar -xzv
sudo mv doctl /usr/local/bin

# Authenticate with DigitalOcean
doctl auth init
```

### 2. Create Kubernetes Cluster

```bash
# Make script executable and run
chmod +x k8s/create-cluster.sh
./k8s/create-cluster.sh
```

This creates a 3-node cluster with:
- **Node size**: 2 vCPU, 4GB RAM
- **Auto-scaling**: 2-5 nodes
- **Region**: NYC1 (changeable in script)

### 3. Build and Push Docker Images

```bash
# Build and push images to DigitalOcean Container Registry
chmod +x build-and-push.sh
./build-and-push.sh
```

This script:
- Creates a DigitalOcean Container Registry
- Builds your backend and frontend images
- Pushes them to the registry
- Saves image URLs for Kubernetes manifests

### 4. Update Configuration

Before deploying, update these files with your actual values:

#### `k8s/configmap-secret.yaml`
```yaml
data:
  REACT_APP_API_URL: "https://your-domain.com"  # Your actual domain
  JWT_SECRET: "your-secure-jwt-secret"          # Generate a secure secret
  PAYPAL_CLIENT_ID: "your-paypal-client-id"     # Your PayPal client ID
  AWS_BUCKET_NAME: "your-s3-bucket"             # Your AWS S3 bucket
```

#### `k8s/cert-manager.yaml`
```yaml
email: your-email@example.com  # Your email for Let's Encrypt
```

#### `k8s/ingress.yaml`
```yaml
- host: your-domain.com  # Replace with your actual domain
```

#### Update AWS credentials (base64 encoded):
```bash
# Encode your AWS credentials
echo -n 'your-aws-access-key' | base64
echo -n 'your-aws-secret-key' | base64
# Update the values in configmap-secret.yaml
```

### 5. Update Kubernetes Manifests

```bash
# Update manifests with actual image URLs
cd k8s
chmod +x update-manifests.sh
./update-manifests.sh
```

### 6. Deploy to Kubernetes

```bash
# Run the complete deployment
chmod +x k8s/deploy.sh
./k8s/deploy.sh
```

This deployment script:
- Installs NGINX Ingress Controller
- Installs cert-manager for SSL certificates
- Deploys all your application components
- Sets up SSL certificates with Let's Encrypt

### 7. Configure DNS

After deployment, get the LoadBalancer IP:

```bash
kubectl get service -n ingress-nginx ingress-nginx-controller
```

Configure your domain's DNS:
- **A Record**: `your-domain.com` → `LoadBalancer IP`
- **CNAME Record**: `www.your-domain.com` → `your-domain.com`

## Monitoring and Troubleshooting

### Check Deployment Status
```bash
# View all pods
kubectl get pods -n ecommerce

# View services
kubectl get services -n ecommerce

# View ingress
kubectl get ingress -n ecommerce

# Check SSL certificate
kubectl get certificate -n ecommerce
```

### View Logs
```bash
# Backend logs
kubectl logs -f deployment/backend-deployment -n ecommerce

# Frontend logs
kubectl logs -f deployment/frontend-deployment -n ecommerce

# MongoDB logs
kubectl logs -f deployment/mongodb-deployment -n ecommerce
```

### Common Issues

#### 1. Pods not starting
```bash
kubectl describe pod <pod-name> -n ecommerce
```

#### 2. SSL certificate not issued
```bash
kubectl describe certificate ecommerce-tls-secret -n ecommerce
kubectl logs -n cert-manager deployment/cert-manager
```

#### 3. LoadBalancer IP not assigned
```bash
kubectl get events -n ingress-nginx
```

## Scaling and Updates

### Scale your application
```bash
# Scale backend
kubectl scale deployment backend-deployment --replicas=3 -n ecommerce

# Scale frontend
kubectl scale deployment frontend-deployment --replicas=3 -n ecommerce
```

### Update your application
```bash
# Rebuild and push new images
./build-and-push.sh

# Update manifests
cd k8s && ./update-manifests.sh

# Apply updates
kubectl apply -f backend.yaml -f frontend.yaml
```

### Rolling updates
```bash
# Force rolling update
kubectl rollout restart deployment/backend-deployment -n ecommerce
kubectl rollout restart deployment/frontend-deployment -n ecommerce
```

## Cost Optimization

### DigitalOcean Costs (Monthly estimates)
- **3 nodes (s-2vcpu-4gb)**: ~$72/month
- **Load Balancer**: ~$12/month  
- **Block Storage (10GB)**: ~$1/month
- **Container Registry**: ~$5/month
- **Total**: ~$90/month

### Cost-saving tips
1. Use smaller nodes for development
2. Enable auto-scaling to scale down during low usage
3. Use spot instances for non-critical workloads
4. Monitor resource usage and optimize

## Security Best Practices

1. **Network Policies**: Implement network segmentation
2. **RBAC**: Use Role-Based Access Control
3. **Secrets Management**: Use Kubernetes secrets properly
4. **Image Security**: Scan images for vulnerabilities
5. **Regular Updates**: Keep cluster and dependencies updated

## Backup Strategy

### MongoDB Backup
```bash
# Create backup job
kubectl create job mongodb-backup --from=cronjob/mongodb-backup -n ecommerce
```

### Persistent Volume Backup
Use DigitalOcean's Volume Snapshots feature through the control panel.

## Next Steps

1. Set up monitoring with Prometheus and Grafana
2. Implement CI/CD pipeline
3. Add health checks and alerting
4. Configure backup automation
5. Set up staging environment
