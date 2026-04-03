#!/bin/bash

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <linuxmint.iso> <base-disk.qcow2>"
  exit 1
fi

ISO="$1"
BASE_DISK="$2"

qemu-system-x86_64 \
  -enable-kvm \
  -machine q35,accel=kvm \
  -cpu host \
  -smp 4 \
  -m 8192 \
  -boot d \
  -drive if=virtio,format=qcow2,file="$BASE_DISK" \
  -cdrom "$ISO" \
  -display gtk \
  -device virtio-vga \
  -device intel-hda -device hda-duplex \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device virtio-net-pci,netdev=net0
