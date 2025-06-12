# Kubernetes Manifests for E-commerce Application

This folder contains all essential Kubernetes manifest files and scripts for deploying the e-commerce application on DigitalOcean.

## 📁 File Structure

### Core Kubernetes Manifests (Required)
- **`namespace.yaml`** - Creates the `ecommerce` namespace
- **`configmap-secret.yaml`** - Application configuration and secrets
- **`mongodb.yaml`** - MongoDB database with persistent storage
- **`backend.yaml`** - Node.js backend API deployment and service
- **`frontend.yaml`** - React frontend deployment and service
- **`ingress.yaml`** - NGINX ingress with SSL termination

### SSL Certificate Management
- **`cert-manager.yaml`** - Let's Encrypt certificate issuers

### Optional Components
- **`monitoring.yaml`** - Prometheus monitoring setup

### Deployment Scripts
- **`create-cluster.sh`** - Create DigitalOcean Kubernetes cluster
- **`deploy.sh`** - Complete deployment automation
- **`update-manifests.sh`** - Update manifests with image URLs
- **`test-ingress.sh`** - Test and validate deployment
- **`cleanup.sh`** - Remove all deployed resources

## 🚀 Quick Deployment

### Automated Deployment
```bash
# From project root directory
./quick-deploy.sh
```

### Manual Step-by-Step
```bash
# 1. Create cluster (from project root)
./k8s/create-cluster.sh

# 2. Build and push images (from project root)
./build-and-push.sh

# 3. Update manifests with image URLs
./update-manifests.sh

# 4. Deploy all components
./deploy.sh

# 5. Test deployment
./test-ingress.sh
```

## 🔧 Configuration Required

Before deployment, update these files:

### 1. Update Domain and Email
```bash
# In configmap-secret.yaml
REACT_APP_API_URL: "https://your-domain.com"

# In cert-manager.yaml  
email: your-email@example.com

# In ingress.yaml
host: your-domain.com
```

### 2. Update Secrets (Base64 encoded)
```bash
# Generate base64 values
echo -n 'your-aws-access-key' | base64
echo -n 'your-aws-secret-key' | base64

# Update in configmap-secret.yaml
AWS_ACCESS_KEY_ID: "<base64-encoded-value>"
AWS_SECRET_ACCESS_KEY: "<base64-encoded-value>"
```

## 📊 Monitoring and Management

### Check Deployment Status
```bash
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
kubectl get ingress -n ecommerce
```

### View Logs
```bash
kubectl logs -f deployment/backend-deployment -n ecommerce
kubectl logs -f deployment/frontend-deployment -n ecommerce
kubectl logs -f deployment/mongodb-deployment -n ecommerce
```

### Scale Applications
```bash
kubectl scale deployment backend-deployment --replicas=3 -n ecommerce
kubectl scale deployment frontend-deployment --replicas=3 -n ecommerce
```

## 🧪 Testing

### Test Deployment
```bash
./test-ingress.sh
```

### Manual Testing
```bash
# Check LoadBalancer IP
kubectl get service -n ingress-nginx ingress-nginx-controller

# Test API health
curl https://your-domain.com/api/health

# Check SSL certificate
kubectl get certificate -n ecommerce
```

## 🗑️ Cleanup

### Remove All Resources
```bash
./cleanup.sh
```

### Manual Cleanup
```bash
kubectl delete namespace ecommerce
```

## 📋 Deployment Order

The deployment script applies manifests in this order:
1. Namespace
2. ConfigMap and Secrets  
3. MongoDB (with persistent storage)
4. Backend API
5. Frontend
6. Ingress (with SSL certificates)

## 🔒 Security Features

- SSL/TLS encryption with Let's Encrypt
- Kubernetes secrets for sensitive data
- Network policies for pod isolation
- Resource limits and requests
- Health checks and readiness probes
- Security headers in NGINX

## 💡 Tips

- **Development**: Use smaller resource limits for cost savings
- **Production**: Enable monitoring and set up alerts
- **Scaling**: Use Horizontal Pod Autoscaler (HPA) for automatic scaling
- **Backup**: Implement MongoDB backup strategy using persistent volume snapshots

For detailed deployment instructions, see the main [KUBERNETES-DEPLOYMENT-GUIDE.md](../KUBERNETES-DEPLOYMENT-GUIDE.md).

## Notes

- **Database**: MongoDB uses a 10Gi persistent volume
- **Resources**: Backend and Frontend have memory/CPU limits configured
- **Health Checks**: Backend includes liveness and readiness probes at `/api/health`
- **Security**: Sensitive data (AWS credentials, MongoDB passwords) stored in Secrets
- **File Uploads**: Supports both local storage and AWS S3 via `/uploads` path