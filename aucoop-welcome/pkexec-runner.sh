#!/bin/bash

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <essential-setup|install-module> [args...]"
  exit 1
fi

APP_DIR="$(cd "$(dirname "$0")" && pwd)"
ACTION="$1"
shift

case "$ACTION" in
  essential-setup)
    exec "$APP_DIR/essential-setup.sh" "$@"
    ;;
  install-module)
    exec "$APP_DIR/install-module.sh" "$@"
    ;;
  *)
    echo "Unknown action: $ACTION"
    exit 1
    ;;
esac
