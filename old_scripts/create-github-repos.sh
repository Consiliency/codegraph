#!/bin/bash
# create-github-repos.sh

ORG="Consiliency"
REPOS=("codegraph-core" "codegraph-api" "codegraph-analysis" "codegraph-proto" "codegraph-deploy")

echo "Creating GitHub repositories for CodeGraph/USA..."
echo "Organization: $ORG"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub CLI."
    echo "Please run: gh auth login"
    exit 1
fi

# Create repositories
for repo in "${REPOS[@]}"; do
  echo "Creating repository: $repo"
  
  # Define description based on repo name
  case $repo in
    "codegraph-core")
      DESC="High-performance C++ engine for CodeGraph/USA - AST parsing, graph algorithms, and content-addressable storage"
      ;;
    "codegraph-api")
      DESC="GraphQL and REST API server for CodeGraph/USA - Real-time code analysis and graph exploration"
      ;;
    "codegraph-analysis")
      DESC="ML-powered analysis workflows and data pipelines for CodeGraph/USA"
      ;;
    "codegraph-proto")
      DESC="Protocol Buffer definitions and generated code for CodeGraph/USA services"
      ;;
    "codegraph-deploy")
      DESC="Infrastructure and deployment configurations for CodeGraph/USA"
      ;;
  esac
  
  # Create the repository
  gh repo create "$ORG/$repo" \
    --public \
    --description "$DESC" \
    --add-readme=false \
    --clone=false \
    --license apache-2.0 \
    --gitignore "" \
    || echo "Repository $repo may already exist, continuing..."
  
  echo "✅ Repository created: https://github.com/$ORG/$repo"
  echo ""
done

echo "All repositories created successfully!"
echo ""
echo "Next steps:"
echo "1. Run the individual setup scripts to initialize each repository"
echo "2. Or run ./setup-all-repos.sh to set up all repositories at once"