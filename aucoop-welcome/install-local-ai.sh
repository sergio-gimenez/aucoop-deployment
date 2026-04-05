#!/bin/bash

set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$APP_DIR/modules.json"
TARGET_DIR="/opt/aucoop-ai"
RUNNER_SCRIPT="$TARGET_DIR/run-local-ai.sh"
DESKTOP_FILE="/usr/share/applications/aucoop-local-ai.desktop"
DESKTOP_DIR="${SUDO_USER:+/home/$SUDO_USER/Desktop}"
ICON_SOURCE="$APP_DIR/assets/llamafile-icon.png"
ICON_TARGET="/usr/share/pixmaps/aucoop-local-ai.png"
REQUESTED_MODEL_ID="${1:-auto}"

readarray -t MODEL_INFO < <(python3 - "$CONFIG_FILE" "$REQUESTED_MODEL_ID" <<'PY'
import json
from pathlib import Path
import sys

cfg = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
requested_model_id = sys.argv[2]

mem_total_kb = 0
with open('/proc/meminfo', 'r', encoding='utf-8') as fh:
    for line in fh:
        if line.startswith('MemTotal:'):
            mem_total_kb = int(line.split()[1])
            break

ram_gb = mem_total_kb / 1024 / 1024
models = sorted(cfg['local_ai'].get('models', []), key=lambda m: m.get('min_ram_gb', 0))
selected = None

if requested_model_id != 'auto':
    for model in models:
        if model.get('id') == requested_model_id:
            selected = model
            break
else:
    for model in models:
        if ram_gb >= model.get('min_ram_gb', 0):
            selected = model

if not selected:
    raise SystemExit('No suitable local AI model configured for this machine.')

print(selected['name'])
print(selected['download_url'])
print(selected['filename'])
print(str(selected.get('port', 8091)))
PY
)

MODEL_NAME="${MODEL_INFO[0]}"
DOWNLOAD_URL="${MODEL_INFO[1]}"
FILENAME="${MODEL_INFO[2]}"
PORT="${MODEL_INFO[3]}"

echo "Installing local AI assistant: $MODEL_NAME"

mkdir -p "$TARGET_DIR"
curl -L "$DOWNLOAD_URL" -o "$TARGET_DIR/$FILENAME"
chmod +x "$TARGET_DIR/$FILENAME"

cat > "$RUNNER_SCRIPT" <<EOF
#!/bin/bash
set -euo pipefail
pkill -f '$TARGET_DIR/$FILENAME --server' 2>/dev/null || true
nohup '$TARGET_DIR/$FILENAME' --server --host 127.0.0.1 --port $PORT >/tmp/aucoop-local-ai.log 2>&1 < /dev/null &
sleep 3
xdg-open 'http://127.0.0.1:$PORT'
EOF

chmod +x "$RUNNER_SCRIPT"

if [ -f "$ICON_SOURCE" ]; then
  install -m 644 "$ICON_SOURCE" "$ICON_TARGET"
fi

cat > /tmp/aucoop-local-ai.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Offline AI assistant
Comment=Run a local AI assistant in AUCOOP Mint
Exec=$RUNNER_SCRIPT
Icon=$ICON_TARGET
Terminal=false
Categories=Utility;Education;
Keywords=ai;assistant;offline;chat;llamafile;aucoop;
EOF

install -m 644 /tmp/aucoop-local-ai.desktop "$DESKTOP_FILE"
update-desktop-database /usr/share/applications >/dev/null 2>&1 || true

if [ -n "${DESKTOP_DIR:-}" ]; then
  mkdir -p "$DESKTOP_DIR"
  cp "$DESKTOP_FILE" "$DESKTOP_DIR/aucoop-local-ai.desktop"
  chown "$SUDO_USER:$SUDO_USER" "$DESKTOP_DIR/aucoop-local-ai.desktop"
  chmod +x "$DESKTOP_DIR/aucoop-local-ai.desktop"
  sudo -u "$SUDO_USER" gio set "$DESKTOP_DIR/aucoop-local-ai.desktop" metadata::trusted true 2>/dev/null || true
fi

echo "Installed local AI assistant launcher."
