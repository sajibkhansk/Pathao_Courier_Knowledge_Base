#!/usr/bin/env bash
set -euo pipefail

cd /home/ubuntu/sajib-obsidian-vault

# --- 1. Bidirectional Sync of Built-in Memories (MEMORY.md / USER.md) ---
CORE_MEM_DIR="/home/ubuntu/.hermes-sajib/memories"
VAULT_MEM_DIR="/home/ubuntu/sajib-obsidian-vault/06-SYSTEM"

sync_file() {
  local core_file="$1"
  local vault_file="$2"
  
  if [[ -f "$core_file" && -f "$vault_file" ]]; then
    if [[ "$core_file" -nt "$vault_file" ]]; then
      cp "$core_file" "$vault_file"
    elif [[ "$vault_file" -nt "$core_file" ]]; then
      cp "$vault_file" "$core_file"
    fi
  elif [[ -f "$core_file" ]]; then
    cp "$core_file" "$vault_file"
  elif [[ -f "$vault_file" ]]; then
    cp "$vault_file" "$core_file"
  fi
}

sync_file "$CORE_MEM_DIR/MEMORY.md" "$VAULT_MEM_DIR/MEMORY.md"
sync_file "$CORE_MEM_DIR/USER.md" "$VAULT_MEM_DIR/USER.md"
# ------------------------------------------------------------------------

# 2. Commit any local changes on the VM to make the working directory clean
if [[ -n "$(git status --porcelain)" ]]; then
  git add .
  git commit -m "Auto-commit: Hermes analysis updates"
fi

# 3. Pull any Mac edits from GitHub (using rebase to keep history clean)
if git remote | grep -q 'origin'; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  git pull origin "$BRANCH" --rebase || echo "Git pull failed, remote might be unreachable."
  
  # --- 4. Re-sync in case the git pull brought newer vault memory files ---
  sync_file "$CORE_MEM_DIR/MEMORY.md" "$VAULT_MEM_DIR/MEMORY.md"
  sync_file "$CORE_MEM_DIR/USER.md" "$VAULT_MEM_DIR/USER.md"
  # ------------------------------------------------------------------------

  # 5. Push the merged commits back to GitHub
  git push origin "$BRANCH" || echo "Git push failed, remote might be unreachable."
fi
