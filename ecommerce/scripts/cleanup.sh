#!/bin/bash

# E-Commerce Kubernetes Cleanup Script

set -e

echo "🧹 Cleaning up E-Commerce Kubernetes Demo"
echo "========================================="

echo "Removing ingress..."
kubectl delete ingress ecommerce-ingress -n ecommerce-frontend --ignore-not-found

echo "Removing AWS Load Balancer Controller..."
helm uninstall aws-load-balancer-controller -n ecommerce-ingress --ignore-not-found

echo "Removing frontend..."
kubectl delete -f ../frontend/images-configmap.yaml --ignore-not-found
kubectl delete -f ../frontend/frontend.yaml --ignore-not-found

echo "Removing backend services..."
kubectl delete -f ../backend/user-service.yaml --ignore-not-found
kubectl delete -f ../backend/product-service.yaml --ignore-not-found
kubectl delete -f ../backend/order-service.yaml --ignore-not-found

echo "Removing database..."
kubectl delete -f ../database/mongodb.yaml --ignore-not-found

echo "Removing namespaces..."
kubectl delete -f ../namespaces/namespaces.yaml --ignore-not-found

echo "✅ Cleanup completed!"