# Ultimate Configuration Backup Script
BACKUP_DIR="./user_home/backups/configs"
DATE=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="system-configs-$DATE.tar.gz"

echo "Starting configuration backup - $DATE"

# List of important config directories and files
CONFIGS=(
    "/etc"
    "./user_home/.config"
    "./user_home/.local"
    "./user_home/.bashrc"
    "./user_home/.zshrc"
    "./user_home/.profile"
    "./user_home/.xinitrc"
    "./user_home/.Xresources"
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
cp ./config/fstab "$BACKUP_DIR/fstab-$DATE" 2>/dev/null || true

# Keep only last 7 config backups
find "$BACKUP_DIR" -name "system-configs-*.tar.gz" -type f | sort -r | tail -n +8 | xargs -r rm

echo "Configuration backup completed: $ARCHIVE_NAME"
