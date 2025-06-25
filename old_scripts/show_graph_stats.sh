#!/bin/bash

echo "╔════════════════════════════════════════════════╗"
echo "║         CodeGraph/USA System Status            ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Get stats via GraphQL
STATS=$(curl -s -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ graphStats { totalNodes totalEdges nodes { label count } } }"}' | \
  jq -r '.data.graphStats')

TOTAL_NODES=$(echo "$STATS" | jq -r '.totalNodes')
TOTAL_EDGES=$(echo "$STATS" | jq -r '.totalEdges')

echo "┌─────────────────────────┬──────────────────────┐"
echo "│ 📊 Total Nodes         │ $(printf '%20s' "$TOTAL_NODES") │"
echo "│ 🔗 Total Edges         │ $(printf '%20s' "$TOTAL_EDGES") │"
echo "└─────────────────────────┴──────────────────────┘"
echo ""
echo "📂 Node Distribution:"
echo "├─────────────────────────────────────────────────"

echo "$STATS" | jq -r '.nodes[] | "│ " + .label + ": " + (.count|tostring)' | \
while read line; do
    printf "%-49s│\n" "$line"
done

echo "└─────────────────────────────────────────────────"
echo ""
echo "🌐 Service URLs:"
echo "├─ Dashboard: http://localhost:4000/dashboard/"
echo "├─ GraphQL:   http://localhost:4000/graphql"
echo "├─ Memgraph:  http://localhost:3000"
echo "└─ Qdrant:    http://localhost:6333/dashboard"
