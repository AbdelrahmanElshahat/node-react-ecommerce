# Troubleshooting ImagePullBackOff in Kubernetes

If you're experiencing `ImagePullBackOff` or `ErrImagePull` errors when deploying your backend application to Kubernetes, follow these steps to troubleshoot and resolve the issue.

## Common Causes of ImagePullBackOff

1. **Invalid Docker Hub credentials** - The secret used for accessing your private Docker repository is incorrect or missing
2. **Image doesn't exist** - The image specified in your deployment doesn't exist in the repository
3. **Incorrect image name or tag** - Typo in the image name or tag
4. **Network issues** - Kubernetes cluster can't reach Docker Hub
5. **Rate limiting** - Docker Hub has rate limits for pulls from anonymous or free accounts

## Step-by-Step Troubleshooting

### 1. Verify the Image Exists

Run the verification script to ensure your image exists and is accessible:

```bash
./verify-image.sh
```

### 2. Check Pod Status and Events

```bash
# Get the status of your pods
kubectl get pods -n ecommerce

# Look at the events for more details on why the image is failing to pull
kubectl describe pod <pod-name> -n ecommerce
```

Look for specific error messages in the events section.

### 3. Recreate Docker Hub Secret

If you suspect your Docker Hub credentials are incorrect or expired, recreate the secret:

```bash
./create-dockerhub-secret.sh
```

### 4. Verify Secret Configuration

```bash
# Check if the secret exists
kubectl get secret dockerhub-secret -n ecommerce

# Inspect the secret content
kubectl get secret dockerhub-secret -n ecommerce -o yaml
```

### 5. Pull Image Manually

Try pulling the image manually to verify access:

```bash
docker login
docker pull elshahat20/my-app:itiBack-1.0.4
```

### 6. Modify Image Pull Policy (if needed)

If you're developing locally and want to use a local image, you can change the `imagePullPolicy` in your deployment:

```yaml
imagePullPolicy: IfNotPresent  # Only pull if not present locally
```

### 7. Check Network Access

Ensure your Kubernetes cluster has network access to Docker Hub:

```bash
# Start a debugging pod
kubectl run debug --image=alpine -n ecommerce -- sleep 3600

# Access the pod
kubectl exec -it debug -n ecommerce -- sh

# Install curl and test connectivity
apk add curl
curl -I https://index.docker.io
```

## After Fixing the Issue

Once you've fixed the issue, delete the failed pods to force Kubernetes to create new ones:

```bash
kubectl delete pod <pod-name> -n ecommerce
```

Or reapply your deployment:

```bash
kubectl apply -f backend.yaml
```

## Need More Help?

If you're still experiencing issues, check:

1. Docker Hub account status and subscription
2. Kubernetes cluster network policies
3. Registry mirroring or caching if applicable
4. Container runtime configuration on your nodes
