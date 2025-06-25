#!/bin/bash
# setup-codegraph-analysis.sh

REPO_NAME="codegraph-analysis"
GITHUB_ORG="Consiliency"

# Create and enter directory
mkdir -p $REPO_NAME && cd $REPO_NAME

# Initialize git
git init

# Create directory structure
mkdir -p {src/codegraph_analysis/{workflows,pipelines,ml,utils},tests,docs,scripts,.github/workflows}

# Initialize Poetry project
cat > pyproject.toml << 'EOF'
[tool.poetry]
name = "codegraph-analysis"
version = "0.1.0"
description = "Analysis workflows and ML integration for CodeGraph/USA"
authors = ["CodeGraph Team"]
license = "Apache-2.0"
readme = "README.md"
python = "^3.11"

[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.109.0"
uvicorn = "^0.27.0"
celery = {extras = ["redis"], version = "^5.3.0"}
redis = "^5.0.0"
pydantic = "^2.5.0"
numpy = "^1.26.0"
pandas = "^2.1.0"
scikit-learn = "^1.3.0"
langchain = "^0.1.0"
llama-index = "^0.9.0"
openai = "^1.0.0"
qdrant-client = "^1.7.0"
neo4j = "^5.0.0"
httpx = "^0.25.0"
structlog = "^24.0.0"
python-dotenv = "^1.0.0"
typer = "^0.9.0"
rich = "^13.0.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.0"
pytest-cov = "^4.1.0"
pytest-asyncio = "^0.21.0"
pytest-mock = "^3.12.0"
black = "^23.12.0"
ruff = "^0.1.0"
mypy = "^1.8.0"
pre-commit = "^3.6.0"
ipython = "^8.19.0"
jupyter = "^1.0.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

[tool.black]
line-length = 100
target-version = ['py311']

[tool.ruff]
line-length = 100
select = ["E", "F", "W", "C90", "I", "N", "UP", "B", "A", "C4", "DTZ", "ISC", "ICN", "PIE", "T20", "SIM", "RET", "ARG", "PTH", "ERA", "RUF"]
ignore = ["E501", "B008", "B905"]
target-version = "py311"

[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = false
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true

[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]
addopts = "-ra -q --strict-markers --cov=codegraph_analysis --cov-report=term-missing"

[tool.coverage.run]
source = ["src"]
omit = ["*/tests/*", "*/test_*.py"]
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv/
*.egg-info/
dist/
build/
*.egg

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/
.hypothesis/

# Jupyter
.ipynb_checkpoints/
*.ipynb

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Environment
.env
.env.*

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Data
data/
*.csv
*.parquet
*.h5

# ML
models/
checkpoints/
runs/
wandb/
mlruns/
EOF

# Create main application
cat > src/codegraph_analysis/__init__.py << 'EOF'
"""CodeGraph Analysis - ML and workflow orchestration for code understanding."""

__version__ = "0.1.0"
EOF

# Create FastAPI app
cat > src/codegraph_analysis/main.py << 'EOF'
"""Main FastAPI application for CodeGraph Analysis."""

from contextlib import asynccontextmanager
from typing import Any, Dict

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import structlog

from codegraph_analysis import __version__
from codegraph_analysis.workflows import workflow_router
from codegraph_analysis.pipelines import pipeline_router

logger = structlog.get_logger(__name__)


class HealthResponse(BaseModel):
    """Health check response model."""
    status: str
    version: str
    services: Dict[str, str]


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    logger.info("Starting CodeGraph Analysis service", version=__version__)
    yield
    logger.info("Shutting down CodeGraph Analysis service")


app = FastAPI(
    title="CodeGraph Analysis",
    version=__version__,
    lifespan=lifespan,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(workflow_router, prefix="/workflows", tags=["workflows"])
app.include_router(pipeline_router, prefix="/pipelines", tags=["pipelines"])


@app.get("/", response_model=Dict[str, str])
async def root() -> Dict[str, str]:
    """Root endpoint."""
    return {"message": "CodeGraph Analysis API", "version": __version__}


@app.get("/health", response_model=HealthResponse)
async def health() -> HealthResponse:
    """Health check endpoint."""
    return HealthResponse(
        status="healthy",
        version=__version__,
        services={
            "redis": "connected",
            "neo4j": "connected",
            "qdrant": "connected",
        }
    )
EOF

# Create workflow router
cat > src/codegraph_analysis/workflows/__init__.py << 'EOF'
"""Workflow orchestration module."""

from fastapi import APIRouter

workflow_router = APIRouter()


@workflow_router.get("/")
async def list_workflows():
    """List available workflows."""
    return {"workflows": ["code_analysis", "dependency_mapping", "quality_metrics"]}
EOF

# Create pipeline router
cat > src/codegraph_analysis/pipelines/__init__.py << 'EOF'
"""Data pipeline module."""

from fastapi import APIRouter

pipeline_router = APIRouter()


@pipeline_router.get("/")
async def list_pipelines():
    """List available pipelines."""
    return {"pipelines": ["ingestion", "processing", "indexing"]}
EOF

# Create CLI
cat > src/codegraph_analysis/cli.py << 'EOF'
"""Command-line interface for CodeGraph Analysis."""

import typer
from rich import print
from rich.console import Console
from rich.table import Table

from codegraph_analysis import __version__

app = typer.Typer(help="CodeGraph Analysis CLI")
console = Console()


@app.command()
def version():
    """Show version information."""
    print(f"[bold blue]CodeGraph Analysis[/bold blue] version {__version__}")


@app.command()
def analyze(
    repository: str = typer.Argument(..., help="Repository path to analyze"),
    output: str = typer.Option("./output", help="Output directory"),
):
    """Analyze a code repository."""
    console.print(f"Analyzing repository: [green]{repository}[/green]")
    console.print(f"Output directory: [blue]{output}[/blue]")
    # Implementation here


if __name__ == "__main__":
    app()
EOF

# Create test structure
cat > tests/conftest.py << 'EOF'
"""Pytest configuration and fixtures."""

import pytest
from fastapi.testclient import TestClient

from codegraph_analysis.main import app


@pytest.fixture
def client():
    """Create a test client."""
    with TestClient(app) as client:
        yield client
EOF

cat > tests/test_main.py << 'EOF'
"""Tests for main application."""

def test_root(client):
    """Test root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    assert "version" in response.json()


def test_health(client):
    """Test health endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "services" in data
EOF

# Create README.md
cat > README.md << 'EOF'
# CodeGraph Analysis

ML-powered analysis workflows and data pipelines for CodeGraph/USA.

## Features

- **Workflow Orchestration**: Celery-based distributed task processing
- **ML Integration**: LangChain and LlamaIndex for intelligent code analysis
- **Data Pipelines**: Scalable data processing with Pandas and NumPy
- **REST API**: FastAPI-based service for triggering analyses
- **CLI Tools**: Rich command-line interface for operations

## Requirements

- Python 3.11+
- Poetry for dependency management
- Redis for task queue
- Docker (optional)

## Installation

```bash
poetry install
```

## Development

```bash
# Start API server
poetry run uvicorn codegraph_analysis.main:app --reload

# Run tests
poetry run pytest

# Format code
poetry run black src tests
poetry run ruff src tests
```

## CLI Usage

```bash
poetry run python -m codegraph_analysis.cli analyze /path/to/repo
```

## Testing

```bash
poetry run pytest
poetry run pytest --cov  # with coverage
```

## License

Apache License 2.0
EOF

# Create GitHub Actions workflow
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.11", "3.12"]

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install Poetry
      uses: snok/install-poetry@v1
      with:
        version: latest
        virtualenvs-create: true
        virtualenvs-in-project: true

    - name: Load cached venv
      id: cached-poetry-dependencies
      uses: actions/cache@v3
      with:
        path: .venv
        key: venv-${{ runner.os }}-${{ matrix.python-version }}-${{ hashFiles('**/poetry.lock') }}

    - name: Install dependencies
      if: steps.cached-poetry-dependencies.outputs.cache-hit != 'true'
      run: poetry install --no-interaction --no-root

    - name: Install project
      run: poetry install --no-interaction

    - name: Lint with ruff
      run: poetry run ruff src tests

    - name: Format check with black
      run: poetry run black --check src tests

    - name: Type check with mypy
      run: poetry run mypy src

    - name: Test with pytest
      run: poetry run pytest --cov

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      if: matrix.python-version == '3.11'
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-slim as builder

WORKDIR /app

RUN pip install poetry

COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-interaction --no-ansi

COPY . .

FROM python:3.11-slim

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /app /app

EXPOSE 8000

CMD ["uvicorn", "codegraph_analysis.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Initial commit and push
git add .
git commit -m "feat: initial Python analysis service structure"
git branch -M main
git remote add origin "https://github.com/$GITHUB_ORG/$REPO_NAME.git"
git push -u origin main

echo "✅ $REPO_NAME setup complete!"