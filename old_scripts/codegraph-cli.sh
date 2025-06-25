#!/bin/bash
# CodeGraph CLI Tool

GRAPHQL_ENDPOINT="http://localhost:4000/graphql"

case "$1" in
  "stats")
    echo "📊 CodeGraph Statistics:"
    curl -s -X POST $GRAPHQL_ENDPOINT \
      -H "Content-Type: application/json" \
      -d '{"query": "{ graphStats { totalNodes totalEdges nodes { label count } } }"}' | \
      jq -r '.data.graphStats | "Total Nodes: \(.totalNodes)\nTotal Edges: \(.totalEdges)\n\nNode Distribution:" as $header | $header, (.nodes[] | "  \(.label): \(.count)")'
    ;;
    
  "health")
    echo "🏥 System Health Check:"
    echo -n "  GraphQL API: "
    curl -s http://localhost:4000/health > /dev/null && echo "✅ Online" || echo "❌ Offline"
    echo -n "  Python Analysis: "
    curl -s http://localhost:8000/health > /dev/null && echo "✅ Online" || echo "❌ Offline"
    ;;
    
  *)
    echo "🚀 CodeGraph CLI"
    echo "Usage: $0 <stats|health>"
    ;;
esac
