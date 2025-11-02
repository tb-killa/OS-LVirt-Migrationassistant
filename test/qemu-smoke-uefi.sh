#!/usr/bin/env bash
set -euo pipefail
ISO="$1"
OVMF_CODE=${OVMF_CODE:-/usr/share/OVMF/OVMF_CODE.fd}
[ -f "$OVMF_CODE" ] || OVMF_CODE=/usr/share/OVMF/OVMF_CODE_4M.fd

timeout 900 qemu-system-x86_64 \
  -m 2048 -smp 2 -nographic \
  -drive if=pflash,format=raw,unit=0,readonly=on,file="$OVMF_CODE" \
  -cdrom "$ISO" \
  -boot d \
  -no-reboot \
  -serial mon:stdio \
  -append "console=ttyS0 rd.live.ram rd.auto=1" | \
  stdbuf -oL tr -d '\r' | tee boot-uefi.log | \
  grep -m1 -E "Welcome to|EFI|Rocky Linux|dracut"
