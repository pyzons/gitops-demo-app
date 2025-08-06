#!/bin/bash

# GitOps Setup Script
# This script sets up ArgoCD and initializes GitOps workflow

set -e

echo "🚀 Starting GitOps Setup..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if we can connect to a cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

echo "✅ Kubernetes cluster connection verified"

# Check if ingress controller is available
echo "🔍 Checking for ingress controller..."
if kubectl get pods -n ingress-nginx &>/dev/null; then
    echo "✅ Ingress controller found"
else
    echo "⚠️  Warning: No ingress controller found in ingress-nginx namespace."
    echo "   Consider running 'make kind-create' to set up the cluster with ingress controller."
fi

# Install ArgoCD
echo "📦 Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "🔧 Configuring ArgoCD service for Kind cluster..."
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort","ports":[{"name":"http","port":80,"protocol":"TCP","targetPort":8080,"nodePort":30080},{"name":"https","port":443,"protocol":"TCP","targetPort":8080,"nodePort":30443}]}}'

echo "🔧 Configuring ArgoCD server for insecure mode..."
kubectl patch deployment argocd-server -n argocd -p '{"spec":{"template":{"spec":{"containers":[{"name":"argocd-server","args":["/usr/local/bin/argocd-server","--insecure"]}]}}}}'

echo "⏳ Waiting for ArgoCD server to restart..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=120s

# Get ArgoCD admin password
echo "🔑 Getting ArgoCD admin password..."
if ! ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null); then
    echo "⚠️  Warning: Could not retrieve ArgoCD admin password. The secret might not be ready yet."
    echo "   You can get it later with: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
    ARGOCD_PASSWORD="<password not available>"
fi

echo "🔍 Verifying ArgoCD accessibility..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:9080 | grep -q "200"; then
    echo "✅ ArgoCD is accessible via HTTP"
else
    echo "⚠️  Warning: ArgoCD HTTP endpoint may not be ready yet. Please wait a moment and try again."
fi

echo "✅ ArgoCD installation complete!"
echo ""
echo "🌐 Access ArgoCD:"
echo "   URL: http://localhost:9080 (HTTP - recommended for insecure mode)"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "📝 Note: HTTPS endpoint (https://localhost:9443) is available but will show certificate warnings in insecure mode."
echo ""
echo "📝 Next steps:"
echo "1. Login to ArgoCD UI using the URL above"
echo "2. Connect your Git repository"
echo "3. Deploy the app-of-apps"
echo ""
echo "✅ Setup complete! ArgoCD is ready for use."
