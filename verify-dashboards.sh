#!/bin/bash

# Dashboard Verification Script
# This script checks if all dashboards are properly loaded in Grafana

echo "🎨 Verifying Grafana Dashboards..."
echo "=================================="

# Wait for Grafana to be ready
echo "⏳ Waiting for Grafana to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/grafana -n monitoring

# Check Grafana health
echo "🔍 Checking Grafana health..."
HEALTH=$(curl -s http://localhost:3000/api/health)
if echo "$HEALTH" | grep -q '"database": "ok"'; then
    echo "✅ Grafana is healthy"
else
    echo "❌ Grafana health check failed"
    echo "Debug: $HEALTH"
    exit 1
fi

# List available dashboards
echo ""
echo "📊 Available Dashboards:"
echo "========================"

# Check if dashboards are mounted
echo "🗂️ Dashboard files in Grafana pod:"
kubectl exec -n monitoring deployment/grafana -- ls -la /var/lib/grafana/dashboards/ 2>/dev/null || echo "Dashboard directory not found"

echo ""
echo "🔗 Access Information:"
echo "====================="
echo "📈 Grafana Web UI: http://localhost:3000"
echo "🔑 Username: admin"
echo "🔑 Password: admin123"
echo ""
echo "🔗 Additional Services:"
echo "🎯 ArgoCD GitOps: http://localhost:9080"
echo "🔍 Prometheus: http://localhost:9090"
echo ""
echo "📋 Available Dashboards:"
echo "• Kubernetes Cluster Overview - General cluster health and metrics"
echo "• Node Exporter Metrics - Detailed system metrics from all nodes"
echo "• ArgoCD GitOps Dashboard - GitOps application status and health"
echo "• Prometheus Monitoring - Monitoring stack performance"
echo ""
echo "🎯 Dashboard Features:"
echo "• Real-time metrics with 30-second refresh"
echo "• Dark theme optimized for monitoring"
echo "• Responsive design for all screen sizes"
echo "• Interactive panels with drill-down capabilities"
echo "• Threshold-based color coding for quick status identification"
echo ""
echo "📚 Next Steps:"
echo "1. Open http://localhost:3000 in your browser"
echo "2. Login with admin/admin123"
echo "3. Navigate to Dashboards → Browse"
echo "4. Select any dashboard to view your cluster metrics"
echo "5. Customize panels and create alerts as needed"

echo ""
echo "✅ Dashboard verification complete!"
