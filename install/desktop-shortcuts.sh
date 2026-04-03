#!/bin/bash
# Create OnlyOffice desktop shortcuts with Microsoft-style icons
#
# Three shortcuts on the desktop:
#   - Document (Word-like, blue "W" icon)
#   - Spreadsheet (Excel-like, green "X" icon)
#   - Presentation (PowerPoint-like, orange "P" icon)
#
# Custom icons should be placed in assets/icons/:
#   - onlyoffice-document.png   (Word-style)
#   - onlyoffice-spreadsheet.png (Excel-style)
#   - onlyoffice-presentation.png (PowerPoint-style)
#
# If custom icons are not available, falls back to the default OnlyOffice icon.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ICONS_DIR="$SCRIPT_DIR/assets/icons"
DESKTOP_DIR="$HOME/Desktop"
SYSTEM_ICON_DIR="/usr/share/icons/aucoop"

mkdir -p "$DESKTOP_DIR"

# Install custom icons system-wide if available
if [ -d "$ICONS_DIR" ]; then
  sudo mkdir -p "$SYSTEM_ICON_DIR"
  for icon_file in "$ICONS_DIR"/onlyoffice-*.png; do
    [ -f "$icon_file" ] && sudo cp "$icon_file" "$SYSTEM_ICON_DIR/"
  done
fi

# Helper to pick the right icon
pick_icon() {
  local name="$1"
  if [ -f "$SYSTEM_ICON_DIR/$name.png" ]; then
    echo "$SYSTEM_ICON_DIR/$name.png"
  else
    echo "onlyoffice-desktopeditors"
  fi
}

# Document (Word equivalent)
cat > "$DESKTOP_DIR/onlyoffice-document.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Document
Comment=Create or edit documents
Exec=/usr/bin/onlyoffice-desktopeditors --new:word
Icon=$(pick_icon onlyoffice-document)
Terminal=false
Categories=Office;WordProcessor;
StartupWMClass=ONLYOFFICE
EOF

# Spreadsheet (Excel equivalent)
cat > "$DESKTOP_DIR/onlyoffice-spreadsheet.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Spreadsheet
Comment=Create or edit spreadsheets
Exec=/usr/bin/onlyoffice-desktopeditors --new:cell
Icon=$(pick_icon onlyoffice-spreadsheet)
Terminal=false
Categories=Office;Spreadsheet;
StartupWMClass=ONLYOFFICE
EOF

# Presentation (PowerPoint equivalent)
cat > "$DESKTOP_DIR/onlyoffice-presentation.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Presentation
Comment=Create or edit presentations
Exec=/usr/bin/onlyoffice-desktopeditors --new:slide
Icon=$(pick_icon onlyoffice-presentation)
Terminal=false
Categories=Office;Presentation;
StartupWMClass=ONLYOFFICE
EOF

# Make them trusted (Cinnamon requires this to show on desktop)
for f in "$DESKTOP_DIR"/onlyoffice-*.desktop; do
  chmod +x "$f"
  # Mark as trusted so Cinnamon doesn't show "untrusted" warning
  gio set "$f" metadata::trusted true 2>/dev/null || true
done

echo "  Created 3 OnlyOffice shortcuts on desktop."
