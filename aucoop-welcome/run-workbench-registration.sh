#!/bin/bash

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <devicehub-url> <token>"
  exit 1
fi

DEVICEHUB_URL="$1"
TOKEN="$2"
WORKBENCH_DIR="${WORKBENCH_DIR:-/opt/aucoop-workbench}"

if [ ! -f "$WORKBENCH_DIR/workbench-script.py" ]; then
  echo "Workbench not found at $WORKBENCH_DIR"
  exit 1
fi

TMP_DIR="$(mktemp -d)"
CONFIG_FILE="$TMP_DIR/settings.ini"

cat > "$CONFIG_FILE" <<EOF
[settings]
url = $DEVICEHUB_URL
token = $TOKEN
http_max_retries = 3
http_retry_delay = 3
disable_qr = False
path = $TMP_DIR
EOF

cd "$WORKBENCH_DIR"
python3 workbench-script.py --config "$CONFIG_FILE"
