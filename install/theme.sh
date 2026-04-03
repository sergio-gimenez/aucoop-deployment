#!/bin/bash
# Set light/white theme (Mint-Y-Blue)
#
# White mode always — Windows default, familiar for target users.
# Mint-Y-Blue is the light blue variant (NOT Mint-Y-Dark-Blue).

echo "  Setting light theme (Mint-Y-Blue)..."

# GTK theme
dconf write /org/cinnamon/desktop/interface/gtk-theme "'Mint-Y-Blue'"

# Cinnamon desktop theme (window borders, panel)
dconf write /org/cinnamon/theme/name "'Mint-Y-Blue'"

# Icon theme
dconf write /org/cinnamon/desktop/interface/icon-theme "'Mint-Y-Blue'"

# Ensure event sounds are off (less annoyance)
dconf write /org/cinnamon/desktop/sound/event-sounds "false"
