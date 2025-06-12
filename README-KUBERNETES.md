# 🛍️ E-commerce Application - Kubernetes Deployment

A complete guide for deploying your Node.js + React e-commerce application on DigitalOcean Kubernetes.

## 🎯 Quick Start

Deploy your entire application with one command:

```bash
./quick-deploy.sh
```

This handles cluster creation, image building, and deployment automatically.

## 📋 What You'll Learn

This deployment covers essential Kubernetes concepts:

- **Container Orchestration** - Managing application containers
- **Service Discovery** - How services communicate
- **Load Balancing** - Distributing traffic
- **Persistent Storage** - Database data persistence  
- **SSL/TLS** - Automatic certificate management
- **Ingress** - External traffic routing
- **Monitoring** - Application health checks

## 🏗️ Architecture

```
Internet → LoadBalancer → Ingress → Services → Pods
                                      ↓
                              MongoDB (Persistent Volume)
```

**Components:**
- **Frontend**: React app served by NGINX
- **Backend**: Node.js API server
- **Database**: MongoDB with persistent storage
- **Ingress**: NGINX for SSL termination and routing

## 📚 Documentation

- **[KUBERNETES-DEPLOYMENT-GUIDE.md](KUBERNETES-DEPLOYMENT-GUIDE.md)** - Complete step-by-step guide
- **[DEPLOYMENT-SUMMARY.md](DEPLOYMENT-SUMMARY.md)** - Architecture and configuration overview
- **[k8s/README.md](k8s/README.md)** - Kubernetes manifests explanation

## 🚀 Deployment Options

### Option 1: Automated (Recommended)
```bash
# One command deployment
./quick-deploy.sh
```

### Option 2: Manual Steps
```bash
# 1. Setup DigitalOcean
doctl auth init

# 2. Create cluster  
./k8s/create-cluster.sh

# 3. Build images
./build-and-push.sh

# 4. Deploy app
cd k8s && ./deploy.sh

# 5. Test deployment
./test-ingress.sh
```

## ⚙️ Configuration

Before deployment, update:

1. **Domain**: Replace `your-domain.com` in configuration files
2. **Email**: Add your email for SSL certificates  
3. **Secrets**: Update AWS credentials and PayPal keys
4. **Resources**: Adjust CPU/memory limits as needed

## 💰 Estimated Costs

**DigitalOcean Monthly Costs:**
- Kubernetes Cluster (3 nodes): ~$72
- Load Balancer: ~$12
- Storage & Registry: ~$6
- **Total: ~$90/month**

## 🔧 Management Commands

```bash
# View application status
kubectl get pods -n ecommerce

# Check logs
kubectl logs -f deployment/backend-deployment -n ecommerce

# Scale application
kubectl scale deployment backend-deployment --replicas=3 -n ecommerce

# Update application
./build-and-push.sh && kubectl rollout restart deployment/backend-deployment -n ecommerce

# Clean up everything
./k8s/cleanup.sh
```

## 🎓 Learning Path

1. **Start Here**: Run `./quick-deploy.sh` to see it work
2. **Understand**: Read the deployment guide
3. **Experiment**: Try scaling, updating, monitoring
4. **Advanced**: Add CI/CD, service mesh, advanced monitoring

## 🔍 Troubleshooting

**Common Issues:**
- Pods not starting → Check `kubectl describe pod <name>`
- SSL not working → Verify DNS and certificate status
- App not accessible → Check ingress and LoadBalancer IP

**Get Help:**
```bash
# Check all resources
kubectl get all -n ecommerce

# View recent events  
kubectl get events -n ecommerce --sort-by='.lastTimestamp'

# Test connectivity
./k8s/test-ingress.sh
```

## 🛡️ Production Readiness

This deployment includes:
- ✅ SSL/TLS encryption
- ✅ Health checks and readiness probes
- ✅ Resource limits and requests
- ✅ Persistent storage for database
- ✅ Secrets management
- ✅ Network policies
- ✅ Monitoring capabilities

## 🚨 Important Notes

- **Backup**: Implement MongoDB backup strategy
- **Monitoring**: Set up alerts for production
- **Security**: Regularly update images and scan for vulnerabilities
- **Costs**: Monitor DigitalOcean usage dashboard

## 📞 Support

Need help? Check:
1. [Troubleshooting section](#-troubleshooting) above
2. [KUBERNETES-DEPLOYMENT-GUIDE.md](KUBERNETES-DEPLOYMENT-GUIDE.md) for detailed steps
3. DigitalOcean Kubernetes documentation
4. Kubernetes official documentation

---

**Happy deploying!** 🎉 Your e-commerce app will be running on professional-grade Kubernetes infrastructure.
