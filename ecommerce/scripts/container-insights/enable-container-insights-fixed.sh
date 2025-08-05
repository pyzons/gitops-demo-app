#!/bin/bash

# Container Insights Setup Script for EKS Cluster - CORRECTED VERSION
# This script properly enables Container Insights with correct IAM permissions

set -e

# Configuration
CLUSTER_NAME="my-eks-cluster"
REGION="us-west-2"
NAMESPACE="amazon-cloudwatch"

echo "🔍 Container Insights Setup for EKS Cluster (CORRECTED)"
echo "======================================================="
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo ""

# Step 1: Create CloudWatch namespace
echo "📁 Step 1: Creating CloudWatch namespace"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
echo "✅ CloudWatch namespace ready"

# Step 2: Create custom IAM policy for Container Insights
echo "🔐 Step 2: Creating custom IAM policy for Container Insights"
cat > /tmp/container-insights-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "ec2:DescribeTags",
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes"
            ],
            "Resource": "*"
        }
    ]
}
EOF

# Create the policy (ignore if it already exists)
aws iam create-policy \
    --policy-name ContainerInsightsPolicy \
    --policy-document file:///tmp/container-insights-policy.json \
    --description "Policy for Container Insights with all required permissions" \
    --region $REGION 2>/dev/null || echo "Policy already exists, continuing..."

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/ContainerInsightsPolicy"

# Step 3: Create IAM service accounts with proper permissions
echo "🔐 Step 3: Creating IAM service accounts"

# CloudWatch Agent service account
echo "Creating CloudWatch Agent service account..."
eksctl create iamserviceaccount \
    --name cloudwatch-agent \
    --namespace $NAMESPACE \
    --cluster $CLUSTER_NAME \
    --region $REGION \
    --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
    --attach-policy-arn $POLICY_ARN \
    --approve \
    --override-existing-serviceaccounts

# Fluent Bit service account
echo "Creating Fluent Bit service account..."
eksctl create iamserviceaccount \
    --name fluent-bit \
    --namespace $NAMESPACE \
    --cluster $CLUSTER_NAME \
    --region $REGION \
    --attach-policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
    --attach-policy-arn $POLICY_ARN \
    --approve \
    --override-existing-serviceaccounts

echo "✅ Service accounts and IAM roles configured"

# Step 4: Deploy CloudWatch Agent
echo "📊 Step 4: Deploying CloudWatch Agent"
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml | kubectl apply -f -

curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-serviceaccount.yaml | kubectl apply -f -

# Download and customize the CloudWatch agent config
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-configmap.yaml | \
sed "s/{{cluster_name}}/$CLUSTER_NAME/g" | \
sed "s/{{region_name}}/$REGION/g" | \
kubectl apply -f -

curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml | kubectl apply -f -

echo "✅ CloudWatch Agent deployed"

# Step 5: Deploy Fluent Bit for log collection
echo "📝 Step 5: Deploying Fluent Bit for log collection"
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit-configmap.yaml | \
sed "s/{{cluster_name}}/$CLUSTER_NAME/g" | \
sed "s/{{region_name}}/$REGION/g" | \
kubectl apply -f -

curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml | kubectl apply -f -

# Update Fluent Bit to use correct service account
kubectl patch daemonset fluent-bit -n $NAMESPACE -p '{"spec":{"template":{"spec":{"serviceAccountName":"fluent-bit"}}}}'

echo "✅ Fluent Bit deployed"

# Step 6: Wait for pods to be ready
echo "⏳ Step 6: Waiting for Container Insights components to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cloudwatch-agent -n $NAMESPACE --timeout=300s
kubectl wait --for=condition=ready pod -l k8s-app=fluent-bit -n $NAMESPACE --timeout=300s

echo "✅ All Container Insights components are ready"

# Step 7: Verify deployment
echo "🔍 Step 7: Verifying deployment"
echo ""
echo "CloudWatch Agent pods:"
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=cloudwatch-agent

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
echo ""
echo "⏰ Note: Metrics will appear in 2-3 minutes (not 5-10 minutes as previously stated)"

# Clean up temporary files
rm -f /tmp/container-insights-policy.json
