#!/bin/bash
# setup-codegraph-deploy.sh

REPO_NAME="codegraph-deploy"
GITHUB_ORG="Consiliency"

# Create and enter directory
mkdir -p $REPO_NAME && cd $REPO_NAME

# Initialize git
git init

# Create directory structure
mkdir -p {docker,kubernetes/{base,overlays/{dev,staging,prod}},terraform/{modules,environments},ansible/{playbooks,roles},scripts,docs,.github/workflows}

# Create .gitignore
cat > .gitignore << 'EOF'
# Terraform
*.tfstate
*.tfstate.*
.terraform/
*.tfvars
!example.tfvars

# Ansible
*.retry
ansible/vault-password

# Secrets
secrets/
*.key
*.pem
*.crt
*.env
!.env.example

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Temporary
*.tmp
*.bak
EOF

# Create docker-compose.yml for local development
cat > docker-compose.yml << 'EOF'
version: '3.9'

services:
  # Graph Database - Memgraph
  memgraph:
    image: memgraph/memgraph:latest
    ports:
      - "7687:7687"
      - "3000:3000"  # Memgraph Lab
    volumes:
      - memgraph_data:/var/lib/memgraph
    environment:
      - MEMGRAPH_LOG_LEVEL=INFO
    command: ["--log-level=INFO", "--also-log-to-stderr"]

  # Vector Database - Qdrant
  qdrant:
    image: qdrant/qdrant:latest
    ports:
      - "6333:6333"
      - "6334:6334"  # gRPC
    volumes:
      - qdrant_data:/qdrant/storage
    environment:
      - QDRANT__LOG_LEVEL=INFO

  # Content Storage - MinIO (S3-compatible)
  minio:
    image: minio/minio:latest
    ports:
      - "9000:9000"
      - "9001:9001"  # Console
    volumes:
      - minio_data:/data
    environment:
      - MINIO_ROOT_USER=minioadmin
      - MINIO_ROOT_PASSWORD=minioadmin
    command: server /data --console-address ":9001"

  # Cache - Redis
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes

  # Message Queue - RabbitMQ
  rabbitmq:
    image: rabbitmq:3-management-alpine
    ports:
      - "5672:5672"
      - "15672:15672"  # Management UI
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=admin

  # Monitoring - Prometheus
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  # Monitoring - Grafana
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false

  # Tracing - Jaeger
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "5775:5775/udp"
      - "6831:6831/udp"
      - "6832:6832/udp"
      - "5778:5778"
      - "16686:16686"  # UI
      - "14268:14268"
      - "14250:14250"
    environment:
      - COLLECTOR_ZIPKIN_HOST_PORT=:9411

volumes:
  memgraph_data:
  qdrant_data:
  minio_data:
  redis_data:
  rabbitmq_data:
  prometheus_data:
  grafana_data:

networks:
  default:
    name: codegraph
EOF

# Create Kubernetes base configuration
cat > kubernetes/base/kustomization.yaml << 'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: codegraph

resources:
  - namespace.yaml
  - configmap.yaml
  - secrets.yaml
  - memgraph.yaml
  - qdrant.yaml
  - api.yaml
  - analysis.yaml
  - ingress.yaml

commonLabels:
  app.kubernetes.io/part-of: codegraph
  app.kubernetes.io/managed-by: kustomize
EOF

cat > kubernetes/base/namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: codegraph
  labels:
    name: codegraph
EOF

cat > kubernetes/base/memgraph.yaml << 'EOF'
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: memgraph
spec:
  serviceName: memgraph
  replicas: 1
  selector:
    matchLabels:
      app: memgraph
  template:
    metadata:
      labels:
        app: memgraph
    spec:
      containers:
      - name: memgraph
        image: memgraph/memgraph:latest
        ports:
        - containerPort: 7687
          name: bolt
        volumeMounts:
        - name: data
          mountPath: /var/lib/memgraph
        resources:
          requests:
            memory: "2Gi"
            cpu: "1"
          limits:
            memory: "4Gi"
            cpu: "2"
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: memgraph
spec:
  ports:
  - port: 7687
    name: bolt
  clusterIP: None
  selector:
    app: memgraph
EOF

# Create Terraform main configuration
cat > terraform/main.tf << 'EOF'
terraform {
  required_version = ">= 1.3.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
  }
}

module "codegraph" {
  source = "./modules/codegraph"
  
  environment     = var.environment
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  
  memgraph_config = var.memgraph_config
  qdrant_config   = var.qdrant_config
  api_config      = var.api_config
  analysis_config = var.analysis_config
}
EOF

# Create Makefile
cat > Makefile << 'EOF'
.PHONY: help up down logs ps clean deploy-dev deploy-staging deploy-prod

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Start local development environment
	docker-compose up -d
	@echo "Services started. Access:"
	@echo "  - Memgraph Lab: http://localhost:3000"
	@echo "  - Qdrant UI: http://localhost:6333/dashboard"
	@echo "  - MinIO Console: http://localhost:9001"
	@echo "  - RabbitMQ Management: http://localhost:15672"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - Grafana: http://localhost:3001"
	@echo "  - Jaeger UI: http://localhost:16686"

down: ## Stop local development environment
	docker-compose down

logs: ## Show logs from all services
	docker-compose logs -f

