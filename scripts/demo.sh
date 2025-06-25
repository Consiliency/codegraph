#!/bin/bash

echo "🚀 Starting CodeGraph/USA Demo..."
echo "================================="
echo ""

# Check services
echo "📡 Checking Services..."
if curl -s http://localhost:4000/health > /dev/null; then
    echo "✅ GraphQL API: Online"
else
    echo "❌ GraphQL API: Offline"
fi

if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ Python Analysis: Online"
else
    echo "❌ Python Analysis: Offline"
fi

echo ""
echo "📊 Current Graph Statistics:"
./codegraph-cli.sh stats

echo ""
echo "🌐 Demo URLs:"
echo "├─ Dashboard:    http://localhost:4000/dashboard/"
echo "├─ GraphQL:      http://localhost:4000/graphql"
echo "├─ Memgraph Lab: http://localhost:3000"
echo "└─ Qdrant:       http://localhost:6333/dashboard"

echo ""
echo "📝 Demo Commands:"
echo "├─ Show stats:        ./show_graph_stats.sh"
echo "├─ Run queries:       ./run_demo_query.sh [1-5]"
echo "├─ Ingest more code:  cd codegraph-analysis && poetry run python scripts/ingest_demo.py"
echo "└─ View logs:         cd codegraph && ./codegraph-cli.sh logs"

echo ""
echo "✨ Demo Ready! Open the dashboard in your browser."
