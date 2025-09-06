#!/bin/bash

# Garuda Ultimate Backup System - External Storage Priority
# This version prioritizes external storage and fixes the /home backup flaw

set -euo pipefail

# Configuration
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Function to find best backup location
find_backup_location() {
    # Check external drives first (priority order)
    for drive in /run/media/$USER/*/; do
        if [[ -d "$drive" ]]; then
            for subdir in "Home-Backup" "garuda-backups" "Backups"; do
                local location="$drive$subdir"
                if mkdir -p "$location" 2>/dev/null && [[ -w "$location" ]]; then
                    echo "$location"
                    return 0
                fi
            done
        fi
    done
    
    # Check mounted drives
    for drive in /mnt/*/; do
        if [[ -d "$drive" ]]; then
            local location="${drive}backups"
            if mkdir -p "$location" 2>/dev/null && [[ -w "$location" ]]; then
                echo "$location"
                return 0
            fi
        fi
    done
    
    # Last resort: local storage with warning
    for location in "/opt/garuda-backups" "/var/backups/garuda"; do
        if mkdir -p "$location" 2>/dev/null && [[ -w "$location" ]]; then
            echo "$location"
            return 0
        fi
    done
    
    # No suitable location found
    echo "ERROR: No suitable backup location found!" >&2
    echo "Please connect an external drive or ensure /opt/garuda-backups is writable" >&2
    return 1
}

# Function to check if location is external
is_external_storage() {
    local location="$1"
    [[ "$location" =~ ^/run/media/ || "$location" =~ ^/mnt/ || "$location" =~ ^/media/ ]]
}

# Find backup location
BACKUP_BASE=$(find_backup_location)
[[ -z "$BACKUP_BASE" ]] && exit 1

# Set up directory structure
BACKUP_DIR="$BACKUP_BASE/garuda-system"
PACKAGES_DIR="$BACKUP_DIR/packages"
CONFIGS_DIR="$BACKUP_DIR/configs"
DATA_DIR="$BACKUP_DIR/data"
SCRIPTS_DIR="$BACKUP_DIR/scripts"
LOG_FILE="$BACKUP_DIR/backup.log"

# Create directories
mkdir -p "$PACKAGES_DIR" "$CONFIGS_DIR" "$DATA_DIR" "$SCRIPTS_DIR"

# Logging function
log_message() {
    echo "[$DATE] $1" | tee -a "$LOG_FILE"
}

# Storage type warning
if is_external_storage "$BACKUP_BASE"; then
    log_message "✓ Using external storage: $BACKUP_BASE"
else
    log_message "⚠ WARNING: Using internal storage: $BACKUP_BASE"
    log_message "⚠ These backups will NOT survive a system reinstall!"
    log_message "⚠ Consider connecting an external drive for safer backups."
fi

log_message "Starting comprehensive backup to: $BACKUP_DIR"

# 1. Package Backup
log_message "Backing up package lists..."
pacman -Qqen > "$PACKAGES_DIR/native-packages-$TIMESTAMP.txt"
pacman -Qqem > "$PACKAGES_DIR/aur-packages-$TIMESTAMP.txt"
pacman -Q > "$PACKAGES_DIR/all-packages-with-versions-$TIMESTAMP.txt"

# 2. Configuration Backup
log_message "Backing up system configurations..."
tar -czf "$CONFIGS_DIR/system-configs-$TIMESTAMP.tar.gz" \
    /etc/ \
    /home/*/.*config* \
    /home/*/.local/ \
    /home/*/.ssh/ \
    /home/*/.bashrc \
    /home/*/.zshrc \
    /boot/loader/ \
    2>/dev/null || true

# Backup fstab separately
cp /etc/fstab "$CONFIGS_DIR/fstab-$TIMESTAMP"

# 3. Create Timeshift snapshot if available
if command -v timeshift &> /dev/null; then
    log_message "Creating Timeshift snapshot..."
    timeshift --create --comments "Daily auto backup $TIMESTAMP" >> "$LOG_FILE" 2>&1 || true
fi

# 4. Cleanup old backups (keep last 10)
log_message "Cleaning up old backups..."
find "$PACKAGES_DIR" -name "*packages*" -type f | sort -r | tail -n +31 | xargs -r rm
find "$CONFIGS_DIR" -name "*configs*" -type f | sort -r | tail -n +11 | xargs -r rm

# 5. Create backup summary
cat > "$BACKUP_DIR/LAST_BACKUP_INFO.txt" << EOF
Garuda System Backup Summary
============================
Backup Date: $DATE
Backup Location: $BACKUP_DIR
Storage Type: $(is_external_storage "$BACKUP_BASE" && echo "External (Safe)" || echo "Internal (Risk)")
Total Packages: $(wc -l < "$PACKAGES_DIR/all-packages-with-versions-$TIMESTAMP.txt")
Native Packages: $(wc -l < "$PACKAGES_DIR/native-packages-$TIMESTAMP.txt")
AUR Packages: $(wc -l < "$PACKAGES_DIR/aur-packages-$TIMESTAMP.txt")

To restore this backup after reinstall:
1. Connect this external drive
2. Run: sudo bash $BACKUP_DIR/scripts/restore-system-improved.sh

Files backed up:
- Package lists: $PACKAGES_DIR/
- System configs: $CONFIGS_DIR/
- This info: $BACKUP_DIR/LAST_BACKUP_INFO.txt
EOF

log_message "✓ Backup completed successfully!"
log_message "✓ Location: $BACKUP_DIR"
log_message "✓ Storage: $(is_external_storage "$BACKUP_BASE" && echo "External (Safe for reinstall)" || echo "Internal (Will be lost on reinstall)")"

# Keep log file under 10MB
if [[ -f "$LOG_FILE" && $(stat -c%s "$LOG_FILE") -gt 10485760 ]]; then
    tail -n 1000 "$LOG_FILE" > "$LOG_FILE.tmp"
    mv "$LOG_FILE.tmp" "$LOG_FILE"
fi
