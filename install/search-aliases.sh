#!/bin/bash
# Add search aliases for Software Manager
#
# Users coming from Windows might search for "app store" or "download"
# in the Cinnamon menu. By default, those terms don't find Software Manager.
#
# We create a secondary .desktop file with extra Keywords so the menu
# search picks it up.

ALIAS_DESKTOP="/usr/share/applications/mintinstall-aliases.desktop"

echo "  Adding search aliases for Software Manager..."

sudo tee "$ALIAS_DESKTOP" > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Software Manager
GenericName=App Store
Comment=Browse and install applications
Exec=mintinstall
Icon=mintinstall
Terminal=false
Categories=System;PackageManager;
Keywords=app store;download;download apps;store;shop;market;install;applications;programs;software;
NoDisplay=true
EOF

# Update desktop database so menu search indexes it
sudo update-desktop-database /usr/share/applications 2>/dev/null || true
