#!/usr/bin/env bash
set -euxo pipefail

KS_FILE="$1"
OUTDIR="$2"

rm -rf "$OUTDIR" || true
mkdir -p "$OUTDIR"

echo "=== Running livemedia-creator ==="

livemedia-creator \
  --no-virt \
  --image-only \
  --make-iso \
  --ks "$KS_FILE" \
  --project "OS-LVirt-Migrationassistant" \
  --volid "OSLVIRT_MIGRATION" \
  --resultdir "$OUTDIR" \
  --iso-only

echo "=== ISO build complete ==="
ls -lh "$OUTDIR" || true
sha256sum "$OUTDIR"/*.iso > "$OUTDIR"/$(basename "$OUTDIR"/*.iso).sha256 || true
