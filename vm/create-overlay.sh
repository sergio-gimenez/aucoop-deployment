#!/bin/bash

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <base-disk.qcow2> <overlay-disk.qcow2>"
  exit 1
fi

BASE_DISK="$1"
OVERLAY_DISK="$2"

mkdir -p "$(dirname "$OVERLAY_DISK")"
qemu-img create -f qcow2 -F qcow2 -b "$BASE_DISK" "$OVERLAY_DISK"
echo "Created overlay $OVERLAY_DISK -> $BASE_DISK"
