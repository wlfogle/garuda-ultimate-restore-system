# Installation Guide

## Prerequisites

- **Garuda Linux** (any edition)
- **BTRFS filesystem** (required for snapshots)
- **Root access** (sudo privileges)
- **Minimum 2GB free space** for backup storage

## Automatic Installation (Recommended)

```bash
# Clone the repository
git clone https://github.com/wlfogle/garuda-ultimate-restore-system.git
cd garuda-ultimate-restore-system

# Run the installer
sudo ./install.sh
```

The installer will:
- Install required packages (snapper, timeshift, rsync, rclone, cronie)
- Create backup directory structure
- Copy all scripts and documentation
- Enable backup services
- Set up automated daily backups
- Create desktop shortcut
- Run initial backup

## Manual Installation

### 1. Install Dependencies
```bash
sudo pacman -S --needed snapper timeshift rsync rclone cronie
```

### 2. Create Directory Structure
```bash
mkdir -p ~/backups/{configs,data,packages,scripts}
```

### 3. Copy Scripts
```bash
# Copy all scripts from the repository
cp scripts/*.sh ~/backups/scripts/
chmod +x ~/backups/scripts/*.sh
```

### 4. Enable Services
```bash
sudo systemctl enable snapper-timeline.timer
sudo systemctl enable snapper-cleanup.timer
sudo systemctl enable cronie.service
```

### 5. Set Up Automated Backups
```bash
# Add to crontab (runs daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * $HOME/backups/scripts/daily-backup.sh") | crontab -
```

### 6. Run Initial Backup
```bash
~/backups/scripts/backup-packages.sh
~/backups/scripts/backup-configs.sh
```

## Configuration Options

### External Drive Backup
Edit `~/backups/scripts/daily-backup.sh` and modify:
```bash
EXTERNAL_BACKUP="/path/to/your/external/drive/backups"
```

### Cloud Backup Setup
```bash
# Configure cloud storage
rclone config

# Add cloud sync to daily backup script
```

### Custom Backup Paths
Edit `~/backups/scripts/backup-configs.sh` to add/remove paths:
```bash
CONFIGS=(
    "/etc"
    "/home/$USER/.config"
    # Add your custom paths here
)
```

## Verification

After installation, verify everything works:

```bash
# Check backup status
~/backups/scripts/backup-status.sh

# List created files
ls -la ~/backups/

# Check cron job
crontab -l

# Test restore menu (exit without changes)
sudo ~/backups/scripts/restore-system.sh
```

## Troubleshooting

### Permission Issues
```bash
# Fix ownership
sudo chown -R $USER:$USER ~/backups/

# Fix script permissions
chmod +x ~/backups/scripts/*.sh
```

### Service Issues
```bash
# Check service status
systemctl status snapper-timeline.timer
systemctl status cronie.service

# Restart services if needed
sudo systemctl restart snapper-timeline.timer
sudo systemctl restart cronie.service
```

### Disk Space Issues
```bash
# Check space usage
df -h
du -sh ~/backups/

# Clean old backups if needed
find ~/backups/packages/ -name "*.txt" -mtime +30 -delete
find ~/backups/configs/ -name "*.tar.gz" -mtime +30 -delete
```

## Next Steps

After installation:
1. Read the [Recovery Procedures](recovery.md)
2. Test the restore process
3. Set up external/cloud backups
4. Review the backup schedule
5. Document any custom configurations

## Uninstallation

To remove the system:
```bash
# Remove cron job
crontab -l | grep -v daily-backup.sh | crontab -

# Remove backup directory
rm -rf ~/backups/

# Remove desktop shortcut
rm ~/Desktop/Ultimate-Restore-System.desktop

# Optionally remove packages
sudo pacman -R snapper timeshift
```
