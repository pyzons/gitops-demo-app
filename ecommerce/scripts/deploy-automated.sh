#!/bin/bash

# E-Commerce Kubernetes Automated Deployment Script
# Non-interactive version for CI/CD pipelines

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🚀 Starting E-Commerce Kubernetes Automated Deployment"
echo "======================================================"

# Step 1: Create Namespaces
echo "📁 Step 1: Creating Namespaces"
kubectl apply -f "$BASE_DIR/namespaces/namespaces.yaml"
echo "✅ Namespaces created"

# Step 2: Deploy Database Layer
echo "🗄️  Step 2: Deploying Database Layer (MongoDB)"
kubectl apply -f "$BASE_DIR/database/mongodb.yaml"
echo "✅ MongoDB deployed with persistent storage"
echo "Waiting for MongoDB to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mongodb -n ecommerce-database

# Step 3: Deploy Backend Services
echo "🔧 Step 3: Deploying Backend Services"
echo "Deploying User Service..."
kubectl apply -f "$BASE_DIR/backend/user-service.yaml"

echo "Deploying Product Service..."
kubectl apply -f "$BASE_DIR/backend/product-service.yaml"

echo "Deploying Order Service..."
kubectl apply -f "$BASE_DIR/backend/order-service.yaml"

echo "✅ Backend services deployed"
echo "Waiting for backend services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/user-service -n ecommerce-backend
kubectl wait --for=condition=available --timeout=300s deployment/product-service -n ecommerce-backend
kubectl wait --for=condition=available --timeout=300s deployment/order-service -n ecommerce-backend

# Step 4: Initialize Sample Data
echo "📊 Step 4: Initializing Sample Data"
sleep 10  # Wait for services to fully start
kubectl apply -f "$BASE_DIR/backend/init-data-job.yaml"
echo "Waiting for data initialization job to complete..."
kubectl wait --for=condition=complete --timeout=60s job/init-sample-data -n ecommerce-backend
echo "✅ Sample products initialized"

# Step 5: Deploy Frontend
echo "🌐 Step 5: Deploying Frontend Application"
echo "Deploying product images ConfigMap..."
kubectl apply -f "$BASE_DIR/frontend/images-configmap.yaml"

echo "Deploying frontend application..."
kubectl apply -f "$BASE_DIR/frontend/frontend.yaml"
echo "✅ Frontend deployed"
echo "Waiting for frontend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n ecommerce-frontend

# Step 6: Install Nginx Ingress Controller
echo "🔗 Step 6: Installing Nginx Ingress Controller"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/aws/deploy.yaml

echo "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s
echo "✅ Nginx Ingress Controller installed"

# Step 7: Create Ingress
echo "🌍 Step 7: Creating Ingress for External Access"
kubectl apply -f "$BASE_DIR/ingress/ingress-controller.yaml"
echo "✅ Ingress created"

# Step 8: Display Status
echo "📋 Step 8: Deployment Summary"
echo "=============================="

echo "Namespaces:"
kubectl get namespaces | grep ecommerce

echo ""
echo "Pods by Namespace:"
echo "Database Tier:"
kubectl get pods -n ecommerce-database

echo ""
echo "Backend Tier:"
kubectl get pods -n ecommerce-backend

echo ""
echo "Frontend Tier:"
kubectl get pods -n ecommerce-frontend

echo ""
echo "Services:"
kubectl get services --all-namespaces | grep ecommerce

echo ""
echo "Ingress:"
kubectl get ingress -n ecommerce-frontend

echo ""
echo "🎉 E-Commerce Application Deployed Successfully!"
echo ""
echo "To access the application:"
echo "1. Get the Load Balancer URL:"
echo "   kubectl get ingress ecommerce-ingress -n ecommerce-frontend"
echo ""
echo "2. Wait for the Load Balancer to be provisioned (may take 2-3 minutes)"
echo ""
echo "3. Access the application using the provided URL"
