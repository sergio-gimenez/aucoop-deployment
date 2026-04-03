#!/bin/bash
# Set wallpaper
#
# Uses the Mint default "joe-mcdaniel" wallpaper with zoom mode.
# To use a custom AUCOOP wallpaper, place it in assets/ and update the path below.

WALLPAPER="/usr/share/backgrounds/joe-mcdaniel-ZdWhZTpd_Uw-unsplash.jpg"

if [ ! -f "$WALLPAPER" ]; then
  echo "  WARNING: Wallpaper not found at $WALLPAPER — skipping."
  return 0
fi

echo "  Setting wallpaper..."
dconf write /org/cinnamon/desktop/background/picture-uri "'file://$WALLPAPER'"
dconf write /org/cinnamon/desktop/background/picture-options "'zoom'"
