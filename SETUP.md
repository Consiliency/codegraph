# CodeGraph Development Setup Guide

## Prerequisites

### Required Software
- Docker Desktop 20.10+ (with 8GB RAM allocated)
- Node.js 18+ and npm
- Python 3.11+ and Poetry
- Git and GitHub CLI
- Cursor IDE or VS Code
- (Optional) Claude Code for AI assistance

### Required Accounts
- GitHub account with access to Consiliency org
- OpenAI API key for embeddings

## Initial Setup

### 1. Clone the Repository

    git clone https://github.com/Consiliency/codegraph
    cd codegraph

### 2. Run Setup Script

    ./scripts/setup-dev.sh

This script will:
- Clone all sub-repositories
- Check system requirements
- Create .env from template
- Install dependencies
- Generate protocol buffers
- Initialize databases

### 3. Configure Environment

    cp .env.example .env
    # Edit .env and add your OpenAI API key

### 4. Start Development Environment

    ./scripts/start-dev.sh

## IDE Setup

### Cursor IDE
1. Open Cursor
2. File → Open Folder → Select codegraph directory
3. Cursor will auto-detect the multi-repo structure
4. Install recommended extensions when prompted

### Claude Code
1. Ensure .claude/ directory exists
2. Claude Code will use the assistant instructions automatically
3. Use @codegraph to reference project context

## Development Workflow

### Making Changes
1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes in appropriate repository
3. Run tests: `./scripts/test-affected.sh`
4. Commit with conventional commits: `git commit -m "feat: add new feature"`
5. Push and create PR

### Running Tests

    # Test everything
    ./scripts/test-all.sh

    # Test specific service
    cd codegraph-api && npm test
    cd codegraph-analysis && poetry run pytest

### Debugging
- API logs: `docker logs codegraph_api_1`
- Analysis logs: `docker logs codegraph_analysis_1`
- Memgraph console: http://localhost:3000
- Qdrant dashboard: http://localhost:6333/dashboard

## Common Tasks

### Add New Python Dependency

    cd codegraph-analysis
    poetry add <package>

### Add New NPM Dependency

    cd codegraph-api
    npm install <package>

### Regenerate Protocol Buffers

    cd codegraph-proto
    ./scripts/generate.sh

### Reset Databases

    ./scripts/reset-db.sh

## Troubleshooting

### Port Conflicts
If you see "port already in use":

    # Find and kill process using port
    lsof -ti:4000 | xargs kill -9

### Docker Issues

    # Reset Docker environment
    docker system prune -a
    ./scripts/start-dev.sh

### Missing Dependencies

    # Reinstall all dependencies
    ./scripts/clean-install.sh
