#!/bin/bash

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <base-disk.qcow2> [size]"
  exit 1
fi

BASE_DISK="$1"
SIZE="${2:-40G}"

mkdir -p "$(dirname "$BASE_DISK")"
qemu-img create -f qcow2 "$BASE_DISK" "$SIZE"
echo "Created $BASE_DISK ($SIZE)"
