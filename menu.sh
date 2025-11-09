#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PS3="Select an option: "
options=(
  "Run Backup"
  "Run Update & Cleanup"
  "Run Log Monitor"
  "Generate User & Disk Report"
  "Schedule Daily Backup at 02:00 (cron)"
  "Exit"
)
select opt in "${options[@]}"; do
  case $REPLY in
    1) "$SCRIPT_DIR/backup.sh";;
    2) "$SCRIPT_DIR/update_cleanup.sh";;
    3) "$SCRIPT_DIR/log_monitor.sh";;
    4) "$SCRIPT_DIR/user_disk_report.sh";;
    5)
      cron_line="0 2 * * * $SCRIPT_DIR/backup.sh >> $SCRIPT_DIR/../reports/cron_backup.log 2>&1"
      (crontab -l 2>/dev/null | grep -Fv "$SCRIPT_DIR/backup.sh" ; echo "$cron_line") | crontab -
      echo "Scheduled daily backup at 02:00."
      ;;
    6) echo "Goodbye."; break;;
    *) echo "Invalid option.";;
  esac
done
