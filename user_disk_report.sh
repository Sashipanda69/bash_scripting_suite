#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.cfg"

mkdir -p "$REPORT_DIR"
OUT="$REPORT_DIR/report_$(date +%F).txt"

{
  echo "System Maintenance Report - $(date)"
  echo "Host: $(hostname)"
  echo "----------------------------------------"
  echo "Logged-in users:"
  who || true
  echo
  echo "Last logins (top 10):"
  last -n 10 || true
  echo
  echo "Disk usage (df -h):"
  df -hT --total || true
  echo
  echo "Top 10 largest directories in /home:"
  du -h --max-depth=1 /home 2>/dev/null | sort -hr | head -n 10 || true
  echo
  echo "Top 10 largest files in / (may take time):"
  find / -xdev -type f -printf '%s %p
' 2>/dev/null | sort -nr | head -n 10 | awk '{printf "%s %s\n", $1, $2}'
  echo "----------------------------------------"
  echo "End of report."
} > "$OUT"

echo "Report saved to $OUT"
exit 0
