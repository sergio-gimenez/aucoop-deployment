#!/bin/bash

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <overlay-disk.qcow2> [ssh-port]"
  exit 1
fi

OVERLAY_DISK="$1"
SSH_PORT="${2:-2222}"

qemu-system-x86_64 \
  -enable-kvm \
  -machine q35,accel=kvm \
  -cpu host \
  -smp 4 \
  -m 8192 \
  -drive if=virtio,format=qcow2,file="$OVERLAY_DISK" \
  -display gtk \
  -device virtio-vga \
  -device intel-hda -device hda-duplex \
  -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22 \
  -device virtio-net-pci,netdev=net0
