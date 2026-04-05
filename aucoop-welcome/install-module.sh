#!/bin/bash

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <module-id>"
  exit 1
fi

MODULE_ID="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODULES_JSON="$SCRIPT_DIR/modules.json"
DESKTOP_DIR="${SUDO_USER:+/home/$SUDO_USER/Desktop}"
mapfile -t packages < <(python3 - "$MODULES_JSON" "$MODULE_ID" <<'PY'
import json
import sys

config_path = sys.argv[1]
module_id = sys.argv[2]

with open(config_path, 'r', encoding='utf-8') as fh:
    data = json.load(fh)

for module in data.get('optional_modules', []):
    if module.get('id') == module_id:
        for pkg in module.get('install', {}).get('packages', []):
            print(pkg)
        break
PY
)

if [ ${#packages[@]} -eq 0 ]; then
  echo "No installable packages found for module: $MODULE_ID"
  exit 1
fi

apt-get update -qq
apt-get install -y "${packages[@]}"

if [ "$MODULE_ID" = "kiwix" ] && [ -n "${DESKTOP_DIR:-}" ] && [ -f /usr/share/applications/kiwix.desktop ]; then
  mkdir -p "$DESKTOP_DIR"
  cp /usr/share/applications/kiwix.desktop "$DESKTOP_DIR/kiwix.desktop"
  chown "$SUDO_USER:$SUDO_USER" "$DESKTOP_DIR/kiwix.desktop"
  chmod +x "$DESKTOP_DIR/kiwix.desktop"
  sudo -u "$SUDO_USER" gio set "$DESKTOP_DIR/kiwix.desktop" metadata::trusted true 2>/dev/null || true
fi