ps: ## Show status of services
	docker-compose ps

clean: ## Clean up volumes and containers
	docker-compose down -v --remove-orphans

deploy-dev: ## Deploy to development environment
	kubectl apply -k kubernetes/overlays/dev

deploy-staging: ## Deploy to staging environment
	kubectl apply -k kubernetes/overlays/staging

deploy-prod: ## Deploy to production environment
	@echo "Production deployment requires approval"
	@read -p "Deploy to production? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		kubectl apply -k kubernetes/overlays/prod; \
	fi

test-k8s: ## Test Kubernetes manifests
	kubectl apply -k kubernetes/base --dry-run=client

validate-terraform: ## Validate Terraform configuration
	cd terraform && terraform init && terraform validate

backup-dev: ## Backup development databases
	./scripts/backup.sh dev

restore-dev: ## Restore development databases
	./scripts/restore.sh dev
EOF

# Create README.md
cat > README.md << 'EOF'
# CodeGraph Deploy

Infrastructure and deployment configurations for CodeGraph/USA.

## Overview

This repository contains:
- Docker Compose configuration for local development
- Kubernetes manifests for cloud deployment
- Terraform modules for infrastructure provisioning
- Ansible playbooks for configuration management
- Monitoring and observability setup

## Prerequisites

- Docker & Docker Compose
- Kubernetes (kubectl, kustomize)
- Terraform 1.3+
- Ansible 2.9+
- Make

## Quick Start

### Local Development

```bash
# Start all services
make up

# View logs
make logs

# Stop services
make down
```

### Kubernetes Deployment

```bash
# Deploy to development
make deploy-dev

# Deploy to staging
make deploy-staging

# Deploy to production (requires confirmation)
make deploy-prod
```

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Ingress   │────▶│     API     │────▶│    Core     │
└─────────────┘     └─────────────┘     └─────────────┘
                            │                    │
                            ▼                    ▼
                    ┌─────────────┐     ┌─────────────┐
                    │  Analysis   │     │  Memgraph   │
                    └─────────────┘     └─────────────┘
                            │                    │
                            ▼                    ▼
                    ┌─────────────┐     ┌─────────────┐
                    │   Qdrant    │     │   Storage   │
                    └─────────────┘     └─────────────┘
```

## Services

### Core Services
- **Memgraph**: Graph database for code relationships
- **Qdrant**: Vector database for semantic search
- **MinIO**: S3-compatible object storage
- **Redis**: Caching and session storage

### Supporting Services
- **RabbitMQ**: Message queue for async processing
- **Prometheus**: Metrics collection
- **Grafana**: Metrics visualization
- **Jaeger**: Distributed tracing

## Monitoring

Access monitoring dashboards:
- Grafana: http://localhost:3001 (admin/admin)
- Prometheus: http://localhost:9090
- Jaeger: http://localhost:16686

## Security

- All secrets are managed via Kubernetes secrets
- TLS encryption for all external endpoints
- Network policies restrict inter-service communication
- Regular security scanning of container images

## Backup & Recovery

```bash
# Backup development environment
make backup-dev

# Restore from backup
make restore-dev
```

## Contributing

1. Test changes locally using docker-compose
2. Validate Kubernetes manifests: `make test-k8s`
3. Run Terraform plan before applying changes
4. Document any new services or configurations

## License

Apache License 2.0
EOF

# Create monitoring configuration
mkdir -p monitoring
cat > monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'codegraph-api'
    static_configs:
      - targets: ['api:3000']

  - job_name: 'codegraph-analysis'
    static_configs:
      - targets: ['analysis:8000']

  - job_name: 'memgraph'
    static_configs:
      - targets: ['memgraph:7687']

  - job_name: 'qdrant'
    static_configs:
      - targets: ['qdrant:6333']
EOF

# Create backup script
mkdir -p scripts
cat > scripts/backup.sh << 'EOF'
#!/bin/bash

ENVIRONMENT=$1
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="backups/${ENVIRONMENT}/${TIMESTAMP}"

mkdir -p "${BACKUP_DIR}"

echo "Backing up ${ENVIRONMENT} environment..."

# Backup Memgraph
echo "Backing up Memgraph..."
docker exec memgraph mg_dump > "${BACKUP_DIR}/memgraph.cypher"

# Backup Qdrant
echo "Backing up Qdrant..."
docker exec qdrant qdrant-backup create "${BACKUP_DIR}/qdrant"

echo "Backup completed: ${BACKUP_DIR}"
EOF

chmod +x scripts/backup.sh

# Create GitHub Actions workflow
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Validate Docker Compose
      run: docker-compose config

    - name: Validate Kubernetes manifests
      run: |
        kubectl apply -k kubernetes/base --dry-run=client --validate=true

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.3.0

    - name: Terraform Init
      working-directory: terraform
      run: terraform init

    - name: Terraform Validate
      working-directory: terraform
      run: terraform validate

    - name: Terraform Format Check
      working-directory: terraform
      run: terraform fmt -check -recursive

  security:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'config'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'

    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
EOF

# Initial commit and push
git add .
git commit -m "feat: initial deployment configuration"
git branch -M main
git remote add origin "https://github.com/$GITHUB_ORG/$REPO_NAME.git"
git push -u origin main

echo "✅ $REPO_NAME setup complete!"