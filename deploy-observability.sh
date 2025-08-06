#!/bin/bash

# Observability Stack Deployment Script
# This script deploys Prometheus, Grafana, and related monitoring components

set -e

echo "🔍 Deploying Observability Stack..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if cluster is running
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes cluster is not accessible"
    echo "Please ensure your Kind cluster is running: cd kind && ./cluster-manager.sh"
    exit 1
fi

# Create monitoring namespace if it doesn't exist
echo "📦 Creating monitoring namespace..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Deploy observability stack using kustomize
echo "🚀 Deploying monitoring components..."
kubectl apply -k observability/

# Wait for deployments to be ready
echo "⏳ Waiting for Prometheus to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring

echo "⏳ Waiting for Grafana to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

echo "⏳ Waiting for Kube State Metrics to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kube-state-metrics -n monitoring

# Wait for DaemonSet
echo "⏳ Waiting for Node Exporter to be ready..."
kubectl rollout status daemonset/node-exporter -n monitoring --timeout=300s

# Get service information
echo ""
echo "✅ Observability Stack deployed successfully!"
echo ""
echo "📊 Access Information:"
echo "===================="

# Prometheus
PROMETHEUS_PORT=$(kubectl get svc prometheus-service -n monitoring -o jsonpath='{.spec.ports[0].nodePort}')
echo "🔍 Prometheus: http://localhost:9090 (NodePort: ${PROMETHEUS_PORT})"
echo "   Internal: http://prometheus-service.monitoring.svc.cluster.local:9090"

# Grafana
GRAFANA_PORT=$(kubectl get svc grafana-service -n monitoring -o jsonpath='{.spec.ports[0].nodePort}')
echo "📈 Grafana: http://localhost:3000 (NodePort: ${GRAFANA_PORT})"
echo "   Internal: http://grafana-service.monitoring.svc.cluster.local:3000"
echo "   Username: admin"
echo "   Password: admin123"

echo ""
echo "🎯 Available Dashboards:"
echo "========================"
echo "• Kubernetes Cluster Overview - Custom dashboard with cluster metrics"
echo "• Import additional dashboards from Grafana.com:"
echo "  - Kubernetes cluster monitoring (ID: 7249)"
echo "  - Node Exporter Full (ID: 1860)"
echo "  - ArgoCD Dashboard (ID: 14584)"
echo "  - NGINX Ingress Controller (ID: 9614)"

echo ""
echo "📋 Monitoring Components Status:"
echo "================================"
kubectl get pods -n monitoring

echo ""
echo "🔗 Quick Commands:"
echo "=================="
echo "• View Prometheus targets: kubectl port-forward -n monitoring svc/prometheus-service 9090:9090"
echo "• Access Grafana locally: kubectl port-forward -n monitoring svc/grafana-service 3000:3000"
echo "• Check metrics: curl http://localhost:${PROMETHEUS_PORT}/metrics"
echo "• View logs: kubectl logs -n monitoring deployment/prometheus"

echo ""
echo "📚 Best Practices Implemented:"
echo "=============================="
echo "✓ Resource limits and requests set for all components"
echo "✓ ServiceMonitors for automatic service discovery"
echo "✓ RBAC permissions configured properly"
echo "✓ Persistent storage for Grafana (emptyDir for Kind)"
echo "✓ Health checks and readiness probes"
echo "✓ NodePort services for easy local access"
echo "✓ Pre-configured datasources and dashboards"

echo ""
echo "🏆 Observability Stack is ready for GitOps monitoring!"
