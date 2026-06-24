#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

DOTFILES_REPO="https://github.com/damevi/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# Install Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  until xcode-select -p &>/dev/null; do
    sleep 5
    echo "   still installing..."
  done
fi

# Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "Tapping and trusting third-party taps..."
brew tap nikitabobko/tap
brew trust nikitabobko/tap
brew tap jorgerojas26/lazysql
brew trust jorgerojas26/lazysql

# Install applications via Brewfile (this is what brings in `mise` itself)
if [[ -f ./Brewfile ]]; then
  echo "Installing applications from Brewfile..."
  brew bundle --file=./Brewfile
else
  echo "Warning: Brewfile not found in current directory"
fi

# Install Zap ZSH plugin manager
if [[ ! -d "${XDG_DATA_HOME:-$HOME/.local/share}/zap" ]]; then
  echo "Installing Zap ZSH plugin manager..."
  zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
fi

# Remove any pre-existing real .zshrc so stow can manage it
if [[ -f ~/.zshrc && ! -L ~/.zshrc ]]; then
  echo "Removing existing .zshrc so stow can manage it..."
  rm -f ~/.zshrc
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# Hard-verify stow is actually present before relying on it later
if ! command -v stow &>/dev/null; then
  echo "Error: GNU Stow is required but was not installed (brew bundle may have failed partway)." >&2
  echo "Try running: brew install stow" >&2
  exit 1
fi

# Clone (or update) the separate dotfiles repo
if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "Cloning dotfiles repo into $DOTFILES_DIR..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "Dotfiles repo already present at $DOTFILES_DIR, pulling latest..."
  git -C "$DOTFILES_DIR" pull --ff-only
fi

if [[ -f "$DOTFILES_DIR/macos/.macos" ]]; then
  echo "Applying macOS defaults..."
  bash "$DOTFILES_DIR/macos/.macos"
fi

# Symlink dotfiles from the dotfiles repo
echo "Setting up dotfiles with GNU Stow..."
STOW_PACKAGES=(aerospace ghostty mise nvim starship tmux vim zsh)
stow --target="$HOME" --dir="$DOTFILES_DIR" "${STOW_PACKAGES[@]}"

# Now mise is installed AND its config is in place — install the actual runtimes
if command -v mise &>/dev/null; then
  echo "Installing mise-managed runtimes..."
  eval "$(mise activate bash)" # activate in this script's session so `mise install` works without a new shell
  mise install
fi

exec zsh -l
