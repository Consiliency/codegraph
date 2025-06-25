#!/bin/bash
set -e

echo "🔍 Running pre-push checks..."
echo "============================="

ISSUES=0

# Check for secrets
echo "Checking for exposed secrets..."
for dir in codegraph-*/; do
    if [ ! -d "${dir}.git" ]; then
        continue
    fi
    
    cd "$dir"
    repo_name=$(basename "$dir")
    
    # Check if .env is tracked
    if git ls-files | grep -q "^\.env$"; then
        echo "❌ .env file is tracked in $repo_name!"
        ISSUES=1
    fi
    
    cd ..
done

# Check for large files
echo ""
echo "Checking for large files..."
for dir in codegraph-*/; do
    if [ ! -d "${dir}.git" ]; then
        continue
    fi
    
    cd "$dir"
    repo_name=$(basename "$dir")
    
    # Find files larger than 10MB
    large_files=$(find . -type f -size +10M -not -path "./.git/*" -not -path "./node_modules/*" -not -path "./.venv/*" 2>/dev/null)
    if [ ! -z "$large_files" ]; then
        echo "⚠️  Large files found in $repo_name:"
        echo "$large_files"
    fi
    
    cd ..
done

if [ $ISSUES -eq 0 ]; then
    echo ""
    echo "✅ All checks passed! Safe to push."
else
    echo ""
    echo "❌ Issues found! Please fix before pushing."
    exit 1
fi
