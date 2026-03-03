#!/bin/zsh
set -euo pipefail

WRAPPER_SCRIPT_SOURCE="$0"

resolve_wrapper_dotfiles_dir() {
  local script_source="${WRAPPER_SCRIPT_SOURCE}"
  local source_dir

  if [[ "${script_source}" != */* ]]; then
    script_source="$(command -v -- "${script_source}")"
  fi

  while [[ -L "${script_source}" ]]; do
    source_dir="$(cd -P "$(dirname "${script_source}")" && pwd)"
    script_source="$(readlink "${script_source}")"
    if [[ "${script_source}" != /* ]]; then
      script_source="${source_dir}/${script_source}"
    fi
  done

  cd -P "$(dirname "${script_source}")/../.." && pwd
}

dotfiles_dir="$(resolve_wrapper_dotfiles_dir)"

echo "dotfiles-upgrade.sh is deprecated; forwarding to 'dol update'."
exec "${dotfiles_dir}/home/bin/dol" update "$@"
