# Kubernetes Deployment Checklist

Use this checklist to ensure smooth deployments of your e-commerce application to Kubernetes.

## Pre-Deployment Checks

- [ ] Docker images are built and pushed to Docker Hub
- [ ] Docker Hub credentials are current and valid
- [ ] ConfigMap and Secrets are properly configured
- [ ] MongoDB deployment is running
- [ ] All environment variables are set correctly

## Deployment Steps

1. **Set up Docker Hub authentication**
   ```bash
   ./create-dockerhub-secret.sh
   ```

2. **Deploy MongoDB (if not already deployed)**
   ```bash
   kubectl apply -f mongodb.yaml
   ```

3. **Deploy ConfigMap and Secrets**
   ```bash
   kubectl apply -f configmap-secret.yaml
   ```

4. **Deploy Backend**
   ```bash
   kubectl apply -f backend.yaml
   ```

5. **Deploy Frontend**
   ```bash
   kubectl apply -f frontend.yaml
   ```

6. **Deploy Ingress (if needed)**
   ```bash
   kubectl apply -f ingress.yaml
   ```

## Post-Deployment Verification

- [ ] Check all pods are running
   ```bash
   kubectl get pods -n ecommerce
   ```

- [ ] Check backend logs
   ```bash
   ./check-logs.sh
   ```

- [ ] Test endpoints
   ```bash
   kubectl run -n ecommerce curl-test --image=curlimages/curl --rm --restart=Never -i --timeout=60 -- curl -s http://backend-service:5000/api/products
   ```

- [ ] Access frontend through Ingress
   ```bash
   curl -s https://your-domain.com
   ```

## Troubleshooting

### ImagePullBackOff

If you see ImagePullBackOff errors:

1. Check Docker Hub credentials
   ```bash
   ./create-dockerhub-secret.sh
   ```

2. Verify image exists
   ```bash
   docker pull elshahat20/my-app:itiBack-1.0.4
   ```

3. Check pod events
   ```bash
   kubectl describe pod <pod-name> -n ecommerce
   ```

### Service Connection Issues

If services can't connect to each other:

1. Check service discovery
   ```bash
   kubectl run -n ecommerce curl-test --image=curlimages/curl --rm --restart=Never -i --timeout=60 -- curl -s http://backend-service:5000/api/health
   ```

2. Check network policies
   ```bash
   kubectl get networkpolicies -n ecommerce
   ```

### Database Connection Issues

If the application can't connect to MongoDB:

1. Check MongoDB is running
   ```bash
   kubectl get pods -n ecommerce -l app=mongodb
   ```

2. Check MongoDB service
   ```bash
   kubectl run -n ecommerce mongo-test --image=mongo --rm --restart=Never -i --timeout=60 -- mongo --host mongodb-service --port 27017 -u admin -p password --authenticationDatabase admin
   ```

## Clean Up

To delete all resources:
```bash
kubectl delete -f ingress.yaml
kubectl delete -f frontend.yaml
kubectl delete -f backend.yaml
kubectl delete -f mongodb.yaml
kubectl delete -f configmap-secret.yaml
```
