# ULTIMATE SYSTEM RESTORE SCRIPT
# Run with: sudo bash restore-system.sh

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo bash $0"
    exit 1
fi

BACKUP_DIR="./user_home/backups"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== ULTIMATE GARUDA LINUX RESTORE SYSTEM ===${NC}"
echo -e "${YELLOW}What would you like to restore?${NC}"
echo "1) Restore packages from backup"
echo "2) Restore configurations from backup"
echo "3) Restore from Timeshift snapshot"
echo "4) Restore from Snapper snapshot"
echo "5) Full system restore (packages + configs)"
echo "6) Emergency repair (fix boot/grub)"
echo "0) Exit"
read -p "Choose option [0-6]: " choice

case $choice in
    1)
        echo -e "${BLUE}Available package backups:${NC}"
        ls -lt "$BACKUP_DIR/packages/" | grep "native-packages"
        read -p "Enter date (YYYYMMDD_HHMMSS) or 'latest': " date_choice
        
        if [ "$date_choice" = "latest" ]; then
            NATIVE_FILE=$(ls -t "$BACKUP_DIR/packages/native-packages-"*.txt | head -1)
            AUR_FILE=$(ls -t "$BACKUP_DIR/packages/aur-packages-"*.txt | head -1)
        else
            NATIVE_FILE="$BACKUP_DIR/packages/native-packages-$date_choice.txt"
            AUR_FILE="$BACKUP_DIR/packages/aur-packages-$date_choice.txt"
        fi
        
        if [ -f "$NATIVE_FILE" ]; then
            echo -e "${GREEN}Restoring native packages...${NC}"
            pacman -S --needed $(cat "$NATIVE_FILE")
        fi
        
        if [ -f "$AUR_FILE" ] && command -v yay &> /dev/null; then
            echo -e "${GREEN}Restoring AUR packages...${NC}"
            yay -S --needed $(cat "$AUR_FILE")
        fi
        ;;
    2)
        echo -e "${BLUE}Available config backups:${NC}"
        ls -lt "$BACKUP_DIR/configs/" | grep "system-configs"
        read -p "Enter date (YYYYMMDD_HHMMSS) or 'latest': " date_choice
        
        if [ "$date_choice" = "latest" ]; then
            CONFIG_FILE=$(ls -t "$BACKUP_DIR/configs/system-configs-"*.tar.gz | head -1)
        else
            CONFIG_FILE="$BACKUP_DIR/configs/system-configs-$date_choice.tar.gz"
        fi
        
        if [ -f "$CONFIG_FILE" ]; then
            read -p "Continue? [y/N]: " confirm
            if [[ $confirm =~ ^[Yy]$ ]]; then
                echo -e "${GREEN}Restoring configurations...${NC}"
                tar -xzf "$CONFIG_FILE" -C /
            fi
        fi
        ;;
    3)
        if command -v timeshift &> /dev/null; then
            echo -e "${BLUE}Available Timeshift snapshots:${NC}"
            timeshift --list
            read -p "Enter snapshot name to restore: " snapshot
            timeshift --restore --snapshot "$snapshot"
        else
        fi
        ;;
    4)
        if command -v snapper &> /dev/null; then
            echo -e "${BLUE}Available Snapper snapshots:${NC}"
            snapper list
            read -p "Enter snapshot number to restore: " snapshot_num
            snapper undochange $snapshot_num..0
        else
        fi
        ;;
    5)
        read -p "Continue? [y/N]: " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            # Run both package and config restore
            bash $0 # Restart script for package restore
        fi
        ;;
    6)
        echo -e "${BLUE}Emergency boot repair...${NC}"
        echo "Reinstalling GRUB..."
        grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=garuda
        grub-mkconfig -o /boot/grub/grub.cfg
        ;;
    0)
        echo "Exiting..."
        exit 0
        ;;
    *)
        ;;
esac
