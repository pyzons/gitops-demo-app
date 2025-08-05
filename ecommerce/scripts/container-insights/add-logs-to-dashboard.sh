#!/bin/bash

# Add Log Insights widget to the dashboard once logs are flowing
# Run this script after logs have been flowing for a few minutes

set -e

DASHBOARD_NAME="ECommerce-Microservices-Dashboard"
REGION="us-west-2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📊 Adding Log Insights to Dashboard"
echo "==================================="

# Create dashboard with logs widget
cat > "$SCRIPT_DIR/ecommerce-dashboard-with-logs.json" << 'EOF'
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ContainerInsights", "cluster_cpu_utilization", "ClusterName", "my-eks-cluster" ],
                    [ ".", "cluster_memory_utilization", ".", "." ],
                    [ ".", "cluster_network_total_bytes", ".", "." ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "title": "EKS Cluster Overview",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ContainerInsights", "pod_cpu_utilization", "ClusterName", "my-eks-cluster", "Namespace", "ecommerce-backend" ],
                    [ "AWS/ContainerInsights", "pod_cpu_utilization", "ClusterName", "my-eks-cluster", "Namespace", "ecommerce-database" ],
                    [ "AWS/ContainerInsights", "pod_cpu_utilization", "ClusterName", "my-eks-cluster", "Namespace", "ecommerce-frontend" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "title": "Namespace CPU Utilization",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ContainerInsights", "pod_memory_utilization", "ClusterName", "my-eks-cluster", "Namespace", "ecommerce-backend" ],
                    [ "AWS/ContainerInsights", "pod_memory_utilization", "ClusterName", "my-eks-cluster", "Namespace", "ecommerce-database" ],
                    [ "AWS/ContainerInsights", "pod_memory_utilization", "ClusterName", "my-eks-cluster", "Namespace", "ecommerce-frontend" ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "title": "Namespace Memory Utilization",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 6,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ContainerInsights", "pod_network_rx_bytes", "ClusterName", "my-eks-cluster", "Namespace", "ecommerce-backend" ],
                    [ ".", "pod_network_tx_bytes", ".", ".", ".", "." ],
                    [ ".", "pod_network_rx_bytes", ".", ".", "Namespace", "ecommerce-frontend" ],
                    [ ".", "pod_network_tx_bytes", ".", ".", ".", "." ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-west-2",
                "title": "Network I/O by Namespace",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "log",
            "x": 0,
            "y": 12,
            "width": 24,
            "height": 8,
            "properties": {
                "query": "SOURCE '/aws/containerinsights/my-eks-cluster/application'\n| fields @timestamp, kubernetes.namespace_name, kubernetes.pod_name, log\n| filter kubernetes.namespace_name like /ecommerce/\n| sort @timestamp desc\n| limit 50",
                "region": "us-west-2",
                "title": "E-Commerce Application Logs (Last 50 entries)",
                "view": "table"
            }
        }
    ]
}
EOF

echo "🎨 Updating dashboard with log insights..."
aws cloudwatch put-dashboard \
    --region $REGION \
    --dashboard-name "$DASHBOARD_NAME" \
    --dashboard-body file://"$SCRIPT_DIR/ecommerce-dashboard-with-logs.json"

echo "✅ Dashboard updated with log insights!"
echo ""
echo "🔗 Access your updated dashboard:"
echo "https://console.aws.amazon.com/cloudwatch/home?region=$REGION#dashboards:name=$DASHBOARD_NAME"
