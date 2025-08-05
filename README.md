# GitOps Demo Repository

This repository demonstrates GitOps best practices using ArgoCD and Kubernetes.

## Repository Structure

```
gitops-demo/
├── kind/                    # Kind cluster configuration (NEW)
│   ├── dev-cluster.yaml    # Multi-node cluster config
│   ├── cluster-manager.sh  # Cluster management script
│   └── README.md           # Kind setup documentation
├── infrastructure/          # Infrastructure components (monitoring, ingress, etc.)
│   ├── argocd/             # ArgoCD installation and configuration
│   ├── monitoring/         # Prometheus, Grafana, etc. (planned)
│   └── ingress/           # Ingress controllers (planned)
├── applications/           # Application definitions
│   ├── app-of-apps/       # ArgoCD App-of-Apps pattern
│   ├── demo-app/          # Sample application
│   └── staging/           # Staging applications (planned)
├── environments/          # Environment-specific configurations
│   ├── dev/               # Development environment
│   ├── staging/           # Staging environment (planned)
│   └── production/        # Production environment (planned)
├── clusters/              # Cluster-specific configurations (planned)
│   ├── local/             # Local development cluster
│   └── cloud/             # Cloud clusters
├── Makefile               # Easy command automation
├── setup.sh               # ArgoCD installation script
└── README.md              # This file
```

## GitOps Principles

1. **Declarative**: Desired state defined in Git
2. **Versioned and Immutable**: Git provides versioning
3. **Pulled Automatically**: ArgoCD pulls changes
4. **Continuously Reconciled**: Automatic sync and healing

## Quick Start

### Prerequisites
- Docker installed and running
- Kind installed (`kind` command available)
- kubectl installed
- Make installed

### 1. Create Local Kubernetes Cluster
```bash
# Create a multi-node Kind cluster named 'dev'
make kind-create

# Check cluster status
make kind-status
```

### 2. Install ArgoCD
```bash
# Install ArgoCD in the cluster
make install

# Check ArgoCD status
make status
```

### 3. Access ArgoCD UI
```bash
# Port-forward to access ArgoCD (runs in foreground)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open browser to: https://localhost:8080
# Username: admin
# Password: Get with: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 4. Deploy Applications
1. Configure ArgoCD to watch this repository
2. Deploy applications using the App-of-Apps pattern
3. Monitor deployments through ArgoCD UI

### 5. Cleanup
```bash
# Delete the Kind cluster
make kind-delete
```

## Available Commands

### Kind Cluster Management
- `make kind-create` - Create Kind cluster
- `make kind-status` - Show cluster status  
- `make kind-delete` - Delete Kind cluster
- `make kind-reset` - Reset cluster (delete and recreate)

### GitOps Operations  
- `make install` - Install ArgoCD
- `make status` - Check ArgoCD status
- `make check-cluster` - Check cluster connection
- `make clean` - Clean up resources
- `make validate` - Validate manifests

## Port Mappings

When using the Kind cluster, the following services are available on localhost:

| Service | Port | URL |
|---------|------|-----|
| ArgoCD UI | 8080 | http://localhost:8080 |
| ArgoCD HTTPS | 8443 | https://localhost:8443 |
| Grafana | 3000 | http://localhost:3000 |
| Prometheus | 9090 | http://localhost:9090 |
| HTTP Ingress | 80 | http://localhost:80 |
| HTTPS Ingress | 443 | https://localhost:443 |

## Tools Used

- **Kind**: Local Kubernetes cluster (v1.33.1)
- **ArgoCD**: GitOps continuous delivery
- **Helm**: Package management
- **Kustomize**: Configuration management
- **Kubernetes**: Container orchestration
- **Docker**: Container runtime

## Features

- ✅ **Multi-node Kind cluster** with proper port mappings
- ✅ **GitOps App-of-Apps pattern** for managing multiple applications
- ✅ **Environment-specific configurations** using Kustomize
- ✅ **Infrastructure as Code** for ArgoCD and monitoring
- ✅ **Automated setup scripts** and Makefile commands
- ✅ **Production-ready structure** following GitOps best practices

## Architecture

This repository implements the **App-of-Apps pattern** where:

1. **Root Application** watches the `applications/app-of-apps/` directory
2. **Child Applications** are automatically created for each component
3. **Environment-specific** configurations override base settings
4. **Infrastructure components** are managed separately from applications

## Development Workflow

1. **Make changes** to application configurations in Git
2. **Commit and push** changes to the repository
3. **ArgoCD automatically detects** changes and syncs cluster state
4. **Monitor deployments** through ArgoCD UI
5. **Validate applications** are running as expected

## Troubleshooting

### Check cluster status
```bash
make kind-status
kubectl get nodes
kubectl get pods -A
```

### ArgoCD issues
```bash
make status
kubectl logs -n argocd deployment/argocd-server
```

### Reset everything
```bash
make kind-reset
make install
```
