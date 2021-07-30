#!/bin/sh
set -e

echo "Setting up your Computer..."

echo "Creating a Development folder..."
mkdir -p "$HOME/Development"

# symlink dotfiles
echo "Symlinking dotfiles..."
for file in $( ls -A $HOME/dotfiles | grep '^\.' | grep -vE '^\.git$|\.gitignore$|\.gitmodules$|\.DS_Store$' ) ; do
  echo "  Symlinking $file..."
  echo "$HOME/$file"
  if [ -f "$HOME/$file" ] && ! [ -L "$HOME/$file" ]; then
    echo "    Moving old file to $HOME/dotfiles-old"
    mkdir -p "$HOME/dotfiles-old"
    mv "$HOME/$file" "$HOME/dotfiles-old"
  fi
  # Silently ignore errors here because the files may already exist
  ln -sfn "$HOME/dotfiles/$file" "$HOME"
done
