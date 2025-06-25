# Git Submodules Cheat Sheet

## For Team Members

### First Time Clone
```bash
git clone --recursive https://github.com/Consiliency/codegraph
```

### Daily Workflow
```bash
# Pull latest changes including submodules
git pull
git submodule update --init --recursive
```

### Making Changes in a Submodule
```bash
# 1. Go to the submodule
cd codegraph-api

# 2. Make your changes
git add .
git commit -m "feat: my changes"
git push origin main

# 3. Go back to main repo
cd ..

# 4. Update the submodule reference
git add codegraph-api
git commit -m "chore: update codegraph-api"
git push origin main
```

### Common Issues

**Submodule directory is empty:**
```bash
git submodule update --init
```

**Submodule is at wrong commit:**
```bash
git submodule update
```

**See all submodule status:**
```bash
git submodule status
```
