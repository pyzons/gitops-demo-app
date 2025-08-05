# E-Commerce Kubernetes Demo Application

This directory contains a complete e-commerce application deployment for Kubernetes, designed to demonstrate various Kubernetes concepts and best practices.

## Architecture

The application consists of:
- **Frontend**: Nginx-based web application with product images
- **Backend**: Three microservices (User, Product, Order services)
- **Database**: MongoDB with persistent storage
- **Ingress**: Nginx Ingress Controller for external access

## Quick Start

### Prerequisites
- EKS cluster running
- kubectl configured to access your cluster
- Sufficient permissions to create namespaces, deployments, services, etc.

### Deployment Options

#### 1. Interactive Step-by-Step Deployment (Recommended for Learning)
```bash
cd ecommerce-k8s/scripts
chmod +x deploy-step-by-step.sh
./deploy-step-by-step.sh
```

This script will guide you through each deployment step with explanations, perfect for learning Kubernetes concepts.

#### 2. Automated Deployment (For CI/CD)
```bash
cd scripts
chmod +x deploy-automated.sh
./deploy-automated.sh
```

This script deploys everything automatically without user interaction.

### Cleanup
```bash
cd scripts
chmod +x cleanup.sh
./cleanup.sh
```

## Components

### Namespaces
- `ecommerce-frontend`: Frontend application
- `ecommerce-backend`: Backend microservices
- `ecommerce-database`: MongoDB database
- `ecommerce-ingress`: Ingress resources

### Frontend
- **Deployment**: `frontend` (3 replicas)
- **Service**: `frontend-service` (ClusterIP)
- **ConfigMaps**: 
  - `frontend-config`: Application configuration
  - `nginx-config`: Nginx configuration
  - `frontend-html`: HTML content
  - `product-images`: Product images (binary data)

### Backend Services
- **User Service**: Handles user management
- **Product Service**: Manages product catalog
- **Order Service**: Processes orders
- Each service includes ConfigMaps for configuration and mock code

### Database
- **MongoDB**: Persistent storage with PVC
- **Service**: Internal communication

### Ingress
- **Nginx Ingress Controller**: External access
- **Load Balancer**: AWS ELB integration

## Recent Fixes

### Issue: Frontend Pods Not Starting
**Problem**: Frontend pods were stuck in `ContainerCreating` status due to missing `product-images` ConfigMap.

**Root Cause**: The deployment script was not applying the `images-configmap.yaml` file, which contains binary image data for the product catalog.

**Solution**: Updated deployment scripts to include:
```bash
kubectl apply -f "$BASE_DIR/frontend/images-configmap.yaml"
```

**Files Modified**:
- `scripts/deploy-step-by-step.sh`: Added images ConfigMap deployment
- `scripts/cleanup.sh`: Added images ConfigMap cleanup
- `scripts/deploy-automated.sh`: New automated deployment script

## Troubleshooting

### Frontend Pods Not Starting
1. Check pod status: `kubectl get pods -n ecommerce-frontend`
2. Describe pod for events: `kubectl describe pod <pod-name> -n ecommerce-frontend`
3. Verify ConfigMaps exist: `kubectl get configmaps -n ecommerce-frontend`
4. Expected ConfigMaps: `frontend-config`, `nginx-config`, `frontend-html`, `product-images`

### Backend Services Not Responding
1. Check service endpoints: `kubectl get endpoints -n ecommerce-backend`
2. Verify MongoDB is running: `kubectl get pods -n ecommerce-database`
3. Check service logs: `kubectl logs deployment/<service-name> -n ecommerce-backend`

### Ingress Not Working
1. Verify ingress controller is running: `kubectl get pods -n ingress-nginx`
2. Check ingress resource: `kubectl get ingress -n ecommerce-frontend`
3. Wait for Load Balancer provisioning (2-3 minutes)

## Learning Objectives

This demo demonstrates:
- ✅ Namespace isolation and organization
- ✅ Multi-tier application architecture
- ✅ Persistent storage with PVCs
- ✅ ConfigMaps for configuration management
- ✅ Services for internal communication
- ✅ Deployments and ReplicaSets
- ✅ Ingress controllers and external access
- ✅ Microservices communication patterns
- ✅ Kubernetes Jobs for data initialization
- ✅ Best practices for production deployments

## Accessing the Application

After successful deployment:

1. Get the Load Balancer URL:
   ```bash
   kubectl get ingress ecommerce-ingress -n ecommerce-frontend
   ```

2. Wait for the Load Balancer to be provisioned (may take 2-3 minutes)

3. Access the application using the provided URL

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify your EKS cluster has sufficient resources
3. Ensure all prerequisites are met
4. Check AWS Load Balancer Controller is properly configured
