# Daily Automated Backup Script
BACKUP_DIR="./user_home/backups"
LOG_FILE="$BACKUP_DIR/backup.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting daily backup" >> "$LOG_FILE"

# Run package backup
bash "$BACKUP_DIR/scripts/backup-packages.sh" >> "$LOG_FILE" 2>&1

# Run config backup
bash "$BACKUP_DIR/scripts/backup-configs.sh" >> "$LOG_FILE" 2>&1

# Create Timeshift snapshot
if command -v timeshift &> /dev/null; then
    timeshift --create --comments "Daily auto backup $(date +%Y%m%d)" >> "$LOG_FILE" 2>&1
fi

# Sync to external drive if mounted (modify path as needed)
EXTERNAL_BACKUP="/mnt/external/backups"
if [ -d "$EXTERNAL_BACKUP" ]; then
    rsync -av --delete "$BACKUP_DIR/" "$EXTERNAL_BACKUP/" >> "$LOG_FILE" 2>&1
    echo "[$DATE] Synced to external drive" >> "$LOG_FILE"
fi

echo "[$DATE] Daily backup completed" >> "$LOG_FILE"

# Keep log file under 10MB
if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt 10485760 ]; then
    tail -n 1000 "$LOG_FILE" > "$LOG_FILE.tmp"
    mv "$LOG_FILE.tmp" "$LOG_FILE"
fi
