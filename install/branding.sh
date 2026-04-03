#!/bin/bash
# AUCOOP branding
#
# Places the AUCOOP logo where it can be referenced by other customizations
# (e.g., login screen, About dialog, boot splash).
#
# The logo source is assets/AUCOOP_logotip.png (741x145 banner).
# For now we just install it system-wide. Future: custom login screen, etc.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGO_SOURCE="$SCRIPT_DIR/assets/AUCOOP_logotip.png"
LOGO_DEST="/usr/share/pixmaps/aucoop-logo.png"

if [ ! -f "$LOGO_SOURCE" ]; then
  echo "  No AUCOOP logo found at $LOGO_SOURCE — skipping."
  echo "  Place the logo at assets/AUCOOP_logotip.png and re-run."
  return 0
fi

echo "  Installing AUCOOP logo..."
sudo cp "$LOGO_SOURCE" "$LOGO_DEST"
