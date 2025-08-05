.PHONY: help kind-create kind-delete kind-status kind-reset install check-cluster clean validate

help: ## Show this help message
	@echo "GitOps Demo - Available Commands:"
	@echo ""
	@echo "🐳 Kind Cluster Commands:"
	@echo "  kind-create   - Create Kind cluster"
	@echo "  kind-delete   - Delete Kind cluster" 
	@echo "  kind-status   - Show cluster status"
	@echo "  kind-reset    - Reset cluster"
	@echo ""
	@echo "⚙️ GitOps Commands:"
	@echo "  install       - Install ArgoCD"
	@echo "  status        - Check ArgoCD status"
	@echo "  check-cluster - Check cluster connection"
	@echo "  clean         - Clean up resources"
	@echo "  validate      - Validate manifests"

kind-create: ## Create Kind cluster for development
	@./kind/cluster-manager.sh create

kind-delete: ## Delete Kind cluster
	@./kind/cluster-manager.sh delete

kind-status: ## Show Kind cluster status
	@./kind/cluster-manager.sh status

kind-reset: ## Reset Kind cluster (delete and recreate)
	@./kind/cluster-manager.sh reset

install: ## Install ArgoCD in the cluster
	@./setup.sh

status: ## Check ArgoCD status
	@kubectl get pods -n argocd 2>/dev/null || echo "ArgoCD not installed"

check-cluster: ## Check if cluster is available
	@kubectl cluster-info

clean: ## Remove ArgoCD and demo applications
	@kubectl delete namespace argocd --ignore-not-found=true
	@kubectl delete namespace demo-app --ignore-not-found=true

validate: ## Validate Kubernetes manifests
	@find . -name "*.yaml" -not -path "./.*" | head -5 | xargs kubectl --dry-run=client apply -f
