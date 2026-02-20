#!/bin/zsh
set -euo pipefail

repo_url="https://github.com/MatthewDolan/dotfiles.git"

# Determine where this script lives on disk
script_dir="$(cd "$(dirname "$0")" && pwd)"

# If the script isn't part of a git repository, clone and re-run from ~/.dotfiles
if ! git -C "${script_dir}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  target="${HOME}/.dotfiles"
  echo "Cloning dotfiles repository to ${target}..."
  if [[ ! -d "${target}" ]]; then
    git clone --depth=1 "${repo_url}" "${target}"
  fi
  cd "${target}"
  exec ./install.sh "$@"
fi

cd "${script_dir}"

echo "Setting up your Computer..."

# create developer directory
if [[ ! -d "${HOME}/Developer" ]]; then
  echo "Creating a Developer folder..."
  mkdir -p "${HOME}/Developer"
fi

# install oh-my-zsh
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  echo "Installing oh-my-zsh..."
  curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --keep-zshrc
fi

# install hermit
if [[ "${DOLAN_USE_HERMIT:-false}" == "true" ]]; then
  if [[ ! -d "${HOME}/bin/hermit" ]]; then
    echo "Installing hermit..."
    curl -fsSL https://github.com/cashapp/hermit/releases/download/stable/install.sh | /bin/bash
  fi
fi

# symlink files from `./home` to `$HOME`
home_src="${script_dir}/home"
home_dst="${HOME}"

echo "Symlinking files from ${home_src} to ${home_dst}..."

# iterate through all files in $home_src and its subdirectories
find "${home_src}" -type f -print0 | while IFS= read -r -d '' file; do
  dest_dir="$(dirname "${file#"${home_src}/"}")"
  echo "  Symlinking ${file#"${home_src}/"} to \$HOME/${dest_dir}..."
  mkdir -p "${home_dst}/${dest_dir}"
  dest_file="${home_dst}/${dest_dir}/$(basename "${file}")"
  if [[ -e "${dest_file}" && ! -L "${dest_file}" ]]; then
    mkdir -p "${home_dst}/.old/${dest_dir}"
    mv "${dest_file}" "${home_dst}/.old/${dest_dir}/$(basename "${file}")"
  fi
  ln -sf "${file}" "${dest_file}"
done

# install mac os x specific programs
os_name=$(uname)
if [[ "${os_name}" == "Darwin" ]]; then
  echo "Installing Mac OS Software..."

  if ! command -v brew >/dev/null; then
    echo "  Installing Homebrew..."
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash
  fi

  echo "  Showing hidden files in Finder..."
  defaults write com.apple.finder AppleShowAllFiles TRUE
  killall Finder
fi
