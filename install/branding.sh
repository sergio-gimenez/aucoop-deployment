#!/bin/bash
# AUCOOP branding
#
# Installs AUCOOP branding assets and sets the AUCOOP user avatar.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGO_SOURCE="$SCRIPT_DIR/assets/AUCOOP_logotip.png"
LOGO_DEST="/usr/share/pixmaps/aucoop-logo.png"
USER_IMAGE_SOURCE="$SCRIPT_DIR/assets/user-image.jpg"
USER_IMAGE_DEST="/var/lib/AccountsService/icons/aucoop"
USER_ACCOUNT_FILE="/var/lib/AccountsService/users/aucoop"
USER_FACE_FILE="$HOME/.face"
WELCOME_ICON_SOURCE="$SCRIPT_DIR/assets/aucoop-symbol.png"
WELCOME_ICON_DEST="/usr/share/pixmaps/aucoop-symbol.png"

if [ ! -f "$LOGO_SOURCE" ]; then
  echo "  No AUCOOP logo found at $LOGO_SOURCE — skipping."
  echo "  Place the logo at assets/AUCOOP_logotip.png and re-run."
  return 0
fi

echo "  Installing AUCOOP logo..."
sudo cp "$LOGO_SOURCE" "$LOGO_DEST"

if [ -f "$USER_IMAGE_SOURCE" ]; then
  echo "  Setting AUCOOP user image..."
  sudo mkdir -p /var/lib/AccountsService/icons /var/lib/AccountsService/users
  sudo cp "$USER_IMAGE_SOURCE" "$USER_IMAGE_DEST"
  cp "$USER_IMAGE_SOURCE" "$USER_FACE_FILE"
  if [ -f "$USER_ACCOUNT_FILE" ]; then
    sudo sed -i '/^Icon=/d' "$USER_ACCOUNT_FILE"
  else
    printf '[User]\n' | sudo tee "$USER_ACCOUNT_FILE" >/dev/null
  fi
  printf 'Icon=%s\n' "$USER_IMAGE_DEST" | sudo tee -a "$USER_ACCOUNT_FILE" >/dev/null
fi

if [ -f "$WELCOME_ICON_SOURCE" ]; then
  sudo cp "$WELCOME_ICON_SOURCE" "$WELCOME_ICON_DEST"
fi
