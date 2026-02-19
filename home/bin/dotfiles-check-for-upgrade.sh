#!/bin/zsh
set -euo pipefail

# Resolve the dotfiles directory by following this script's symlink
script_source="${0}"
if [[ -L "${script_source}" ]]; then
  script_source="$(readlink "${script_source}")"
fi
dotfiles_dir="$(cd "$(dirname "${script_source}")/../.." && pwd)"

# Verify it's a git repository
if ! git -C "${dotfiles_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: ${dotfiles_dir} is not a git repository." >&2
  exit 1
fi

# Fetch latest from remote; exit silently on network failure
if ! git -C "${dotfiles_dir}" fetch --quiet 2>/dev/null; then
  exit 0
fi

# Compare local HEAD to upstream
local_head="$(git -C "${dotfiles_dir}" rev-parse HEAD)"
remote_head="$(git -C "${dotfiles_dir}" rev-parse "@{u}" 2>/dev/null)" || exit 0

if [[ "${local_head}" == "${remote_head}" ]]; then
  exit 0
fi

# Show what's new
echo "Dotfiles updates available:"
git -C "${dotfiles_dir}" log --oneline HEAD.."@{u}"
echo ""

# Prompt for upgrade
read -r -p "Upgrade dotfiles? [y/N] " response
if [[ "${response}" =~ ^[Yy]$ ]]; then
  dotfiles-upgrade.sh
fi
