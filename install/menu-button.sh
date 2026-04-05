#!/bin/bash
# Replace the Cinnamon menu button icon with the AUCOOP symbol.

MENU_CONFIG="$HOME/.config/cinnamon/spices/menu@cinnamon.org/0.json"
AUCOOP_ICON="/usr/share/pixmaps/aucoop-symbol.png"

if [ ! -f "$MENU_CONFIG" ]; then
  echo "  Menu applet config not found — skipping menu button icon."
  return 0
fi

if [ ! -f "$AUCOOP_ICON" ]; then
  echo "  AUCOOP menu icon not installed yet — skipping menu button icon."
  return 0
fi

echo "  Setting AUCOOP icon for the menu button..."

python3 - <<PY
import json
from pathlib import Path

path = Path(r"$MENU_CONFIG")
data = json.loads(path.read_text(encoding="utf-8"))
data.setdefault("menu-custom", {})["value"] = True
data.setdefault("menu-icon", {})["value"] = r"$AUCOOP_ICON"
data.setdefault("menu-label", {})["value"] = ""
path.write_text(json.dumps(data, indent=4) + "\n", encoding="utf-8")
PY
