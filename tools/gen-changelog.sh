#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-CHANGELOG.md}"
{
  echo "# Build Report $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo
  echo "## /etc/os-release"
  sed 's/^/    /' /etc/os-release || true
  echo
  echo "## Installed packages (sorted)"
  rpm -qa --qf '    %{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n' | sort
  echo
  echo "## DNF history (last 20)"
  dnf history | head -n 40 | sed 's/^/    /'
} > "$OUT"
echo "Wrote $OUT"
