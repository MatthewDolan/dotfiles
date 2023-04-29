#!/bin/bash
set -e

echo "Setting up your Computer..."

# create developer directory
if ! [ -d "$HOME/Developer" ]; then
  echo "Creating a Developer folder..."
  mkdir -p "$HOME/Developer"
fi

# install oh-my-zsh
if ! [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --keep-zshrc
fi

# install hermit
if ! [[ -d "$HOME/bin/hermit" ]]; then
  echo "Installing hermit..."
  curl -fsSL https://github.com/cashapp/hermit/releases/download/stable/install.sh | /bin/bash
fi

# symlink files from `./home` to `$HOME`
home_src="$PWD/home"
home_dst="$HOME"

echo "Symlinking files from "${file#$PWD/}" to $home_dst..."

# iterate through all files in $home_src and its subdirectories
find "$home_src" -type f -print0 | while IFS= read -r -d '' file; do
  # create the destination directory for the symlink
  dest_dir="$(dirname "${file#$home_src/}")"

  echo "  Symlinking "${file#$home_src/}" to \$HOME/$dest_dir..."

  mkdir -p "$home_dst/$dest_dir"

  dest_file="$home_dst/$dest_dir/$(basename "$file")"

  # create the symlink, moving the file to .old if necessary
  if [[ -e "$dest_file" && ! -L "$dest_file" ]]; then

    # create .old directory if it doesn't exist
    mkdir -p "$home_dst/.old"

    mv "$dest_file" "$home_dst/.old/$dest_dir/$(basename "$file")"
  fi
  ln -sf "$file" "$dest_file"
done

# install mac os x specific programs
if [[ "$(uname)" == "Darwin" ]]; then
  echo "Installing Mac OS Software..."

  if ! command -v brew &> /dev/null ; then
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "  Showing hidden files in Finder..."
  defaults write com.apple.finder AppleShowAllFiles TRUE
  killall Finder
fi
