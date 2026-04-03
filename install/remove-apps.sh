#!/bin/bash
# Remove unwanted default apps
#
# These are either redundant (replaced by Chrome/OnlyOffice),
# not useful for the target audience, or clutter.

REMOVE_PACKAGES=(
  # Replaced by Chrome
  firefox

  # Replaced by OnlyOffice
  libreoffice-common
  libreoffice-core
  libreoffice-calc
  libreoffice-writer
  libreoffice-impress
  libreoffice-draw
  libreoffice-math
  libreoffice-base-core
  libreoffice-gnome
  libreoffice-gtk3
  libreoffice-help-common
  libreoffice-style-colibre

  # Not useful for target audience
  transmission-gtk        # torrent client
  seahorse                # password/keyring manager GUI

  # Removed in earlier manual setup
  hexchat
  thunderbird
  mintchat
  warpinator
  webapp-manager
)

echo "Removing unwanted packages..."

# Build list of packages that are actually installed
TO_REMOVE=()
for pkg in "${REMOVE_PACKAGES[@]}"; do
  if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
    TO_REMOVE+=("$pkg")
  fi
done

if [ ${#TO_REMOVE[@]} -eq 0 ]; then
  echo "  No unwanted packages found — already clean."
else
  echo "  Removing: ${TO_REMOVE[*]}"
  sudo apt-get purge -y "${TO_REMOVE[@]}"
  sudo apt-get autoremove -y
fi
