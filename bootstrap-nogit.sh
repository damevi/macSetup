#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/damevi/macSetup.git"
CLONE_DIR="$HOME/development/macSetup"

echo "⏳ Bootstrapping MacAutoSetup..."

# Step 1: Install Xcode Command Line Tools (includes Git)
if ! command -v git &> /dev/null; then
  echo "🔧 Installing Xcode Command Line Tools (required for Git)..."
  xcode-select --install
  echo "⏳ Waiting for installation to complete (check for a popup)..."

  # Wait until installation is complete
  until command -v git &> /dev/null; do
    sleep 5
  done
  echo "✅ Git is now installed."
fi

# Step 2: Install Homebrew
if ! command -v brew &> /dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Step 3: Clone the repo if it hasn't been cloned yet
if [ ! -d "$CLONE_DIR" ]; then
  echo "📥 Cloning MacAutoSetup into $CLONE_DIR..."
  mkdir -p "$(dirname "$CLONE_DIR")"
  git clone "$REPO_URL" "$CLONE_DIR"
else
  echo "📁 Directory $CLONE_DIR already exists. Skipping clone."
fi

# Step 4: Run main bootstrap script
cd "$CLONE_DIR"
echo "🚀 Running main bootstrap script..."
if [[ ! -f ./bootstrap.sh ]]; then
  echo "❌ bootstrap.sh not found in $CLONE_DIR — clone may be corrupted." >&2
  exit 1
fi
chmod +x ./bootstrap.sh
exec ./bootstrap.sh
