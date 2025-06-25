#!/bin/bash
# Execute Cypher queries on Memgraph

QUERY="$1"

if [ -z "$QUERY" ]; then
    echo "Usage: $0 \"CYPHER QUERY\""
    exit 1
fi

# Use echo to pipe the query into mgconsole
echo "$QUERY" | docker exec -i codegraph-deploy_memgraph_1 mgconsole | grep -v "^mgconsole" | grep -v "^Type" | grep -v "^Connected" | tail -n +2
