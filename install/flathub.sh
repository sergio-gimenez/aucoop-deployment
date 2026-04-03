#!/bin/bash
# Configure Flathub as Flatpak remote
#
# Linux Mint ships with Flatpak but points to its own filtered repo.
# We add the full Flathub so users can install anything via Software Manager.

if flatpak remote-list | grep -q "flathub"; then
  echo "  Flathub is already configured."
else
  echo "  Adding Flathub remote..."
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi
