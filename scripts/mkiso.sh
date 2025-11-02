#!/usr/bin/env bash
set -euo pipefail

KS=${1:-kickstart/ks.cfg}
OUTDIR=${2:-build}
ISO_NAME=${ISO_NAME:-OS-LVirt-Migrationassistant-$(date +%Y%m%d)}
ISO_LABEL=${ISO_LABEL:-OS_LVIRT_P2V}
RELEASEVER=${RELEASEVER:-10}

# Remove existing build folder if present (LMC requires clean dir)
if [ -d "${OUTDIR}" ]; then
  echo "Cleaning existing build directory: ${OUTDIR}"
  rm -rf "${OUTDIR:?}/"*
fi

# Dependencies (Container/Host)
dnf -y install lorax lorax-lmc-virt anaconda-tui pykickstart || true

# Kickstart validation
if ! command -v ksvalidator >/dev/null 2>&1; then
  echo "ERROR: ksvalidator not found"; exit 1
fi
ksvalidator "${KS}"

# Optional: reproducible timestamp
export SOURCE_DATE_EPOCH=$(date -r "${KS}" +%s 2>/dev/null || date +%s)

# Run LMC build (creates OUTDIR automatically)
livemedia-creator \
  --make-iso \
  --ks "${KS}" \
  --no-virt \
  --project "OS-LVirt-Migrationassistant" \
  --releasever "${RELEASEVER}" \
  --volid "${ISO_LABEL}" \
  --iso-only \
  --iso-name "${ISO_NAME}.iso" \
  --resultdir "${OUTDIR}" \
  --logfile "${OUTDIR}/lmc.log"

# Checksums
pushd "${OUTDIR}" >/dev/null
sha256sum "${ISO_NAME}.iso" > "${ISO_NAME}.iso.sha256"
popd >/dev/null

echo "ISO ready: ${OUTDIR}/${ISO_NAME}.iso"
