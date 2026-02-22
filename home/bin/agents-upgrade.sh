#!/bin/zsh
set -euo pipefail

agents_dir="${HOME}/.agents"

# Verify it's a git repository.
if ! git -C "${agents_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: ${agents_dir} is not a git repository." >&2
  exit 1
fi

echo "Upgrading agents from ${agents_dir}..."
git -C "${agents_dir}" pull --ff-only
"${agents_dir}/install.sh"
echo "Agents upgraded successfully."
