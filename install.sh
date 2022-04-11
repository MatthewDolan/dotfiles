#!/bin/bash
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

# symlink custom zsh plugins & themes
if [ -d "$PWD/.oh-my-zsh/custom" ]; then
  echo "Symlinking custom oh-my-zsh plugins and themes..."

  # symlink custom zsh plugins
  if [ -d "$PWD/.oh-my-zsh/custom/plugins" ]; then
    echo "  Symlinking custom oh-my-zsh plugins..."
    for file in $( ls -A $PWD/.oh-my-zsh/custom/plugins | grep -vE '\.DS_Store$' ) ; do
      echo "    Symlinking .oh-my-zsh/custom/plugins/$file..."
      if [ -f "$HOME/.oh-my-zsh/custom/plugins/$file" ] && ! [ -L "$HOME/.oh-my-zsh/custom/plugins/$file" ]; then
        echo "      Moving old file to $HOME/.oh-my-zsh-old/custom/plugins"
        mkdir -p "$HOME/.oh-my-zsh-old/custom/plugins"
        mv "$HOME/.oh-my-zsh/custom/plugins/$file" "$HOME/.oh-my-zsh-old/custom/plugins"
      fi
      # Silently ignore errors here because the files may already exist
      ln -sf "$PWD/.oh-my-zsh/custom/plugins/$file" "$HOME/.oh-my-zsh/custom/plugins"
    done
  fi

  # symlink custom zsh themes
  if [ -d "$PWD/.oh-my-zsh/custom/themes" ]; then
    echo "  Symlinking custom oh-my-zsh themes..."
    for file in $( ls -A $PWD/.oh-my-zsh/custom/themes | grep -vE '\.DS_Store$' ) ; do
      echo "    Symlinking .oh-my-zsh/custom/themes/$file..."
      if [ -f "$HOME/.oh-my-zsh/custom/themes/$file" ] && ! [ -L "$HOME/.oh-my-zsh/custom/themes/$file" ]; then
        echo "      Moving old file to $HOME/.oh-my-zsh-old/custom/themes"
        mkdir -p "$HOME/.oh-my-zsh-old/custom/themes"
        mv "$HOME/.oh-my-zsh/custom/themes/$file" "$HOME/.oh-my-zsh-old/custom/themes"
      fi
      # Silently ignore errors here because the files may already exist
      ln -sf "$PWD/.oh-my-zsh/custom/themes/$file" "$HOME/.oh-my-zsh/custom/themes"
    done
  fi
fi

# symlink dotfiles
echo "Symlinking dotfiles..."
for file in $( ls -A | grep '^\.' | grep -vE '^\.git$|\.DS_Store$|\.oh-my-zsh$|\.githooks$' ) ; do
  echo "  Symlinking $file..."
  if [ -f "$HOME/$file" ] && ! [ -L "$HOME/$file" ]; then
    echo "    Moving old file to $HOME/dotfiles-old"
    mkdir -p "$HOME/dotfiles-old"
    mv "$HOME/$file" "$HOME/dotfiles-old"
  fi
  # Silently ignore errors here because the files may already exist
  ln -sf "$PWD/$file" "$HOME"
done

# create bin folder
if ! [ -d "$HOME/bin" ]; then
  echo "Creating a bin folder..."
  mkdir -p "$HOME/bin"
fi

# symlink bin files
echo "Symlinking bin files..."
for file in $( ls -A bin | grep -vE '\.DS_Store$' ) ; do
  echo "  Symlinking bin/$file..."
  if [ -f "$HOME/bin/$file" ] && ! [ -L "$HOME/bin/$file" ]; then
    echo "    Moving old file to $HOME/bin-old"
    mkdir -p "$HOME/bin-old"
    mv "$HOME/bin/$file" "$HOME/bin-old"
  fi
  # Silently ignore errors here because the files may already exist
  ln -sf "$PWD/bin/$file" "$HOME/bin"
done

# create .githooks folder
if ! [ -d "$HOME/.githooks" ]; then
  echo "Creating a .githooks folder..."
  mkdir -p "$HOME/.githooks"
fi

# symlink .githooks files
echo "Symlinking .githooks files..."
for file in $( ls -A .githooks | grep -vE '\.DS_Store$' ) ; do
  echo "  Symlinking .githooks/$file..."
  if [ -f "$HOME/.githooks/$file" ] && ! [ -L "$HOME/.githooks/$file" ]; then
    echo "    Moving old file to $HOME/.githooks-old"
    mkdir -p "$HOME/.githooks-old"
    mv "$HOME/bin/$file" "$HOME/.githooks-old"
  fi
  # Silently ignore errors here because the files may already exist
  ln -sf "$PWD/.githooks/$file" "$HOME/.githooks"
done

# install mac os x specific programs
if [ "$(uname)" == "Darwin" ]; then
  echo "Installing Mac OS Software..."

  if ! command -v brew &> /dev/null ; then
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "  Showing hidden files in Finder..."
  defaults write com.apple.finder AppleShowAllFiles TRUE
  killall Finder
fi
