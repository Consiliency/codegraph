#!/bin/bash

echo "🔍 CodeGraph Demo Query Runner"
echo "=============================="

execute_query() {
    echo "$1" | docker exec -i codegraph-deploy_memgraph_1 mgconsole | \
    grep -v "^mgconsole" | grep -v "^Type" | grep -v "^Connected" | tail -n +2
}

case "$1" in
  "1")
    echo "📋 All Functions:"
    execute_query "MATCH (f:Function) RETURN f.name as Function, f.file as File ORDER BY f.name;"
    ;;
  
  "2")
    echo "🔗 Function Relationships:"
    execute_query "MATCH (f1:Function)-[r:CALLS]->(f2:Function) RETURN f1.name + ' calls ' + f2.name as Relationship;"
    ;;
  
  "3")
    echo "🏗️ Classes and Their Files:"
    execute_query "MATCH (c:Class)-[:DEFINED_IN]->(file:File) RETURN c.name as Class, file.path as File;"
    ;;
  
  "4")
    echo "📁 File Statistics:"
    execute_query "MATCH (f:File) OPTIONAL MATCH (f)<-[:DEFINED_IN]-(item) RETURN f.path as File, count(item) as Items ORDER BY Items DESC;"
    ;;
  
  "5")
    echo "🔍 Authentication-related Code:"
    execute_query "MATCH (f:Function) WHERE f.name CONTAINS 'auth' RETURN f.name as Function, f.file as File;"
    ;;
  
  "graph")
    echo "📊 Full Graph Overview:"
    execute_query "MATCH (n) RETURN labels(n)[0] as Type, count(*) as Count;"
    ;;
    
  "recent")
    echo "🕒 Recently Added Nodes:"
    execute_query "MATCH (n) RETURN labels(n)[0] as Type, n.name as Name ORDER BY id(n) DESC LIMIT 10;"
    ;;
  
  *)
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  1      - Show all functions"
    echo "  2      - Show function relationships"  
    echo "  3      - Show classes and their files"
    echo "  4      - Show file statistics"
    echo "  5      - Find authentication code"
    echo "  graph  - Graph overview"
    echo "  recent - Recently added nodes"
    ;;
esac
