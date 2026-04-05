#!/bin/bash
# Set wallpaper
#
# Uses a bundled AUCOOP wallpaper if available. Otherwise it falls back to
# a wallpaper already present on the Mint system.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WALLPAPER_NAME="joe-mcdaniel-ZdWhZTpd_Uw-unsplash.jpg"
USER_PICTURES_DIR="$HOME/Pictures"
TARGET_WALLPAPER="$USER_PICTURES_DIR/$WALLPAPER_NAME"

if [ -f "$SCRIPT_DIR/assets/wallpaper.jpg" ]; then
  mkdir -p "$USER_PICTURES_DIR"
  cp "$SCRIPT_DIR/assets/wallpaper.jpg" "$TARGET_WALLPAPER"
  WALLPAPER="$TARGET_WALLPAPER"
else
  WALLPAPER="$(find /usr/share/backgrounds -maxdepth 3 -type f \( -name 'joe-mcdaniel-ZdWhZTpd_Uw-unsplash.jpg' -o -name '*.jpg' -o -name '*.png' \) | head -1)"
fi

if [ -z "${WALLPAPER:-}" ] || [ ! -f "$WALLPAPER" ]; then
  echo "  WARNING: Wallpaper not found at $WALLPAPER — skipping."
  return 0
fi

echo "  Setting wallpaper..."
dconf write /org/cinnamon/desktop/background/picture-uri "'file://$WALLPAPER'"
dconf write /org/cinnamon/desktop/background/picture-options "'zoom'"
dconf write /org/cinnamon/desktop/screensaver/screensaver-name "'default'" 2>/dev/null || true
dconf write /org/cinnamon/desktop/screensaver/picture-uri "'file://$WALLPAPER'" 2>/dev/null || true
dconf write /org/cinnamon/desktop/screensaver/picture-options "'zoom'" 2>/dev/null || true

# Cinnamon's lock screen ultimately reads the desktop background settings.
# Nudge the screensaver to reload if the helper is available; otherwise the
# final reboot will pick up the new wallpaper.
python3 /usr/share/cinnamon-screensaver/cinnamon-screensaver-command.py --deactivate >/dev/null 2>&1 || true

if [ -f /var/lib/AccountsService/users/"$USER" ]; then
  sudo sed -i '/^BackgroundFile=/d' /var/lib/AccountsService/users/"$USER"
  printf 'BackgroundFile=%s\n' "$WALLPAPER" | sudo tee -a /var/lib/AccountsService/users/"$USER" >/dev/null
fi

# LightDM/Slick Greeter uses its own config for the login/greeter background.
if [ -d /etc/lightdm ]; then
  sudo mkdir -p /etc/lightdm/slick-greeter.conf.d
  sudo tee /etc/lightdm/slick-greeter.conf.d/90-aucoop-background.conf >/dev/null <<EOF
[Greeter]
background=$WALLPAPER
draw-user-backgrounds=false
EOF
fi
