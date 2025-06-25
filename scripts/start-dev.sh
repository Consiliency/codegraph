#!/bin/bash
set -e

echo "🚀 Starting CodeGraph Development Environment"
echo "==========================================="

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

# Check environment
if [ ! -f ".env" ]; then
    echo "⚠️  No .env file found. Creating from template..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "📝 Please edit .env and add your OpenAI API key"
    else
        echo "❌ No .env.example found!"
    fi
    exit 1
fi

# Start infrastructure
echo "🐳 Starting Docker services..."
cd codegraph-deploy
docker-compose up -d
cd ..

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 10

# Start API service
echo "🚀 Starting API service..."
cd codegraph-api
npm run dev &
API_PID=$!
cd ..

# Start Analysis service
echo "🚀 Starting Analysis service..."
cd codegraph-analysis
poetry run uvicorn codegraph_analysis.main:app --reload --port 8000 &
ANALYSIS_PID=$!
cd ..

echo ""
echo "✅ CodeGraph is running!"
echo ""
echo "📊 Access points:"
echo "  Dashboard: http://localhost:4000/dashboard/"
echo "  GraphQL:   http://localhost:4000/graphql"
echo "  Memgraph:  http://localhost:3000"
echo "  Qdrant:    http://localhost:6333/dashboard"
echo ""
echo "🛑 Press Ctrl+C to stop all services"

# Wait and cleanup on exit
trap "kill $API_PID $ANALYSIS_PID 2>/dev/null; cd codegraph-deploy && docker-compose down" EXIT
wait
