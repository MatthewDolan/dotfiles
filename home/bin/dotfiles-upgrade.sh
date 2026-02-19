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

echo "Upgrading dotfiles from ${dotfiles_dir}..."
git -C "${dotfiles_dir}" pull --ff-only
"${dotfiles_dir}/install.sh"
echo "Dotfiles upgraded successfully."
