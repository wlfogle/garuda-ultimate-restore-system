# Ultimate Configuration Backup Script
BACKUP_DIR="/home/lou/backups/configs"
DATE=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="system-configs-$DATE.tar.gz"

echo "Starting configuration backup - $DATE"

# List of important config directories and files
CONFIGS=(
    "/etc"
    "/home/lou/.config"
    "/home/lou/.local"
    "/home/lou/.bashrc"
    "/home/lou/.zshrc"
    "/home/lou/.profile"
    "/home/lou/.xinitrc"
    "/home/lou/.Xresources"
    "/boot/grub"
    "/usr/share/applications"
)

# Create temporary list of existing configs
EXISTING_CONFIGS=()
for config in "${CONFIGS[@]}"; do
    if [ -e "$config" ]; then
        EXISTING_CONFIGS+=("$config")
    fi
done

# Create archive
tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" "${EXISTING_CONFIGS[@]}" 2>/dev/null || true

# Backup fstab separately
cp /etc/fstab "$BACKUP_DIR/fstab-$DATE" 2>/dev/null || true

# Keep only last 7 config backups
find "$BACKUP_DIR" -name "system-configs-*.tar.gz" -type f | sort -r | tail -n +8 | xargs -r rm

echo "Configuration backup completed: $ARCHIVE_NAME"
