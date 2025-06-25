#!/bin/bash
set -e

echo "📤 Pushing all repositories to GitHub..."
echo "======================================="

# Push each sub-repo
for dir in codegraph-*/; do
    if [ ! -d "${dir}.git" ]; then
        continue
    fi
    
    repo_name=$(basename "$dir")
    echo ""
    echo "Pushing $repo_name..."
    cd "$dir"
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --staged --quiet; then
        echo "⚠️  Uncommitted changes in $repo_name"
        git status --short
    fi
    
    # Push if we have a remote
    if git remote | grep -q origin; then
        git push origin main || echo "⚠️  Failed to push $repo_name"
    else
        echo "⚠️  No remote 'origin' configured for $repo_name"
    fi
    
    cd ..
done

echo ""
echo "✅ Done!"
echo ""
echo "Note: Make sure each repository exists on GitHub first!"
