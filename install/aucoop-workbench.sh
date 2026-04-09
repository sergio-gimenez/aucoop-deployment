#!/bin/bash
# Install a packaged copy of Workbench for AUCOOP Mint.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$SCRIPT_DIR/aucoop-workbench"
TARGET_DIR="/opt/aucoop-workbench"
REQUIRED_COMMANDS=(smartctl lshw hwinfo dmidecode inxi qrencode)

echo "  Installing AUCOOP Workbench..."

if [ ! -f "$SOURCE_DIR/workbench-script.py" ]; then
  echo "  ERROR: AUCOOP Workbench source not found at $SOURCE_DIR"
  exit 1
fi

sudo mkdir -p "$TARGET_DIR"
sudo cp -r "$SOURCE_DIR"/* "$TARGET_DIR/"
sudo chmod +x "$TARGET_DIR/workbench-script.py"

# Runtime dependencies needed by workbench-script.py to gather evidence.
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  smartmontools \
  lshw \
  hwinfo \
  dmidecode \
  inxi \
  qrencode \
  pciutils

for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "  ERROR: required Workbench command '$cmd' is missing after installation"
    exit 1
  fi
done
