#!/bin/bash
set -e

echo "🖥️  CodeGraph New Machine Setup"
echo "=============================="

# Check prerequisites
echo "Checking prerequisites..."

check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 not found. Please install $1"
        return 1
    else
        echo "✅ $1 found"
        return 0
    fi
}

MISSING_DEPS=0
check_command docker || MISSING_DEPS=1
check_command node || MISSING_DEPS=1
check_command python3 || MISSING_DEPS=1
check_command poetry || MISSING_DEPS=1
check_command git || MISSING_DEPS=1

if [ $MISSING_DEPS -eq 1 ]; then
    echo ""
    echo "Please install missing dependencies first."
    exit 1
fi

# Initialize and update submodules
echo ""
echo "Initializing submodules..."
git submodule init
git submodule update --recursive

# Setup environment
echo ""
echo "Setting up environment..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo ""
    echo "⚠️  IMPORTANT: Edit .env and add your OpenAI API key"
    echo "Press enter when done..."
    read
fi

# Install dependencies
echo "Installing dependencies..."

# API dependencies
if [ -d "codegraph-api" ]; then
    echo "Installing API dependencies..."
    cd codegraph-api
    npm install
    cd ..
fi

# Analysis dependencies
if [ -d "codegraph-analysis" ]; then
    echo "Installing Analysis dependencies..."
    cd codegraph-analysis
    poetry install
    cd ..
fi

# Generate protocol buffers
if [ -d "codegraph-proto" ]; then
    echo "Generating protocol buffers..."
    cd codegraph-proto
    ./scripts/generate.sh
    cd ..
fi

echo ""
echo "✅ Machine setup complete!"
echo ""
echo "Next steps:"
echo "1. Run: ./scripts/start-dev.sh"
echo "2. Open: http://localhost:4000/dashboard/"
echo "3. Start coding! 🚀"
