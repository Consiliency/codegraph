#!/bin/bash
set -e

echo "🚀 CodeGraph Push to GitHub"
echo "=========================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check if repo exists on GitHub
check_github_repo() {
    local org=$1
    local repo=$2
    if gh repo view "$org/$repo" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

echo "📋 Pre-flight checks..."
echo ""

# Check GitHub CLI auth
if ! gh auth status &>/dev/null; then
    echo -e "${RED}❌ Not authenticated with GitHub CLI${NC}"
    echo "Run: gh auth login"
    exit 1
fi

# Run security check
echo "Running security check..."
if ./scripts/pre-push-check.sh; then
    echo -e "${GREEN}✅ Security check passed${NC}"
else
    echo -e "${RED}❌ Security check failed${NC}"
    exit 1
fi

echo ""
echo "📦 Checking GitHub repositories..."
echo ""

# Check if repos exist on GitHub
REPOS_TO_CREATE=""
if ! check_github_repo "Consiliency" "codegraph"; then
    REPOS_TO_CREATE="$REPOS_TO_CREATE codegraph"
fi

for repo in codegraph-core codegraph-api codegraph-analysis codegraph-proto codegraph-deploy; do
    if ! check_github_repo "Consiliency" "$repo"; then
        REPOS_TO_CREATE="$REPOS_TO_CREATE $repo"
    fi
done

if [ ! -z "$REPOS_TO_CREATE" ]; then
    echo -e "${YELLOW}The following repositories need to be created on GitHub:${NC}"
    for repo in $REPOS_TO_CREATE; do
        echo "  - $repo"
    done
    echo ""
    read -p "Create these repositories now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for repo in $REPOS_TO_CREATE; do
            echo "Creating $repo..."
            if [ "$repo" == "codegraph" ]; then
                gh repo create "Consiliency/$repo" --public --description "CodeGraph/USA - Graph-native semantic code intelligence"
            else
                gh repo create "Consiliency/$repo" --public --description "CodeGraph/USA - ${repo#codegraph-}"
            fi
        done
    else
        echo "Please create the repositories manually and run this script again."
        exit 1
    fi
fi

echo ""
echo "🔗 Setting up remotes..."
echo ""

# Setup main repo remote
if ! git remote | grep -q origin; then
    echo "Adding remote for main repo..."
    git remote add origin https://github.com/Consiliency/codegraph.git
fi

# Setup sub-repo remotes
for dir in codegraph-*/; do
    if [ -d "${dir}.git" ]; then
        cd "$dir"
        repo_name=$(basename "$dir")
        if ! git remote | grep -q origin; then
            echo "Adding remote for $repo_name..."
            git remote add origin "https://github.com/Consiliency/$repo_name.git"
        fi
        cd ..
    fi
done

echo ""
echo "📤 Pushing repositories..."
echo ""

# Push main repo
echo "Pushing main codegraph repository..."
git push -u origin main || echo -e "${YELLOW}Note: You may need to force push if this is the first push${NC}"

# Push each sub-repo
for dir in codegraph-*/; do
    if [ -d "${dir}.git" ]; then
        cd "$dir"
        repo_name=$(basename "$dir")
        echo ""
        echo "Pushing $repo_name..."
        
        # Commit any pending changes
        if ! git diff --quiet || ! git diff --staged --quiet; then
            git add -A
            git commit -m "feat: prepare for team development" || true
        fi
        
        # Push
        git push -u origin main || echo -e "${YELLOW}Note: You may need to force push if this is the first push${NC}"
        cd ..
    fi
done

echo ""
echo -e "${GREEN}✅ All repositories pushed!${NC}"
echo ""
echo "📋 Next Steps for Team Members:"
echo "==============================="
echo ""
echo "1. Clone the main repository:"
echo "   git clone https://github.com/Consiliency/codegraph"
echo "   cd codegraph"
echo ""
echo "2. Get their OpenAI API key and add to .env:"
echo "   cp .env.example .env"
echo "   # Edit .env and add API key"
echo ""
echo "3. Run setup:"
echo "   ./scripts/setup-new-machine.sh"
echo ""
echo "4. Start development:"
echo "   ./scripts/start-dev.sh"
echo ""
echo "📚 Important Links:"
echo "- Main Repo: https://github.com/Consiliency/codegraph"
echo "- Documentation: See README.md and SETUP.md"
echo "- Quick Reference: QUICK_REFERENCE.md"
echo ""
echo "🔐 Security Reminder:"
echo "Share the OpenAI API key securely (not through Git!)"
