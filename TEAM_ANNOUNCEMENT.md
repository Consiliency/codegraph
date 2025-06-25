# 🚀 CodeGraph is Ready for Development!

## Repository Links
- **Main Repository**: https://github.com/Consiliency/codegraph
- **Core Engine**: https://github.com/Consiliency/codegraph-core
- **API Server**: https://github.com/Consiliency/codegraph-api
- **Analysis Service**: https://github.com/Consiliency/codegraph-analysis
- **Proto Definitions**: https://github.com/Consiliency/codegraph-proto
- **Infrastructure**: https://github.com/Consiliency/codegraph-deploy

## Getting Started

```bash
# Clone with all submodules
git clone --recursive https://github.com/Consiliency/codegraph
cd codegraph

# Set up your environment
cp .env.example .env
# Add your OpenAI API key to .env (get from team lead)

# Run setup
./scripts/setup-new-machine.sh

# Start development
./scripts/start-dev.sh
```

## What's Working
- ✅ Multi-language AST parsing (Python, JavaScript, TypeScript)
- ✅ Semantic code search with OpenAI embeddings
- ✅ Graph database for code relationships
- ✅ Real-time dashboard at http://localhost:4000/dashboard/
- ✅ GraphQL API at http://localhost:4000/graphql

## Development Tools
- **Cursor IDE**: Full project context in `.cursorrules`
- **Claude Code**: Instructions in `CLAUDE.md` and `.claude/`
- **Quick Reference**: See `QUICK_REFERENCE.md`

## Next Steps
1. Check out `ONBOARDING.md` for the full checklist
2. Review the architecture in the main `README.md`
3. Pick an issue from GitHub Issues to work on
4. Join #codegraph-dev on Slack

Welcome to the team! 🎉
