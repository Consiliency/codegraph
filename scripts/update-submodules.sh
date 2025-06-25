#!/bin/bash
# Helper script for working with submodules

case "$1" in
    "pull")
        echo "Updating all submodules to latest..."
        git submodule update --remote --merge
        ;;
    "push")
        echo "Pushing all submodule changes..."
        git submodule foreach 'git push origin main'
        ;;
    "status")
        echo "Checking status of all submodules..."
        git submodule foreach 'echo "=== $name ===" && git status --short'
        ;;
    *)
        echo "Usage: $0 {pull|push|status}"
        echo "  pull   - Update all submodules to latest"
        echo "  push   - Push all submodule changes"
        echo "  status - Check status of all submodules"
        ;;
esac
