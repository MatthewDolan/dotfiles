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

# Used by some programs (including hermit)
export PATH=$HOME/bin:$PATH

# Add homebrew shell environment
if [ -f '/opt/homebrew/bin/brew' ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi

# Set vscode as default editor
if [ -f '/usr/local/bin/code' ]; then export EDITOR="code -w"; fi

# Docker specific configuration
export DOCKER_ID_USER="matthewdolan"

# Go specific configuration
# Add $HOME/go/bin to path
export GOPATH=$HOME/go
export PATH=$GOBIN:$GOPATH/bin:$GOROOT/bin:$PATH

# Ruby specific configuration
# Add ruby gem home environment variable
export GEM_HOME="$HOME/.gem"
export PATH=$GEM_HOME/bin:$PATH

# Google Cloud SDK specific configuration
# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Development/google-cloud-sdk/path.zsh.inc" ]; then source "$HOME/Development/google-cloud-sdk/path.zsh.inc"; fi
# The next line enables shell command completion for gcloud.
if [ -f "$HOME/Development/google-cloud-sdk/completion.zsh.inc" ]; then source "$HOME/Development/google-cloud-sdk/completion.zsh.inc"; fi

# Hermit Shell Hooks (https://github.com/cashapp/hermit)
# Automatic environment activation/deactivation when changing directories.
autoload -U compinit && compinit -i
# If hermit hasn't been downloaded yet, `$HOME/bin/hermit shell-hooks --print --zsh` will print extraneous information about downloading it.
# Calling `$HOME/bin/hermit version` first and sending the output to /dev/null will prevent this.
eval "$(test -x $HOME/bin/hermit &&  $HOME/bin/hermit version > /dev/null && $HOME/bin/hermit shell-hooks --print --zsh)"
