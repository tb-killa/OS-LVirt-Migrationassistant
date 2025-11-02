#!/usr/bin/env bash
set -euo pipefail
OUTFILE=${1:-build/CHANGELOG.md}

echo "# OS-LVirt-Migrationassistant Build Summary" > "$OUTFILE"
echo "" >> "$OUTFILE"

if [ -n "${RELEASEVER:-}" ]; then
  echo "## Rocky Linux ${RELEASEVER} Build" >> "$OUTFILE"
fi

if [ -n "${TAG:-}" ]; then
  echo "- Channel: ${TAG}" >> "$OUTFILE"
fi

echo "- Build Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" >> "$OUTFILE"
echo "" >> "$OUTFILE"

echo "### DNF Package Snapshot" >> "$OUTFILE"
echo '```' >> "$OUTFILE"
dnf list installed | sort >> "$OUTFILE" 2>/dev/null || echo "(Package list unavailable)" >> "$OUTFILE"
echo '```' >> "$OUTFILE"
