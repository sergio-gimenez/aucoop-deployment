#!/bin/bash
# Set cursor theme
#
# DMZ-White is clean and Windows-like (white pointer with black outline).
# If a more Windows-like cursor is desired, install a custom theme here.

CURSOR_THEME="DMZ-White"

echo "  Setting cursor theme to $CURSOR_THEME..."

# Check the theme exists
if [ ! -d "/usr/share/icons/$CURSOR_THEME" ]; then
  echo "  WARNING: Cursor theme $CURSOR_THEME not found — skipping."
  return 0
fi

dconf write /org/cinnamon/desktop/interface/cursor-theme "'$CURSOR_THEME'"
