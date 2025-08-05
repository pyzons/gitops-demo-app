# GitOps Demo Repository

This repository demonstrates GitOps best practices using ArgoCD and Kubernetes.

## Repository Structure

```
gitops-demo/
├── infrastructure/          # Infrastructure components (monitoring, ingress, etc.)
│   ├── argocd/             # ArgoCD installation and configuration
│   ├── monitoring/         # Prometheus, Grafana, etc.
│   └── ingress/           # Ingress controllers
├── applications/           # Application definitions
│   ├── app-of-apps/       # ArgoCD App-of-Apps pattern
│   ├── demo-app/          # Sample application
│   └── staging/           # Staging applications
├── environments/          # Environment-specific configurations
│   ├── dev/               # Development environment
│   ├── staging/           # Staging environment
│   └── production/        # Production environment
└── clusters/              # Cluster-specific configurations
    ├── local/             # Local development cluster
    └── cloud/             # Cloud clusters
```

## GitOps Principles

1. **Declarative**: Desired state defined in Git
2. **Versioned and Immutable**: Git provides versioning
3. **Pulled Automatically**: ArgoCD pulls changes
4. **Continuously Reconciled**: Automatic sync and healing

## Getting Started

1. Install ArgoCD in your cluster
2. Configure ArgoCD to watch this repository
3. Deploy applications using the App-of-Apps pattern

## Tools Used

- **ArgoCD**: GitOps continuous delivery
- **Helm**: Package management
- **Kustomize**: Configuration management
- **Kubernetes**: Container orchestration
