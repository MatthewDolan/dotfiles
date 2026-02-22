#!/usr/bin/env zsh
# shellcheck disable=SC1091

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
export ZSH_DISABLE_COMPFIX=true

# zsh theme
if [[ ! -v ZSH_THEME ]]; then export ZSH_THEME="robbyrussell"; fi

# zsh plugins
plugins=(
  "${plugins[@]}"
  dotenv
  git
  history
  history-substring-search
  timer
)

# Load the brew plugin only on macOS when brew is available
if [[ "${OSTYPE}" == darwin* ]]; then
  if command -v brew >/dev/null 2>&1; then
    plugins+=(brew)
  fi
fi

# Load the docker plugin only if the docker command is available
if command -v docker >/dev/null 2>&1; then
  plugins+=(docker)
fi

source "${ZSH}"/oh-my-zsh.sh

# User configuration

# Used by some programs (including hermit)
export PATH="${HOME}/bin:${PATH}"

# Add homebrew shell environment
if [[ -f '/opt/homebrew/bin/brew' ]]; then
  brew_env="$(/opt/homebrew/bin/brew shellenv)"
  eval "${brew_env}"
fi

# Set vscode as default editor if Code is available anywhere on PATH
if command -v code >/dev/null 2>&1; then
  export EDITOR="code -w"
fi

# Brew configuration
export HOMEBREW_NO_ENV_HINTS=true

# Git configuration
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh "${fpath[@]}")

# Docker specific configuration
export DOCKER_ID_USER="matthewdolan"
if [[ -f "${HOME}/.docker/init-zsh.sh" ]]; then source "${HOME}/.docker/init-zsh.sh"; fi # Added by Docker Desktop

# Go specific configuration
# Add $GOPATH/bin to path
export GOPATH="${HOME}/go"
if command -v go &>/dev/null; then
  PATH="${GOPATH}/bin:${PATH}"
  export PATH
fi

# Ruby specific configuration
# Add ruby gem home environment variable
export GEM_HOME="${HOME}/.gem"
export PATH="${GEM_HOME}/bin:${PATH}"

# Python specific configuration
# Add python bin to the path
if command -v python3 &>/dev/null; then
  PATH="${PATH}:${HOME}/.local/bin"
  export PATH
fi

# Kubernetes specific configuration
# Set the kubernetes editor in addition to the base editor because for some reason it wasn't working
if command -v code >/dev/null 2>&1; then
  export KUBE_EDITOR="code --wait"
fi

if [[ "${DOLAN_USE_GCLOUD:-false}" == "true" ]]; then
  # Google Cloud SDK specific configuration
  # The next line updates PATH for the Google Cloud SDK.
  if [[ -f "${HOME}/Developer/google-cloud-sdk/path.zsh.inc" ]]; then
    source "${HOME}/Developer/google-cloud-sdk/path.zsh.inc"
  fi
  # The next line enables shell command completion for gcloud.
  if [[ -f "${HOME}/Developer/google-cloud-sdk/completion.zsh.inc" ]]; then
    source "${HOME}/Developer/google-cloud-sdk/completion.zsh.inc"
  fi
fi

if [[ "${DOLAN_USE_HERMIT:-false}" == "true" ]]; then
  # Hermit Shell Hooks (https://github.com/cashapp/hermit)
  # If hermit hasn't been downloaded yet, `$HOME/bin/hermit shell-hooks --print --zsh` will print extraneous information about downloading it.
  # Calling `$HOME/bin/hermit version` first and sending the output to /dev/null will prevent this.
  if test -x "${HOME}"/bin/hermit; then
    "${HOME}"/bin/hermit version > /dev/null
    hermit_hooks="$("${HOME}"/bin/hermit shell-hooks --print --zsh)"
    eval "${hermit_hooks}"
  fi
fi

# Check for dotfiles upgrades (once every 24 hours)
_dotfiles_check_for_upgrade() {
  local stamp_file="${HOME}/.dotfiles-last-update-check"
  local now
  now="$(date +%s)"
  local last_check=0

  if [[ -f "${stamp_file}" ]]; then
    last_check="$(cat "${stamp_file}")"
  fi

  if (( now - last_check >= 86400 )); then
    echo "${now}" > "${stamp_file}"
    dotfiles-check-for-upgrade.sh
  fi
}
_dotfiles_check_for_upgrade

# Check for agents upgrades (once every 24 hours)
_agents_check_for_upgrade() {
  local stamp_file="${HOME}/.agents-last-update-check"
  local now
  now="$(date +%s)"
  local last_check=0

  if [[ -f "${stamp_file}" ]]; then
    last_check="$(cat "${stamp_file}")"
  fi

  if (( now - last_check >= 86400 )); then
    echo "${now}" > "${stamp_file}"
    if command -v agents-check-for-upgrade.sh >/dev/null 2>&1; then
      agents-check-for-upgrade.sh
    fi
  fi
}
_agents_check_for_upgrade

# Source ~/.zshrc.local (not checked into the repo)
# This is where you would put local configuration that's only for this computer.
# For example, sourcing company specific files or setting secret keys as
# environment variables.
if [[ -f "${HOME}/.zshrc.local" ]]; then source "${HOME}"/.zshrc.local; fi
