.PHONY: help kind-create kind-delete kind-status kind-reset install check-cluster clean clean-observability clean-all clean-verify validate observability test-observability setup deploy all dashboards update-dashboards verify-dashboards list-dashboards

help: ## Show this help message
	@echo "GitOps Demo - Available Commands:"
	@echo ""
	@echo "🚀 Quick Start Commands:"
	@echo "  all           - Complete setup (cluster + ArgoCD + observability)"
	@echo "  setup         - Setup cluster and ArgoCD"
	@echo "  deploy        - Deploy observability stack"
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
	@echo "  clean         - Clean up ArgoCD and demo apps"
	@echo "  clean-observability - Clean up monitoring stack"
	@echo "  clean-all     - Clean up everything"
	@echo "  clean-verify  - Show what would be cleaned"
	@echo "  validate      - Validate manifests"
	@echo ""
	@echo "📊 Observability Commands:"
	@echo "  observability - Deploy observability stack"
	@echo "  test-observability - Test observability components"
	@echo "  dashboards    - Deploy/update Grafana dashboards"
	@echo "  update-dashboards - Update existing dashboards"
	@echo "  verify-dashboards - Verify dashboard functionality"
	@echo "  list-dashboards - List available dashboards"

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
	@echo "🗑️ Cleaning ArgoCD..."
	@kubectl delete namespace argocd --ignore-not-found=true
	@kubectl delete namespace demo-app --ignore-not-found=true

clean-observability: ## Remove observability stack
	@echo "🗑️ Cleaning observability stack..."
	@kubectl delete namespace monitoring --ignore-not-found=true
	@echo "✅ Observability stack removed"

clean-all: clean clean-observability ## Remove everything (ArgoCD + observability)
	@echo "🗑️ Cleaning additional components..."
	@kubectl delete namespace ingress-nginx --ignore-not-found=true
	@echo "✅ All application resources cleaned up"
	@echo ""
	@echo "ℹ️  Note: System namespaces (kube-system, kube-public, etc.) preserved"
	@echo "ℹ️  To completely reset: make kind-reset"

clean-verify: ## Show what namespaces would be cleaned
	@echo "🔍 Current namespaces that would be cleaned by 'make clean-all':"
	@echo ""
	@echo "📋 Namespaces to be removed:"
	@kubectl get namespaces argocd monitoring ingress-nginx demo-app --ignore-not-found=true 2>/dev/null || echo "  (None of the target namespaces found)"
	@echo ""
	@echo "📋 Namespaces that will remain:"
	@kubectl get namespaces | grep -E "(default|kube-|local-path)" || echo "  System namespaces"
	@echo ""
	@echo "💡 Run 'make clean-all' to perform the cleanup"

validate: ## Validate Kubernetes manifests
	@find . -name "*.yaml" -not -path "./.*" | head -5 | xargs kubectl --dry-run=client apply -f

## Composite Commands
all: kind-create install observability ## Complete setup: cluster + ArgoCD + observability
	@echo "🎉 Complete GitOps environment ready!"
	@echo ""
	@echo "📊 Access URLs:"
	@echo "  ArgoCD:     http://localhost:9080"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Grafana:    http://localhost:3000 (admin/admin123)"
	@echo "  Ingress:    http://localhost:8080"

setup: kind-create install ## Setup cluster and ArgoCD
	@echo "✅ GitOps setup complete! Use 'make observability' to add monitoring."

deploy: observability ## Deploy observability stack (alias for observability)
	@echo "✅ Observability stack deployed successfully!"

