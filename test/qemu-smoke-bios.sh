#!/usr/bin/env bash
set -euo pipefail
ISO="$1"
timeout 900 qemu-system-x86_64 \
  -m 2048 -smp 2 -nographic \
  -cdrom "$ISO" \
  -boot d \
  -no-reboot \
  -serial mon:stdio \
  -append "console=ttyS0 rd.live.ram rd.auto=1" | \
  stdbuf -oL tr -d '\r' | tee boot-bios.log | \
  grep -m1 -E "Welcome to|Rocky Linux|dracut"
