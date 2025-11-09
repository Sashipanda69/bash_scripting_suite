#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.cfg"

if command -v apt-get >/dev/null; then
  PM="apt"
elif command -v dnf >/dev/null; then
  PM="dnf"
elif command -v yum >/dev/null; then
  PM="yum"
else
  PM="none"
fi

echo "Detected package manager: $PM (demo: not performing package updates in sandbox)"
if [[ "$PM" == "none" ]]; then
  echo "No supported package manager found or running in restricted environment. Skipping updates."
else
  echo "Skipping actual update in demo environment to avoid changes."
fi

if command -v journalctl >/dev/null; then
  echo "Rotating journal (demo skip)"
fi

echo "Update & cleanup (demo) finished."
exit 0
