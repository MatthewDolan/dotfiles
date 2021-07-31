# Source .local (not checked into the repo)
# This is where you would put local configuration that's only for this computer.
# For example, sourcing company specific files or setting secret keys as
# environment variables.
if [ -f "$HOME/.local" ]; then source $HOME/.local; fi

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# zsh theme
ZSH_THEME="robbyrussell"

# zsh plugins
plugins=(
  brew
  docker
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

source $ZSH/oh-my-zsh.sh

# User configuration

# Docker specific configuration
export DOCKER_ID_USER="matthewdolan"

# Go specific configuration
# Add $HOME/go/bin to path
export PATH=$HOME/go/bin:$PATH

# Ruby specific configuration
# Add ruby gem home environment variable
export GEM_HOME="$HOME/.gem"

# Google Cloud SDK specific configuration
# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Development/google-cloud-sdk/path.zsh.inc" ]; then source "$HOME/Development/google-cloud-sdk/path.zsh.inc"; fi
# The next line enables shell command completion for gcloud.
if [ -f '$HOME/Development/google-cloud-sdk/completion.zsh.inc' ]; then source '$HOME/Development/google-cloud-sdk/completion.zsh.inc'; fi
