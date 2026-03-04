#!/bin/zsh
set -euo pipefail

repo_url="https://github.com/MatthewDolan/dotfiles.git"

# Determine where this script lives on disk.
script_dir="$(cd "$(dirname "$0")" && pwd)"

# If the script isn't part of a git repository, clone and run from ~/.dotfiles.
if ! git -C "${script_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  target="${HOME}/.dotfiles"
  echo "Cloning dotfiles repository to ${target}..."
  if [[ ! -d "${target}" ]]; then
    git clone --depth=1 "${repo_url}" "${target}"
  fi

  if ! git -C "${target}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: ${target} exists but is not a git repository." >&2
    exit 1
  fi

  exec "${target}/home/bin/dol" install "$@"
fi

exec "${script_dir}/home/bin/dol" install "$@"
