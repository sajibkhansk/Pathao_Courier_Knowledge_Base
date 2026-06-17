#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/home/ubuntu/Hermes_Knowledge_Base"
LOG_PREFIX="[Hermes KB auto-commit]"

cd "$REPO_DIR"

exec 9>/tmp/hermes_kb_auto_commit.lock
if ! flock -n 9; then
  echo "$LOG_PREFIX another run is already active"
  exit 0
fi

git config user.name "Hermes KB Auto Commit"
git config user.email "hermes-kb-auto@users.noreply.github.com"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

echo "$LOG_PREFIX $(date -Iseconds) branch=$BRANCH"

if git remote | grep -qx origin; then
  git pull origin "$BRANCH" --rebase --autostash || {
    echo "$LOG_PREFIX pull failed; leaving repo untouched for manual review"
    exit 0
  }
fi

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "Auto-commit: Hermes knowledge base updates"
else
  echo "$LOG_PREFIX no local changes"
fi

if git remote | grep -qx origin; then
  git push origin "$BRANCH" || {
    echo "$LOG_PREFIX push failed; check GitHub SSH access or remote permissions"
    exit 0
  }
fi

echo "$LOG_PREFIX done"
