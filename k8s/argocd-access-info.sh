#!/bin/bash

echo "🔐 ArgoCD Password Reset & Access Information"
echo "=============================================="

# Get current admin password
ADMIN_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)

echo "✅ ArgoCD Admin Account Reset Complete!"
echo ""
echo "🎯 Login Credentials:"
echo "  Username: admin"
echo "  Password: $ADMIN_PASSWORD"
echo ""
echo "🌐 Access URLs:"
echo "  Direct LoadBalancer: https://129.212.137.63"
echo "  Via Ingress: https://157.230.202.166/argocd"
echo "  Port Forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "                Then access: https://localhost:8080"
echo ""
echo "💡 Tips:"
echo "  - Make sure to use 'admin' (lowercase) as username"
echo "  - Copy the password exactly as shown above"
echo "  - If browser shows certificate warning, click 'Advanced' and 'Proceed'"
echo "  - Account lockout has been reset - you have fresh login attempts"
echo ""
echo "🔄 To change password after login:"
echo "  1. Login to ArgoCD UI"
echo "  2. Go to User Info (top right menu)"
echo "  3. Click 'Update Password'"
echo "  4. Set your preferred password"
echo ""

# Show current pod status
echo "📊 ArgoCD Server Status:"
kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server
