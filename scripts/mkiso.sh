#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# mkiso.sh – ISO Build Script for OS-LVirt-Migrationassistant
#
# This script wraps livemedia-creator for reproducible, container-safe builds.
# It is designed for use inside GitHub Actions and Rocky Linux containers.
#
# Key features:
#   - uses `--no-virt` and `--image-only` (no /dev/loop needed)
#   - auto-cleans previous builds
#   - generates SHA256 checksum
#   - optional bootable ISO integrity check
# -----------------------------------------------------------------------------

set -euxo pipefail

KS_FILE="$1"
OUTDIR="$2"

echo "=== OS-LVirt mkiso.sh – Starting ISO build ==="
echo "Kickstart: $KS_FILE"
echo "Output dir: $OUTDIR"
echo ""

# -----------------------------------------------------------------------------
# 🧹 Cleanup previous runs
# -----------------------------------------------------------------------------
if [ -d "$OUTDIR" ]; then
  echo "Removing previous result dir: $OUTDIR"
  rm -rf "$OUTDIR"
fi

# -----------------------------------------------------------------------------
# 🧱 Run livemedia-creator
# -----------------------------------------------------------------------------
echo "=== Running livemedia-creator ==="

livemedia-creator \
  --no-virt \
  --image-only \
  --make-iso \
  --ks "$KS_FILE" \
  --project "OS-LVirt-Migrationassistant" \
  --volid "OSLVIRT_MIGRATION" \
  --resultdir "$OUTDIR" \
  --iso-only \
  --logfile "$OUTDIR/lmc.log"

echo ""
echo "=== ISO build complete ==="
ls -lh "$OUTDIR" || true

# -----------------------------------------------------------------------------
# 🧮 Generate SHA256 checksum
# -----------------------------------------------------------------------------
ISO_FILE=$(ls "$OUTDIR"/*.iso | head -n1 || true)
if [ -f "$ISO_FILE" ]; then
  echo "Generating SHA256 checksum..."
  sha256sum "$ISO_FILE" > "${ISO_FILE}.sha256"
else
  echo "❌ ERROR: ISO file not found in $OUTDIR"
  exit 10
fi

# -----------------------------------------------------------------------------
# 🔍 Optional: Boot image integrity check
# -----------------------------------------------------------------------------
if command -v xorriso >/dev/null 2>&1; then
  echo ""
  echo "=== Checking ISO boot structure (xorriso) ==="
  xorriso -indev "$ISO_FILE" -report_el_torito as_mkisofs || true
elif command -v isoinfo >/dev/null 2>&1; then
  echo ""
  echo "=== Checking ISO boot structure (isoinfo) ==="
  isoinfo -d -i "$ISO_FILE" || true
else
  echo ""
  echo "⚠️  Neither xorriso nor isoinfo found – skipping boot check"
fi

# -----------------------------------------------------------------------------
# ✅ Summary
# -----------------------------------------------------------------------------
echo ""
echo "=== Build summary ==="
du -h "$ISO_FILE" || true
sha256sum "$ISO_FILE" || true

echo ""
echo "✅ ISO build finished successfully!"
echo "Result: $ISO_FILE"
echo "Checksum: ${ISO_FILE}.sha256"
