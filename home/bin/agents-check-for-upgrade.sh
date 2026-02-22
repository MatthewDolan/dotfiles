#!/bin/zsh
set -euo pipefail

agents_dir="${HOME}/.agents"

# Skip silently when agents repo is not installed.
if [[ ! -d "${agents_dir}" ]]; then
  exit 0
fi

# Verify it's a git repository.
if ! git -C "${agents_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: ${agents_dir} is not a git repository." >&2
  exit 1
fi

# Fetch latest from remote; exit silently on network failure.
if ! git -C "${agents_dir}" fetch --quiet 2>/dev/null; then
  exit 0
fi

# Compare local HEAD to upstream.
local_head="$(git -C "${agents_dir}" rev-parse HEAD)"
remote_head="$(git -C "${agents_dir}" rev-parse '@{u}' 2>/dev/null)" || exit 0

if [[ "${local_head}" == "${remote_head}" ]]; then
  exit 0
fi

# Show what's new.
echo "Agents updates available:"
git -C "${agents_dir}" log --oneline HEAD.."@{u}"
echo ""

# Prompt for upgrade.
read -r -p "Upgrade agents? [y/N] " response
if [[ "${response}" =~ ^[Yy]$ ]]; then
  agents-upgrade.sh
fi
