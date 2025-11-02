#!/usr/bin/env bash
set -euo pipefail
LOG=/var/log/auto-storage.log
exec >>"$LOG" 2>&1
echo "== Auto Storage Detection (RO) =="

command -v mdadm >/dev/null && mdadm --assemble --scan || true
command -v vgchange >/dev/null && vgchange -ay || true
command -v dmraid >/dev/null && dmraid -ay || true

mkdir -p /mnt/src
lsblk -rno NAME,TYPE | awk '$2=="part"{print $1}' | while read -r part; do
  dev="/dev/${part}"
  fstype=$(blkid -s TYPE -o value "$dev" || true)
  mp="/mnt/src/${part}"
  [ -z "$fstype" ] && continue
  mkdir -p "$mp"
  case "$fstype" in
    ntfs)  mount -t ntfs-3g -o ro "$dev" "$mp" || rmdir "$mp" ;;
    exfat) mount -t exfat   -o ro "$dev" "$mp" || rmdir "$mp" ;;
    vfat|msdos|fat) mount -t vfat -o ro "$dev" "$mp" || rmdir "$mp" ;;
    xfs|ext4|ext3|ext2|btrfs) mount -o ro "$dev" "$mp" || rmdir "$mp" ;;
    *) echo "Skip $dev (fstype=$fstype)"; rmdir "$mp" || true ;;
  esac
done
echo "== Done =="
