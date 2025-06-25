# Developer Quick Checklist

## For You (Local Development)
- [ ] Your `.env` file has your OpenAI API key
- [ ] Docker is running
- [ ] You can access http://localhost:4000/dashboard/
- [ ] Semantic search works with your API key

## For Team (Before Pushing)
- [ ] All `.env` files are gitignored
- [ ] `.env.example` templates exist
- [ ] No secrets in code
- [ ] All tests pass

## For New Developers
When they clone, they should:
1. Copy `.env.example` to `.env`
2. Add their OpenAI API key
3. Run `./scripts/setup-new-machine.sh`
4. Run `./scripts/start-dev.sh`

## Cursor IDE Features
- Open the `codegraph` folder
- AI knows project context from `.cursorrules`
- Ignore patterns in `.cursorignore`
- Settings in `.cursor/settings.json`

## Claude Code Features
- Project context in `.claude/project.md`
- Use `@codegraph` to reference the project
- AI understands the architecture

## Quick Commands
```bash
# Start everything
./scripts/start-dev.sh

# Check before push
./scripts/pre-push-check.sh

# Push all repos
./scripts/push-all.sh

# Sync latest
./scripts/sync-repos.sh
```
