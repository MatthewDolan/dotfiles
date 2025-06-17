# Source ~/.zshenv.local (not checked into the repo)
# This is where you would put local configuration that's only for this computer.
# For example, sourcing company specific files or setting secret keys as
# environment variables.
if [ -f "$HOME/.zshenv.local" ]; then source $HOME/.zshenv.local; fi

# Allow unlimited files to be opened at the same time.
ulimit -u unlimited
