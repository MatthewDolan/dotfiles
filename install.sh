#!/bin/sh
set -e

echo "Setting up your Computer..."

# create development directory
if ! [ -d "$HOME/Development" ]; then
  echo "Creating a Development folder..."
  mkdir -p "$HOME/Development"
fi

# install oh-my-zsh
if ! [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --keep-zshrc
fi

# symlink dotfiles
echo "Symlinking dotfiles..."
for file in $( ls -A | grep '^\.' | grep -vE '^\.git$|\.gitignore$|\.gitmodules$|\.DS_Store$' ) ; do
  echo "  Symlinking $file..."
  echo "$HOME/$file"
  if [ -f "$HOME/$file" ] && ! [ -L "$HOME/$file" ]; then
    echo "    Moving old file to $HOME/dotfiles-old"
    mkdir -p "$HOME/dotfiles-old"
    mv "$HOME/g$file" "$HOME/dotfiles-old"
  fi
  # Silently ignore errors here because the files may already exist
  ln -sf "$PWD/$file" "$HOME"
done
