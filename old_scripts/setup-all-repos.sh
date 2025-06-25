#!/bin/bash
# setup-all-repos.sh

echo "==================================="
echo "CodeGraph/USA Repository Setup"
echo "==================================="
echo ""

# Check if all setup scripts exist
SCRIPTS=(
    "create-github-repos.sh"
    "setup-codegraph-core.sh"
    "setup-codegraph-api.sh"
    "setup-codegraph-analysis.sh"
    "setup-codegraph-proto.sh"
    "setup-codegraph-deploy.sh"
)

echo "Checking for required scripts..."
for script in "${SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
        echo "❌ Error: $script not found!"
        echo "Please ensure all setup scripts are in the current directory."
        exit 1
    fi
    if [ ! -x "$script" ]; then
        echo "Making $script executable..."
        chmod +x "$script"
    fi
done

echo "✅ All scripts found and executable"
echo ""

# Function to check if a command succeeded
check_status() {
    if [ $? -eq 0 ]; then
        echo "✅ $1 completed successfully!"
    else
        echo "❌ $1 failed! Check the error messages above."
        exit 1
    fi
}

# Create GitHub repositories
echo "Step 1: Creating GitHub repositories..."
echo "======================================="
./create-github-repos.sh
check_status "GitHub repository creation"
echo ""

# Wait a moment for GitHub to fully process the repo creation
echo "Waiting for GitHub to process repository creation..."
sleep 3

# Setup individual repositories
echo "Step 2: Setting up codegraph-core (C++)..."
echo "=========================================="
./setup-codegraph-core.sh
check_status "codegraph-core setup"
echo ""

echo "Step 3: Setting up codegraph-api (TypeScript)..."
echo "==============================================="
./setup-codegraph-api.sh
check_status "codegraph-api setup"
echo ""

echo "Step 4: Setting up codegraph-analysis (Python)..."
echo "================================================"
./setup-codegraph-analysis.sh
check_status "codegraph-analysis setup"
echo ""

echo "Step 5: Setting up codegraph-proto (Protocol Buffers)..."
echo "======================================================="
./setup-codegraph-proto.sh
check_status "codegraph-proto setup"
echo ""

echo "Step 6: Setting up codegraph-deploy (Infrastructure)..."
echo "======================================================"
./setup-codegraph-deploy.sh
check_status "codegraph-deploy setup"
echo ""

# Summary
echo "==================================="
echo "✅ All repositories have been set up successfully!"
echo "==================================="
echo ""
echo "Repository URLs:"
echo "- Core:     https://github.com/Consiliency/codegraph-core"
echo "- API:      https://github.com/Consiliency/codegraph-api"
echo "- Analysis: https://github.com/Consiliency/codegraph-analysis"
echo "- Proto:    https://github.com/Consiliency/codegraph-proto"
echo "- Deploy:   https://github.com/Consiliency/codegraph-deploy"
echo ""
echo "Next steps:"
echo "1. Review and customize each repository's configuration"
echo "2. Set up CI/CD secrets in GitHub:"
echo "   - Go to each repository's Settings > Secrets and variables > Actions"
echo "   - Add necessary secrets (API keys, deployment credentials, etc.)"
echo "3. Configure your local development environment:"
echo "   - Install language-specific dependencies (C++, Node.js, Python)"
echo "   - Install Docker and Docker Compose"
echo "4. Start local development environment:"
echo "   cd codegraph-deploy && make up"
echo "5. Begin implementing core functionality in each service"
echo ""
echo "For detailed documentation, see the README.md in each repository."
echo ""
echo "Happy coding! 🚀"