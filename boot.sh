#!/bin/bash
#
# AUCOOP Mint bootstrap
#
# Run on a fresh Linux Mint 22.x install:
#   wget -qO- https://raw.githubusercontent.com/sergio-gimenez/aucoop-deployment/master/boot.sh | bash
#

set -e

REPO_URL="https://github.com/sergio-gimenez/aucoop-deployment.git"
INSTALL_DIR="$HOME/.aucoop-mint"

# Ensure git is available (should be on Mint by default)
if ! command -v git &>/dev/null; then
  echo "Installing git..."
  sudo apt-get update -qq && sudo apt-get install -y -qq git
fi

# Clone or update the repo
if [ -d "$INSTALL_DIR" ]; then
  echo "Updating AUCOOP Mint..."
  git -C "$INSTALL_DIR" pull --ff-only
else
  echo "Downloading AUCOOP Mint..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Hand off to install.sh
cd "$INSTALL_DIR"
bash install.sh