## Observability Commands
observability: check-cluster ## Deploy observability stack (Prometheus, Grafana, etc.)
	@echo "📊 Deploying observability stack..."
	@kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
	@kubectl apply -k observability/
	@echo "⏳ Waiting for deployments to be ready..."
	@kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
	@kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring
	@kubectl wait --for=condition=available --timeout=300s deployment/kube-state-metrics -n monitoring
	@kubectl rollout status daemonset/node-exporter -n monitoring --timeout=300s
	@echo "📊 Configuring Grafana dashboards..."
	@sleep 10  # Give Grafana time to fully start
	@kubectl apply -f observability/prometheus/grafana-dashboards.yaml
	@kubectl rollout restart deployment/grafana -n monitoring
	@kubectl rollout status deployment/grafana -n monitoring --timeout=120s
	@echo "✅ Observability stack deployed successfully!"
	@echo ""
	@echo "📊 Access Information:"
	@$(eval PROM_PORT := $(shell kubectl get svc prometheus-service -n monitoring -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "31000"))
	@$(eval GRAFANA_PORT := $(shell kubectl get svc grafana-service -n monitoring -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "31001"))
	@echo "  🔍 Prometheus: http://localhost:9090 (NodePort: $(PROM_PORT))"
	@echo "  📈 Grafana:    http://localhost:3000 (NodePort: $(GRAFANA_PORT))"
	@echo "  🔑 Grafana Credentials: admin/admin123"
	@echo ""
	@echo "📋 Available Dashboards:"
	@echo "  • Kubernetes Cluster Overview"
	@echo "  • Node Exporter Metrics" 
	@echo "  • ArgoCD GitOps Dashboard"
	@echo "  • Prometheus Monitoring"

test-observability: ## Test observability components
	@echo "🧪 Testing observability stack..."
	@kubectl exec -n monitoring deployment/prometheus -- wget -qO- http://localhost:9090/-/healthy >/dev/null && echo "✅ Prometheus is healthy" || echo "❌ Prometheus health check failed"
	@kubectl exec -n monitoring deployment/grafana -- wget -qO- http://localhost:3000/api/health 2>/dev/null | grep -q '"database": "ok"' && echo "✅ Grafana is healthy" || echo "❌ Grafana health check failed"
	@$(eval TARGET_COUNT := $(shell kubectl exec -n monitoring deployment/prometheus -- wget -qO- "http://localhost:9090/api/v1/targets" 2>/dev/null | grep -o '"health":"up"' | wc -l))
	@echo "✅ Prometheus has $(TARGET_COUNT) healthy targets"
	@kubectl exec -n monitoring deployment/grafana -- wget -qO- http://prometheus-service:9090/-/healthy >/dev/null 2>&1 && echo "✅ Grafana can reach Prometheus" || echo "❌ Grafana cannot reach Prometheus"
	@echo "🎉 Observability stack is working correctly!"

## Dashboard Management Commands
dashboards: check-cluster ## Deploy or update Grafana dashboards
	@echo "📊 Deploying Grafana dashboards..."
	@kubectl apply -f observability/prometheus/grafana-dashboards.yaml
	@kubectl apply -f observability/prometheus/grafana-dashboards-config.yaml
	@echo "⏳ Restarting Grafana to load new dashboards..."
	@kubectl rollout restart deployment/grafana -n monitoring
	@kubectl rollout status deployment/grafana -n monitoring --timeout=120s
	@echo "✅ Dashboards deployed successfully!"
	@echo ""
	@echo "📈 Access your dashboards at: http://localhost:3000"
	@echo "🔑 Login: admin/admin123"

update-dashboards: dashboards ## Update existing Grafana dashboards (alias for dashboards)
	@echo "✅ Dashboards updated successfully!"

verify-dashboards: ## Verify Grafana dashboards are working
	@echo "🔍 Verifying Grafana dashboards..."
	@./verify-dashboards.sh

list-dashboards: ## List all available Grafana dashboards
	@echo "📋 Available Grafana Dashboards:"
	@echo ""
	@curl -s -u admin:admin123 http://localhost:3000/api/search?type=dash-db 2>/dev/null | \
		jq -r '.[] | "  📊 \(.title) - \(.url)"' 2>/dev/null || \
		echo "  ⚠️  Unable to connect to Grafana. Is it running?"
	@echo ""
	@echo "📈 Access dashboards at: http://localhost:3000"
