# Ultimate Package Backup Script
BACKUP_DIR="/home/lou/backups/packages"
DATE=$(date +%Y%m%d_%H%M%S)

echo "Starting package backup - $DATE"

# Backup native packages
pacman -Qqen > "$BACKUP_DIR/native-packages-$DATE.txt"
pacman -Qqem > "$BACKUP_DIR/aur-packages-$DATE.txt"

# Backup package info with versions
pacman -Q > "$BACKUP_DIR/all-packages-with-versions-$DATE.txt"

# Keep only last 10 backups
find "$BACKUP_DIR" -name "*packages*" -type f | sort -r | tail -n +31 | xargs -r rm

echo "Package backup completed"
