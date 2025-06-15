#!/bin/bash

echo "🔍 Checking ArgoCD installation status..."

# Wait for ArgoCD server to be ready
echo "⏳ Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

echo "✅ ArgoCD server is ready!"

# Get the admin password
echo "🔐 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "Password not available yet")

echo ""
echo "🎉 ArgoCD Access Information:"
echo "================================"
echo "📍 ArgoCD URL: https://157.230.202.166/argocd"
echo "👤 Username: admin"
if [ "$ARGOCD_PASSWORD" != "Password not available yet" ]; then
    echo "🔑 Password: $ARGOCD_PASSWORD"
else
    echo "🔑 Password: Run this command to get password once server is fully ready:"
    echo "    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
fi
echo ""
echo "📋 Alternative access methods:"
echo "1. Port Forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Then access: https://localhost:8080"
echo ""

# Show pod status
echo "📊 ArgoCD Pods Status:"
kubectl get pods -n argocd

echo ""
echo "🔍 ArgoCD Services:"
kubectl get svc -n argocd

echo ""
echo "🌐 ArgoCD Ingress:"
kubectl get ingress -n argocd
