# CodeGraph/USA Quick Start Guide

## Prerequisites

1. **GitHub CLI** - Install from https://cli.github.com/
2. **Git** - Version 2.35 or higher
3. **Language Toolchains**:
   - C++ compiler (GCC 11+, Clang 13+, or MSVC 2022+)
   - Node.js 18+ and npm
   - Python 3.11+ and Poetry
   - Protocol Buffers compiler (protoc)
4. **Docker & Docker Compose** - For local development environment

## Setup Instructions

### 1. Authenticate with GitHub

```bash
gh auth login
```

### 2. Download Setup Scripts

Save all the setup scripts to a directory:
- `create-github-repos.sh`
- `setup-codegraph-core.sh`
- `setup-codegraph-api.sh`
- `setup-codegraph-analysis.sh`
- `setup-codegraph-proto.sh`
- `setup-codegraph-deploy.sh`
- `setup-all-repos.sh`

### 3. Make Scripts Executable

```bash
chmod +x *.sh
```

### 4. Run Complete Setup

```bash
./setup-all-repos.sh
```

This will:
1. Create all GitHub repositories
2. Initialize each repository with proper structure
3. Set up CI/CD pipelines
4. Configure development environments
5. Push initial commits

### 5. Start Local Development

```bash
cd codegraph-deploy
make up
```

## Service URLs (Local Development)

After running `make up`:

- **Memgraph Lab**: http://localhost:3000
- **Qdrant Dashboard**: http://localhost:6333/dashboard
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin)
- **RabbitMQ Management**: http://localhost:15672 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001 (admin/admin)
- **Jaeger UI**: http://localhost:16686

## Repository Structure

```
Consiliency/
├── codegraph-core/       # C++ high-performance engine
├── codegraph-api/        # TypeScript GraphQL/REST API
├── codegraph-analysis/   # Python ML workflows
├── codegraph-proto/      # Protocol Buffer definitions
└── codegraph-deploy/     # Infrastructure & deployment
```

## Development Workflow

### Working on Core Engine (C++)
```bash
cd codegraph-core
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make -j$(nproc)
ctest --output-on-failure
```

### Working on API Server (TypeScript)
```bash
cd codegraph-api
npm install
npm run dev
```

### Working on Analysis Service (Python)
```bash
cd codegraph-analysis
poetry install
poetry run uvicorn codegraph_analysis.main:app --reload
```

### Generating Protocol Buffers
```bash
cd codegraph-proto
./scripts/generate.sh
```

## GitHub Actions Secrets

Configure these secrets in each repository's settings:

### All Repositories
- `CODECOV_TOKEN` - For code coverage reporting

### codegraph-api
- `NPM_TOKEN` - If publishing packages

### codegraph-analysis
- `PYPI_TOKEN` - If publishing to PyPI
- `OPENAI_API_KEY` - For ML features

### codegraph-deploy
- `DOCKER_USERNAME` - Docker Hub credentials
- `DOCKER_PASSWORD`
- `KUBECONFIG` - For Kubernetes deployments

## Troubleshooting

### Repository Already Exists
If repositories already exist, the create script will continue. You can manually delete them via GitHub UI or:
```bash
gh repo delete Consiliency/codegraph-<name> --confirm
```

### Permission Denied
Ensure you have write access to the Consiliency organization on GitHub.

### Missing Dependencies
Each setup script will fail gracefully if dependencies are missing. Install the required tools and re-run.

## Next Steps

1. **Implement Core Features**:
   - Tree-sitter integration in codegraph-core
   - GraphQL schema in codegraph-api
   - Analysis workflows in codegraph-analysis

2. **Configure Integrations**:
   - Set up Memgraph connection in all services
   - Configure Qdrant vector database
   - Implement gRPC communication between services

3. **Testing**:
   - Write unit tests for each component
   - Set up integration tests
   - Configure end-to-end testing

4. **Documentation**:
   - API documentation
   - Architecture decision records
   - User guides

## Support

- GitHub Issues: Report bugs and request features
- GitHub Discussions: Ask questions and share ideas
- Documentation: See README.md in each repository