#!/usr/bin/env bash
set -euo pipefail

cd /home/ubuntu/sajib-obsidian-vault

# 1. Pull changes from GitHub first to stay updated with your Mac edits
if git remote | grep -q 'origin'; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  git pull origin "$BRANCH" --rebase || echo "Git pull failed, remote might be unreachable."
fi

# 2. Commit and push any new files written by the Agent on the VM
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "Auto-commit: Hermes analysis updates"
  
  if git remote | grep -q 'origin'; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    git push origin "$BRANCH" || echo "Git push failed, remote might be unreachable."
  else
    echo "No remote origin configured yet. Committed locally."
  fi
fi
