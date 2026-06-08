#!/usr/bin/env bash
set -euo pipefail

cd /home/ubuntu/obsidian-vault

# Check if there are changes
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "Auto-commit: Hermes analysis updates"
  
  # Check if remote origin is configured
  if git remote | grep -q 'origin'; then
    # Try to push to master or current branch
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    git push origin "$BRANCH" || echo "Git push failed, remote might be unreachable."
  else
    echo "No remote origin configured yet. Committed locally."
  fi
fi
