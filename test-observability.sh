#!/bin/bash

# Observability Stack Test Script
# This script tests all monitoring components to ensure they're working properly

set -e

echo "🧪 Testing Observability Stack..."
echo "=================================="

# Test Prometheus
echo "🔍 Testing Prometheus..."
PROM_HEALTH=$(kubectl exec -n monitoring deployment/prometheus -- wget -qO- http://localhost:9090/-/healthy 2>/dev/null)
if [[ "$PROM_HEALTH" == "Prometheus Server is Healthy." ]]; then
    echo "✅ Prometheus is healthy"
else
    echo "❌ Prometheus health check failed"
    exit 1
fi

# Test Grafana
echo "📈 Testing Grafana..."
GRAFANA_HEALTH=$(kubectl exec -n monitoring deployment/grafana -- wget -qO- http://localhost:3000/api/health 2>/dev/null)
if echo "$GRAFANA_HEALTH" | grep -q '"database": "ok"'; then
    echo "✅ Grafana is healthy"
else
    echo "❌ Grafana health check failed"
    echo "Debug: $GRAFANA_HEALTH"
    exit 1
fi

# Test Prometheus targets
echo "🎯 Testing Prometheus targets..."
TARGET_COUNT=$(kubectl exec -n monitoring deployment/prometheus -- wget -qO- "http://localhost:9090/api/v1/targets" 2>/dev/null | grep -o '"health":"up"' | wc -l)
if [[ "$TARGET_COUNT" -gt 0 ]]; then
    echo "✅ Prometheus has $TARGET_COUNT healthy targets"
else
    echo "❌ No healthy Prometheus targets found"
    exit 1
fi

# Test Grafana can reach Prometheus
echo "🔗 Testing Grafana → Prometheus connectivity..."
GRAFANA_TO_PROM=$(kubectl exec -n monitoring deployment/grafana -- wget -qO- http://prometheus-service:9090/-/healthy 2>/dev/null)
if [[ "$GRAFANA_TO_PROM" == "Prometheus Server is Healthy." ]]; then
    echo "✅ Grafana can reach Prometheus"
else
    echo "❌ Grafana cannot reach Prometheus"
    exit 1
fi

# Test Node Exporter
echo "📊 Testing Node Exporter..."
NODE_EXPORTER_COUNT=$(kubectl get pods -n monitoring -l app=node-exporter --no-headers | wc -l)
if [[ "$NODE_EXPORTER_COUNT" -gt 0 ]]; then
    echo "✅ Node Exporter has $NODE_EXPORTER_COUNT running instances"
else
    echo "❌ No Node Exporter instances found"
    exit 1
fi

# Test Kube State Metrics
echo "📋 Testing Kube State Metrics..."
KSM_STATUS=$(kubectl get pods -n monitoring -l app=kube-state-metrics --no-headers | awk '{print $3}' | head -1)
if [[ "$KSM_STATUS" == "Running" ]]; then
    echo "✅ Kube State Metrics is running"
else
    echo "❌ Kube State Metrics is not running (Status: $KSM_STATUS)"
    exit 1
fi

# Test basic metrics query
echo "📈 Testing metrics query..."
METRICS_RESULT=$(kubectl exec -n monitoring deployment/prometheus -- wget -qO- "http://localhost:9090/api/v1/query?query=up" 2>/dev/null | grep -o '"value":\[[^]]*\]' | wc -l)
if [[ "$METRICS_RESULT" -gt 0 ]]; then
    echo "✅ Prometheus can query metrics successfully ($METRICS_RESULT results)"
else
    echo "❌ Prometheus metrics query failed"
    exit 1
fi

# Display access information
echo ""
echo "🌐 Access Information:"
echo "====================="
PROM_NODEPORT=$(kubectl get svc prometheus-service -n monitoring -o jsonpath='{.spec.ports[0].nodePort}')
GRAFANA_NODEPORT=$(kubectl get svc grafana-service -n monitoring -o jsonpath='{.spec.ports[0].nodePort}')

echo "🔍 Prometheus (internal): http://prometheus-service.monitoring.svc.cluster.local:9090"
echo "📈 Grafana (internal): http://grafana-service.monitoring.svc.cluster.local:3000"
echo ""
echo "🏠 Local Access (via port-forward):"
echo "   kubectl port-forward -n monitoring svc/prometheus-service 9090:9090"
echo "   kubectl port-forward -n monitoring svc/grafana-service 3000:3000"
echo ""
echo "🔑 Grafana Credentials:"
echo "   Username: admin"
echo "   Password: admin123"

echo ""
echo "✅ All observability components are working correctly!"
echo "🎉 Observability stack is ready for production use!"
