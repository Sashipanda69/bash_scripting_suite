#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/config.cfg"

ALERTS=()
for lf in $LOG_FILES; do
  if [[ ! -f $lf ]]; then
    echo "Warning: log file $lf not found, skipping."
    continue
  fi
  matches=$(tail -n 200 "$lf" | grep -Ei "$LOG_PATTERNS" || true)
  if [[ -n $matches ]]; then
    ALERTS+=( "==== $lf ====
$matches" )
  fi
done

if (( ${#ALERTS[@]} == 0 )); then
  echo "No suspicious log entries found."
  exit 0
fi

ALERT_BODY=$(printf "%s

" "${ALERTS[@]}")
echo -e "Log Monitor Alert:
$ALERT_BODY"

if [[ -n "${ALERT_EMAIL:-}" ]]; then
  if command -v mail >/dev/null; then
    printf "%s
" "$ALERT_BODY" | mail -s "Log Monitor Alert on $(hostname)" "$ALERT_EMAIL"
    echo "Alert emailed to $ALERT_EMAIL"
  else
    echo "Mail command not available; install mailutils or mutt to enable email alerts."
  fi
fi

exit 0
