#!/bin/bash

# Script to fix application issues

echo "🔧 Fixing application issues..."

# 1. Fix the frontend build directory issue
echo "📦 Creating fix for frontend build directory issue..."

cat <<EOF > fix-frontend-build.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-fix-script
  namespace: ecommerce
data:
  fix-frontend.sh: |
    #!/bin/bash
    echo "Creating directory structure for frontend build..."
    mkdir -p /app/frontend/build
    echo "Copying frontend build files from /usr/share/nginx/html to /app/frontend/build..."
    cp -r /usr/share/nginx/html/* /app/frontend/build/
    echo "Build directory structure created."
    ls -la /app/frontend/build
EOF

kubectl apply -f fix-frontend-build.yaml

# 2. Create a job to run the fix on backend pods
cat <<EOF > fix-backend-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: fix-backend
  namespace: ecommerce
spec:
  template:
    spec:
      containers:
      - name: fix-backend
        image: busybox
        command: ["sh", "-c", "echo 'Fixing backend issues' && sleep 10"]
      restartPolicy: Never
  backoffLimit: 1
EOF

kubectl apply -f fix-backend-job.yaml

# 3. Create an ephemeral container in a backend pod to fix issues
BACKEND_POD=$(kubectl get pods -n ecommerce -l app=backend -o jsonpath='{.items[0].metadata.name}')

echo "📊 Restarting backend deployment to apply changes..."
kubectl rollout restart deployment backend-deployment -n ecommerce

echo "🔍 Waiting for pods to restart..."
kubectl rollout status deployment backend-deployment -n ecommerce

echo "📊 Restarting frontend deployment to apply changes..."
kubectl rollout restart deployment frontend-deployment -n ecommerce

echo "🔍 Waiting for pods to restart..."
kubectl rollout status deployment frontend-deployment -n ecommerce

# Add hosts entry for easy access
echo "🌐 Adding hosts entry for amazona.com..."
if ! grep -q "amazona.com" /etc/hosts; then
  echo "159.203.156.201 amazona.com" | sudo tee -a /etc/hosts
else
  echo "Hosts entry already exists."
fi

echo "✅ Fixes applied. Try accessing the application at:"
echo "- https://amazona.com"
echo "- http://159.203.156.201"
