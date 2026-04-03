#!/bin/bash
# Replace Software Manager (mintinstall) icon with a download-arrow icon
#
# The default mintinstall icon looks like a shopping bag — confusing.
# We replace it with a recognizable download-arrow icon across all sizes
# in the Mint-Y icon theme (which Mint-Y-Blue inherits from).
#
# The source icon is stored at assets/software-manager-icon.png (512x512).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_ICON="$SCRIPT_DIR/assets/software-manager-icon.png"
ICON_THEME_DIR="/usr/share/icons/Mint-Y"

if [ ! -f "$SOURCE_ICON" ]; then
  echo "  WARNING: Source icon not found at $SOURCE_ICON — skipping."
  echo "  Place a 512x512 PNG at assets/software-manager-icon.png and re-run."
  return 0
fi

# Ensure ImageMagick is available for resizing
if ! command -v convert &>/dev/null; then
  echo "  Installing ImageMagick for icon resizing..."
  sudo apt-get install -y -qq imagemagick
fi

echo "  Replacing Software Manager icon in Mint-Y theme..."

# Standard sizes in the Mint-Y icon theme
SIZES=(16 22 24 32 48 64 96 128 256 512)

for size in "${SIZES[@]}"; do
  target_dir="$ICON_THEME_DIR/apps/$size"
  if [ -d "$target_dir" ]; then
    convert "$SOURCE_ICON" -resize "${size}x${size}" "/tmp/mintinstall-${size}.png"
    sudo cp "/tmp/mintinstall-${size}.png" "$target_dir/mintinstall.png"
    rm -f "/tmp/mintinstall-${size}.png"
  fi

  # HiDPI @2x variant
  target_dir_2x="$ICON_THEME_DIR/apps/${size}@2x"
  if [ -d "$target_dir_2x" ]; then
    doubled=$((size * 2))
    convert "$SOURCE_ICON" -resize "${doubled}x${doubled}" "/tmp/mintinstall-${size}@2x.png"
    sudo cp "/tmp/mintinstall-${size}@2x.png" "$target_dir_2x/mintinstall.png"
    rm -f "/tmp/mintinstall-${size}@2x.png"
  fi
done

# Refresh icon cache
sudo gtk-update-icon-cache -f "$ICON_THEME_DIR" 2>/dev/null || true
