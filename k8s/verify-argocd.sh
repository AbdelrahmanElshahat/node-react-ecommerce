#!/bin/bash

echo "🔍 ArgoCD Health Check"
echo "====================="

echo "📊 Checking all ArgoCD components..."
kubectl get pods -n argocd

echo ""
echo "🌐 Checking ArgoCD services..."
kubectl get svc -n argocd

echo ""
echo "🔐 Getting current admin credentials..."
ADMIN_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "Not available")

echo ""
echo "✅ ArgoCD Status Summary:"
echo "========================="

# Check if all critical pods are running
RUNNING_PODS=$(kubectl get pods -n argocd --no-headers | grep "1/1.*Running" | wc -l)
TOTAL_PODS=$(kubectl get pods -n argocd --no-headers | wc -l)

if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ]; then
    echo "✅ All ArgoCD pods are running ($RUNNING_PODS/$TOTAL_PODS)"
else
    echo "⚠️  Some pods are not ready ($RUNNING_PODS/$TOTAL_PODS)"
fi

# Check if repo-server is running
if kubectl get pods -n argocd | grep -q "argocd-repo-server.*1/1.*Running"; then
    echo "✅ Repo server is running (manifest generation should work)"
else
    echo "❌ Repo server is not running"
fi

echo ""
echo "🎯 Access Information:"
echo "  URL: https://129.212.137.63"
echo "  Username: admin"
echo "  Password: $ADMIN_PASSWORD"
echo ""
echo "🚀 ArgoCD is ready for GitOps deployments!"
