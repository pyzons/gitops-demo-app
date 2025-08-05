.PHONY: help install status logs port-forward clean deploy-app

# GitOps Demo Makefile
# Provides easy commands for GitOps operations

help: ## Show this help message
	@echo "GitOps Demo - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install ArgoCD in the cluster
	@echo "🚀 Installing ArgoCD..."
	@./setup.sh

status: ## Check ArgoCD status
	@echo "📊 ArgoCD Status:"
	@kubectl get pods -n argocd
	@echo ""
	@echo "🔑 ArgoCD Admin Password:"
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

logs: ## Show ArgoCD server logs
	@echo "📋 ArgoCD Server Logs:"
	@kubectl logs -n argocd deployment/argocd-server -f

port-forward: ## Start port-forward to ArgoCD (localhost:8080)
	@echo "🌐 Starting port-forward to ArgoCD..."
	@echo "Access ArgoCD at: https://localhost:8080"
	@kubectl port-forward svc/argocd-server -n argocd 8080:443

deploy-app: ## Deploy the demo application
	@echo "📦 Deploying demo application..."
	@kubectl apply -f applications/app-of-apps/root-app.yaml

check-cluster: ## Check if cluster is available
	@echo "🔍 Checking cluster connection..."
	@kubectl cluster-info
	@kubectl get nodes

clean: ## Remove ArgoCD and demo applications
	@echo "🧹 Cleaning up..."
	@kubectl delete namespace argocd --ignore-not-found=true
	@kubectl delete namespace demo-app --ignore-not-found=true
	@kubectl delete namespace demo-app-dev --ignore-not-found=true

validate: ## Validate Kubernetes manifests
	@echo "✅ Validating manifests..."
	@find . -name "*.yaml" -not -path "./.*" | xargs kubectl --dry-run=client apply -f

build-kustomize: ## Build kustomize configurations
	@echo "🔨 Building kustomize configurations..."
	@echo "Infrastructure:"
	@kubectl kustomize infrastructure/argocd
	@echo ""
	@echo "Demo App:"
	@kubectl kustomize applications/demo-app
	@echo ""
	@echo "Dev Environment:"
	@kubectl kustomize environments/dev
