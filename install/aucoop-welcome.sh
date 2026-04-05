#!/bin/bash
# Install AUCOOP Welcome app files system-wide.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$SCRIPT_DIR/aucoop-welcome"
TARGET_DIR="/opt/aucoop-welcome"
DESKTOP_DIR="$HOME/Desktop"

echo "  Installing AUCOOP Welcome..."

sudo mkdir -p "$TARGET_DIR"
sudo cp -r "$SOURCE_DIR"/* "$TARGET_DIR/"
sudo chmod +x "$TARGET_DIR/aucoop_welcome.py" "$TARGET_DIR/essential-setup.sh" "$TARGET_DIR/install-module.sh" "$TARGET_DIR/install-local-ai.sh" "$TARGET_DIR/pkexec-runner.sh" "$TARGET_DIR/run-workbench-registration.sh"
sudo cp "$SOURCE_DIR/aucoop-welcome.desktop" /usr/share/applications/aucoop-welcome.desktop

mkdir -p "$DESKTOP_DIR"
cp /usr/share/applications/aucoop-welcome.desktop "$DESKTOP_DIR/aucoop-welcome.desktop"
chmod +x "$DESKTOP_DIR/aucoop-welcome.desktop"
gio set "$DESKTOP_DIR/aucoop-welcome.desktop" metadata::trusted true 2>/dev/null || true
