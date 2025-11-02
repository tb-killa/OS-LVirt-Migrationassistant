#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Variablen / Parameter
# -------------------------------------------------------------------
KS=${1:-kickstart/ks.cfg}
OUTDIR=${2:-build}
RELEASEVER=${RELEASEVER:-9}  # wird im CI übergeben (z.B. 9 oder 10)
TAG=${TAG:-stable}            # optionales Label (z.B. stable/beta)
ISO_DATE=$(date +%Y%m%d)
ISO_NAME=${ISO_NAME:-OS-LVirt-Migrationassistant-${RELEASEVER}-${TAG}-${ISO_DATE}}
ISO_LABEL=${ISO_LABEL:-OS_LVIRT_P2V_${RELEASEVER}}
LOGFILE="${OUTDIR}.log"

# -------------------------------------------------------------------
# Vorbereitungen
# -------------------------------------------------------------------
if [ -d "${OUTDIR}" ]; then
  echo "Removing existing result directory: ${OUTDIR}"
  rm -rf "${OUTDIR}"
fi

# Dracut/lorax Abhängigkeiten (werden meist im Container installiert)
dnf -y install lorax lorax-lmc-virt anaconda-tui pykickstart || true

# Kickstart prüfen
if ! command -v ksvalidator >/dev/null 2>&1; then
  echo "ERROR: ksvalidator not found"; exit 1
fi
ksvalidator "${KS}"

# reproducible timestamp
export SOURCE_DATE_EPOCH=$(date -r "${KS}" +%s 2>/dev/null || date +%s)

# -------------------------------------------------------------------
# livemedia-creator Build
# -------------------------------------------------------------------
echo "Starting livemedia-creator build for Rocky ${RELEASEVER} (${TAG})"
livemedia-creator \
  --make-iso \
  --ks "${KS}" \
  --no-virt \
  --project "OS-LVirt-Migrationassistant-${RELEASEVER}" \
  --releasever "${RELEASEVER}" \
  --volid "${ISO_LABEL}" \
  --iso-only \
  --iso-name "${ISO_NAME}.iso" \
  --resultdir "${OUTDIR}" \
  --logfile "${LOGFILE}"

# -------------------------------------------------------------------
# Checksums
# -------------------------------------------------------------------
pushd "${OUTDIR}" >/dev/null
sha256sum "${ISO_NAME}.iso" > "${ISO_NAME}.iso.sha256"
popd >/dev/null

echo "✅ ISO ready: ${OUTDIR}/${ISO_NAME}.iso"
