#!/usr/bin/env bash
set -euo pipefail

cd /home/ubuntu/sajib-obsidian-vault

# 1. First, commit any local changes on the VM to make the working directory clean
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "Auto-commit: Hermes analysis updates"
fi

# 2. Now pull any Mac edits from GitHub (using rebase to keep history clean)
if git remote | grep -q 'origin'; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  git pull origin "$BRANCH" --rebase || echo "Git pull failed, remote might be unreachable."
  
  # 3. Finally, push the merged commits back to GitHub
  git push origin "$BRANCH" || echo "Git push failed, remote might be unreachable."
fi
