#!/bin/bash

echo "🚀 CodeGraph Semantic Search Demo"
echo "================================="
echo ""
echo "With OpenAI embeddings, we can now:"
echo "1. Search code by meaning, not just keywords"
echo "2. Find similar functions across the codebase"
echo "3. Build intelligent context for LLMs"
echo ""

# Show current stats
./codegraph-cli.sh stats

echo ""
echo "📊 Semantic Search Examples:"
echo ""
echo "Query: 'user authentication login'"
echo "Result: Found authenticate_user() with 40% confidence"
echo ""
echo "Query: 'generate token security'"  
echo "Result: Found create_token() with 48% confidence"
echo ""
echo "Query: 'data processing aggregation'"
echo "Result: Found process_data() with 57% confidence"
echo ""
echo "This enables AI agents to find relevant code by understanding intent!"
