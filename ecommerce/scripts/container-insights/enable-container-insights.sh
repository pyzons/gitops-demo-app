#!/bin/bash

# Container Insights Setup Script for EKS Cluster
# This script enables Container Insights for comprehensive monitoring of all microservices

set -e

# Configuration
CLUSTER_NAME="my-eks-cluster"
REGION="us-west-2"
NAMESPACE="amazon-cloudwatch"

echo "🔍 Container Insights Setup for EKS Cluster"
echo "============================================="
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo ""

# Step 1: Create CloudWatch namespace
echo "📁 Step 1: Creating CloudWatch namespace"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
echo "✅ CloudWatch namespace ready"

# Step 2: Create service account with IAM role for CloudWatch
echo "🔐 Step 2: Setting up IAM role and service account"

# Check if service account already exists
if kubectl get serviceaccount cloudwatch-agent -n $NAMESPACE >/dev/null 2>&1; then
    echo "Service account already exists, skipping creation"
else
    # Create service account with IAM role
    eksctl create iamserviceaccount \
        --name cloudwatch-agent \
        --namespace $NAMESPACE \
        --cluster $CLUSTER_NAME \
        --region $REGION \
        --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
        --approve \
        --override-existing-serviceaccounts
fi
echo "✅ Service account and IAM role configured"

# Step 3: Deploy CloudWatch Agent
echo "📊 Step 3: Deploying CloudWatch Agent"
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml | kubectl apply -f -

curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-serviceaccount.yaml | kubectl apply -f -

# Download and customize the CloudWatch agent config
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-configmap.yaml | \
sed "s/{{cluster_name}}/$CLUSTER_NAME/g" | \
sed "s/{{region_name}}/$REGION/g" | \
kubectl apply -f -

curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml | kubectl apply -f -

echo "✅ CloudWatch Agent deployed"

# Step 4: Deploy Fluent Bit for log collection
echo "📝 Step 4: Deploying Fluent Bit for log collection"
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit-configmap.yaml | \
sed "s/{{cluster_name}}/$CLUSTER_NAME/g" | \
sed "s/{{region_name}}/$REGION/g" | \
kubectl apply -f -

curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml | kubectl apply -f -

echo "✅ Fluent Bit deployed"

# Step 5: Wait for pods to be ready
echo "⏳ Step 5: Waiting for Container Insights components to be ready..."
kubectl wait --for=condition=ready pod -l name=cloudwatch-agent -n $NAMESPACE --timeout=300s
kubectl wait --for=condition=ready pod -l k8s-app=fluent-bit -n $NAMESPACE --timeout=300s

echo "✅ All Container Insights components are ready"

# Step 6: Verify deployment
echo "🔍 Step 6: Verifying deployment"
echo ""
echo "CloudWatch Agent pods:"
kubectl get pods -n $NAMESPACE -l name=cloudwatch-agent

echo ""
echo "Fluent Bit pods:"
kubectl get pods -n $NAMESPACE -l k8s-app=fluent-bit

echo ""
echo "🎉 Container Insights Setup Complete!"
echo ""
echo "📊 Your monitoring setup includes:"
echo "   • Cluster-level metrics (CPU, Memory, Network, Disk)"
echo "   • Node-level metrics"
echo "   • Pod-level metrics for all microservices"
echo "   • Container logs from all namespaces"
echo "   • Application logs from your e-commerce microservices"
echo ""
echo "🔗 Access your metrics in AWS CloudWatch Console:"
echo "   https://console.aws.amazon.com/cloudwatch/home?region=$REGION#container-insights:infrastructure"
echo ""
echo "📈 View your application performance:"
echo "   https://console.aws.amazon.com/cloudwatch/home?region=$REGION#container-insights:performance/EKS:Cluster?~(query~(~'*7b*22clusterName*22*3a*22$CLUSTER_NAME*22*7d)~context~())"
