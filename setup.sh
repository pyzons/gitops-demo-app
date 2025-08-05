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

# Install ArgoCD
echo "📦 Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
echo "🔑 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "✅ ArgoCD installation complete!"
echo ""
echo "🌐 Access ArgoCD:"
echo "   Port-forward: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   URL: https://localhost:8080"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "📝 Next steps:"
echo "1. Port-forward ArgoCD service"
echo "2. Login to ArgoCD UI"
echo "3. Connect your Git repository"
echo "4. Deploy the app-of-apps"

# Optional: Set up port-forward
read -p "🤔 Would you like to start port-forwarding now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🌐 Starting port-forward... (Press Ctrl+C to stop)"
    kubectl port-forward svc/argocd-server -n argocd 8080:443
fi
