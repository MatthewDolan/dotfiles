# Source ~/.zshrc.local (not checked into the repo)
# This is where you would put local configuration that's only for this computer.
# For example, sourcing company specific files or setting secret keys as
# environment variables.
if [ -f "$HOME/.zshrc.local" ]; then source $HOME/.zshrc.local; fi

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# zsh theme
if [[ ! -v ZSH_THEME ]]; then export ZSH_THEME="robbyrussell"; fi

# zsh plugins
plugins=(
  $plugins
  brew
  dotenv
  git
  git-auto-fetch
  github
  golang
  helm
  history
  history-substring-search
  kubectl
  terraform
  timer
)

# Load the docker plugin only if the docker command is available
if command -v docker >/dev/null 2>&1; then
  plugins+=(docker)
fi

source $ZSH/oh-my-zsh.sh

# User configuration

# Used by some programs (including hermit)
export PATH=$HOME/bin:$PATH

# Add homebrew shell environment
if [ -f '/opt/homebrew/bin/brew' ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi

# Set vscode as default editor
if [ -f '/usr/local/bin/code' ]; then export EDITOR="code -w"; fi

# Brew configuration
export HOMEBREW_NO_ENV_HINTS=true

# Git configuration
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)
autoload -Uz compinit && compinit

# Docker specific configuration
export DOCKER_ID_USER="matthewdolan"
if [ -f "$HOME/.docker/init-zsh.sh" ]; then source "$HOME/.docker/init-zsh.sh"; fi # Added by Docker Desktop

# Go specific configuration
# Add $GOPATH/bin to path
export GOPATH=$HOME/go
if command -v go &>/dev/null ; then export PATH="$(go env GOPATH)/bin:$PATH" ; fi

# Ruby specific configuration
# Add ruby gem home environment variable
export GEM_HOME="$HOME/.gem"
export PATH=$GEM_HOME/bin:$PATH

# Python specific configuration
# Add python bin to the path
if command -v python3 &>/dev/null ; then export PATH="$PATH:$(python3 -m site --user-base)/bin" ; fi

# Node specific configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Kubernetes specific configuration
# Set the kubernetes editor in addition to the base editor because for some reason it wasn't working
if [ -f '/usr/local/bin/code' ]; then export KUBE_EDITOR="code --wait"; fi

if [[ "${DOLAN_USE_GCLOUD:-false}" == "true" ]]; then
  # Google Cloud SDK specific configuration
  # The next line updates PATH for the Google Cloud SDK.
  if [ -f "$HOME/Developer/google-cloud-sdk/path.zsh.inc" ]; then source "$HOME/Developer/google-cloud-sdk/path.zsh.inc"; fi
  # The next line enables shell command completion for gcloud.
  if [ -f "$HOME/Developer/google-cloud-sdk/completion.zsh.inc" ]; then source "$HOME/Developer/google-cloud-sdk/completion.zsh.inc"; fi
fi

if [[ "${DOLAN_USE_HERMIT:-false}" == "true" ]]; then
  # Hermit Shell Hooks (https://github.com/cashapp/hermit)
  # Automatic environment activation/deactivation when changing directories.
  autoload -U compinit && compinit -i
  # If hermit hasn't been downloaded yet, `$HOME/bin/hermit shell-hooks --print --zsh` will print extraneous information about downloading it.
  # Calling `$HOME/bin/hermit version` first and sending the output to /dev/null will prevent this.
  eval "$(test -x $HOME/bin/hermit &&  $HOME/bin/hermit version > /dev/null && $HOME/bin/hermit shell-hooks --print --zsh)"
fi
