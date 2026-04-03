#!/bin/bash
#
# AUCOOP Mint installer
#
# Takes a fresh Linux Mint 22.x (Cinnamon) install and applies all
# AUCOOP customizations: removes bloat, installs apps, sets theme,
# wallpaper, cursor, desktop shortcuts, and branding.
#
# Can be run standalone or via boot.sh (curl one-liner).
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$SCRIPT_DIR/install"

# ── Preflight checks ──────────────────────────────────────────────

# Must be Linux Mint Cinnamon
if [ ! -f /etc/linuxmint/info ]; then
  echo "ERROR: This script is designed for Linux Mint. Aborting."
  exit 1
fi

MINT_VERSION=$(grep RELEASE /etc/linuxmint/info | cut -d= -f2)
echo "Detected Linux Mint $MINT_VERSION"

if [[ ! "$MINT_VERSION" =~ ^22\. ]]; then
  echo "WARNING: This script was tested on Mint 22.x. You're running $MINT_VERSION."
  read -rp "Continue anyway? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
fi

# Must not be root (desktop settings need the real user)
if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR: Do not run this script as root. Run as the desktop user (sudo will be used where needed)."
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║          AUCOOP Mint Installer           ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Run install scripts in order ──────────────────────────────────

run_step() {
  local script="$1"
  local name
  name=$(basename "$script" .sh)
  echo ""
  echo "── $name ──────────────────────────────────"
  source "$script"
  echo "   done."
}

# Phase 1: Remove unwanted apps (before installing new ones)
run_step "$INSTALL_DIR/remove-apps.sh"

# Phase 2: Install apps
run_step "$INSTALL_DIR/chrome.sh"
run_step "$INSTALL_DIR/onlyoffice.sh"
run_step "$INSTALL_DIR/flathub.sh"

# Phase 3: Desktop customization
run_step "$INSTALL_DIR/theme.sh"
run_step "$INSTALL_DIR/wallpaper.sh"
run_step "$INSTALL_DIR/cursor.sh"
run_step "$INSTALL_DIR/software-manager-icon.sh"
run_step "$INSTALL_DIR/desktop-shortcuts.sh"
run_step "$INSTALL_DIR/search-aliases.sh"
run_step "$INSTALL_DIR/branding.sh"

# ── Done ──────────────────────────────────────────────────────────

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║       AUCOOP Mint setup complete!        ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "You may want to reboot to ensure all changes take effect."
echo ""
