#!/bin/bash
# Garuda Ultimate Restore System Installer

set -euo pipefail

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${BLUE}=== Garuda Ultimate Restore System Installer ===${NC}"
echo

# Get the actual username
ACTUAL_USER=${SUDO_USER:-$(logname)}
USER_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

echo -e "${YELLOW}Installing for user: $ACTUAL_USER${NC}"
echo -e "${YELLOW}User home: $USER_HOME${NC}"

# Install required packages
echo -e "${BLUE}Installing required packages...${NC}"
pacman -S --needed --noconfirm snapper timeshift rsync rclone cronie

# Create backup directory structure
echo -e "${BLUE}Creating backup directories...${NC}"
mkdir -p "$USER_HOME/backups/{configs,data,packages,scripts}"

# Copy scripts
echo -e "${BLUE}Installing backup scripts...${NC}"
cp scripts/*.sh "$USER_HOME/backups/scripts/"
chmod +x "$USER_HOME/backups/scripts/"*.sh

# Copy documentation
cp docs/RESTORE_GUIDE.md "$USER_HOME/backups/"

# Set up ownership
chown -R "$ACTUAL_USER:$ACTUAL_USER" "$USER_HOME/backups/"

# Enable services
echo -e "${BLUE}Enabling backup services...${NC}"
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer
systemctl enable cronie.service

# Set up cron job
echo -e "${BLUE}Setting up automated backups...${NC}"
(crontab -u "$ACTUAL_USER" -l 2>/dev/null || true; echo "0 2 * * * $USER_HOME/backups/scripts/daily-backup.sh") | crontab -u "$ACTUAL_USER" -

# Create desktop shortcut
mkdir -p "$USER_HOME/Desktop"
cat > "$USER_HOME/Desktop/Ultimate-Restore-System.desktop" << DESKTOP_EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Ultimate Restore System
Comment=Comprehensive system backup and restore tools
Exec=konsole -e 'sudo $USER_HOME/backups/scripts/restore-system.sh'
Icon=system-reboot
Terminal=false
Categories=System;
StartupNotify=true
DESKTOP_EOF

chmod +x "$USER_HOME/Desktop/Ultimate-Restore-System.desktop"
chown "$ACTUAL_USER:$ACTUAL_USER" "$USER_HOME/Desktop/Ultimate-Restore-System.desktop"

# Run initial backups
echo -e "${BLUE}Running initial backups...${NC}"
runuser -l "$ACTUAL_USER" -c "$USER_HOME/backups/scripts/backup-packages.sh"
runuser -l "$ACTUAL_USER" -c "$USER_HOME/backups/scripts/backup-configs.sh"

echo
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo
echo -e "${YELLOW}Your system now has comprehensive backup protection:${NC}"
echo "• Automated daily backups at 2 AM"
echo "• Desktop shortcut created"
echo "• Emergency recovery tools ready"
echo
echo -e "${YELLOW}To use:${NC}"
echo "• Main menu: sudo $USER_HOME/backups/scripts/restore-system.sh"
echo "• Check status: $USER_HOME/backups/scripts/backup-status.sh"
echo "• Manual backup: $USER_HOME/backups/scripts/daily-backup.sh"
echo
echo -e "${GREEN}Documentation: $USER_HOME/backups/RESTORE_GUIDE.md${NC}"
