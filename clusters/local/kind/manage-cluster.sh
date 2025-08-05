#!/bin/bash

# Kind Cluster Management Script for GitOps Demo
set -e

CLUSTER_NAME="dev"
CONFIG_FILE="cluster-config.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kind is installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v kind &> /dev/null; then
        print_error "Kind is not installed. Please install Kind first."
        exit 1
    fi
    
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    print_success "All prerequisites are installed"
}

# Create the cluster
create_cluster() {
    print_status "Creating Kind cluster '$CLUSTER_NAME'..."
    
    # Check if cluster already exists
    if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        print_warning "Cluster '$CLUSTER_NAME' already exists. Use 'delete' command first if you want to recreate it."
        return 1
    fi
    
    # Create storage directory
    sudo mkdir -p /tmp/kind-dev-storage
    sudo chmod 777 /tmp/kind-dev-storage
    
    # Create the cluster
    kind create cluster --config="${CONFIG_FILE}" --name="${CLUSTER_NAME}"
    
    # Wait for cluster to be ready
    print_status "Waiting for cluster to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    print_success "Cluster '$CLUSTER_NAME' created successfully!"
    
    # Display cluster info
    show_cluster_info
}

# Delete the cluster
delete_cluster() {
    print_status "Deleting Kind cluster '$CLUSTER_NAME'..."
    
    if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        print_warning "Cluster '$CLUSTER_NAME' does not exist."
        return 1
    fi
    
    kind delete cluster --name="${CLUSTER_NAME}"
    print_success "Cluster '$CLUSTER_NAME' deleted successfully!"
}

# Show cluster information
show_cluster_info() {
    print_status "Cluster Information:"
    echo ""
    echo "Cluster Name: $CLUSTER_NAME"
    echo "Nodes:"
    kubectl get nodes -o wide
    echo ""
    echo "Cluster Info:"
    kubectl cluster-info
    echo ""
    echo "Context:"
    kubectl config current-context
}

# Load Docker images into the cluster
load_images() {
    print_status "Loading commonly used images into the cluster..."
    
    # List of common images to preload
    images=(
        "nginx:1.21"
        "redis:7-alpine"
        "postgres:15-alpine"
    )
    
    for image in "${images[@]}"; do
        print_status "Loading image: $image"
        docker pull "$image"
        kind load docker-image "$image" --name="${CLUSTER_NAME}"
    done
    
    print_success "Images loaded successfully!"
}

# Install Ingress NGINX Controller
install_ingress() {
    print_status "Installing Ingress NGINX Controller..."
    
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    
    print_status "Waiting for Ingress NGINX Controller to be ready..."
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    
    print_success "Ingress NGINX Controller installed successfully!"
}

# Install local storage provisioner
install_storage() {
    print_status "Installing local storage provisioner..."
    
    kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml
    
    # Set as default storage class
    kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    
    print_success "Local storage provisioner installed successfully!"
}

# Setup complete cluster with addons
setup_complete() {
    check_prerequisites
    create_cluster
    install_ingress
    install_storage
    load_images
    
    print_success "Complete cluster setup finished!"
    echo ""
    print_status "Next steps:"
    echo "1. Run 'make install' to deploy ArgoCD"
    echo "2. Use 'make port-forward' to access ArgoCD UI"
    echo "3. Access applications via http://localhost (Ingress)"
}

# Show help
show_help() {
    echo "Kind Cluster Management for GitOps Demo"
    echo ""
    echo "Usage: $0 {create|delete|info|load-images|install-ingress|install-storage|setup|help}"
    echo ""
    echo "Commands:"
    echo "  create           Create the Kind cluster"
    echo "  delete           Delete the Kind cluster"
    echo "  info             Show cluster information"
    echo "  load-images      Load common Docker images into cluster"
    echo "  install-ingress  Install Ingress NGINX Controller"
    echo "  install-storage  Install local storage provisioner"
    echo "  setup            Complete setup (create + all addons)"
    echo "  help             Show this help message"
}

# Main script logic
case "${1:-help}" in
    create)
        check_prerequisites
        create_cluster
        ;;
    delete)
        delete_cluster
        ;;
    info)
        show_cluster_info
        ;;
    load-images)
        load_images
        ;;
    install-ingress)
        install_ingress
        ;;
    install-storage)
        install_storage
        ;;
    setup)
        setup_complete
        ;;
    help|*)
        show_help
        ;;
esac
