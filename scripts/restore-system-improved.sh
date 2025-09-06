#!/bin/bash

# Garuda Ultimate Restore System - External Storage Support
# Works from external drives and survives reinstalls

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to find backup directories
find_backup_directories() {
    local backup_dirs=()
    
    # Search common locations
    for pattern in \
        "/run/media/*/*/garuda-system" \
        "/run/media/*/*/Home-Backup/backups" \
        "/run/media/*/*/backups" \
        "/mnt/*/garuda-system" \
        "/media/*/garuda-system" \
        "/opt/garuda-backups" \
        "/var/backups/garuda"; do
        
        for dir in $pattern 2>/dev/null; do
            if [[ -d "$dir" && -f "$dir/LAST_BACKUP_INFO.txt" ]]; then
                backup_dirs+=("$dir")
            fi
        done
    done
    
    printf '%s\n' "${backup_dirs[@]}"
}

# Function to display backup info
show_backup_info() {
    local backup_dir="$1"
    if [[ -f "$backup_dir/LAST_BACKUP_INFO.txt" ]]; then
        cat "$backup_dir/LAST_BACKUP_INFO.txt"
    else
        echo "Backup directory: $backup_dir"
        echo "No detailed info available"
    fi
}

# Function to restore packages
restore_packages() {
    local packages_dir="$1"
    
    # Find latest package files
    local native_pkg=$(find "$packages_dir" -name "native-packages-*.txt" | sort -r | head -1)
    local aur_pkg=$(find "$packages_dir" -name "aur-packages-*.txt" | sort -r | head -1)
    
    if [[ -z "$native_pkg" ]]; then
        error "No native package backup found!"
        return 1
    fi
    
    log "Restoring native packages from: $(basename "$native_pkg")"
    
    # Update package database first
    info "Updating package database..."
    pacman -Sy --noconfirm
    
    # Install native packages
    if [[ -s "$native_pkg" ]]; then
        info "Installing $(wc -l < "$native_pkg") native packages..."
        pacman -S --needed --noconfirm - < "$native_pkg" || warn "Some native packages failed to install"
    fi
    
    # Install AUR packages if available and yay is installed
    if [[ -s "$aur_pkg" && -x "$(command -v yay)" ]]; then
        info "Installing $(wc -l < "$aur_pkg") AUR packages..."
        sudo -u "$SUDO_USER" yay -S --needed --noconfirm - < "$aur_pkg" || warn "Some AUR packages failed to install"
    elif [[ -s "$aur_pkg" ]]; then
        warn "AUR packages found but yay not installed. Install yay first, then run:"
        warn "yay -S --needed - < $aur_pkg"
    fi
}

# Function to restore configurations
restore_configs() {
    local configs_dir="$1"
    
    # Find latest config archive
    local config_archive=$(find "$configs_dir" -name "system-configs-*.tar.gz" | sort -r | head -1)
    
    if [[ -z "$config_archive" ]]; then
        warn "No configuration backup found!"
        return 1
    fi
    
    log "Restoring configurations from: $(basename "$config_archive")"
    
    # Create backup of current configs
    local backup_current="/tmp/current-configs-backup-$(date +%Y%m%d_%H%M%S).tar.gz"
    info "Backing up current configs to: $backup_current"
    tar -czf "$backup_current" /etc/ /home/ 2>/dev/null || true
    
    # Extract configuration archive
    info "Extracting configuration archive..."
    tar -xzf "$config_archive" -C / --overwrite || warn "Some configuration files failed to restore"
    
    # Restore fstab
    local fstab_backup=$(find "$configs_dir" -name "fstab-*" | sort -r | head -1)
    if [[ -n "$fstab_backup" ]]; then
        info "Restoring fstab..."
        cp "$fstab_backup" /etc/fstab.backup-restored
        warn "fstab backed up as /etc/fstab.backup-restored - review before replacing /etc/fstab"
    fi
}

# Main menu
show_menu() {
    clear
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     Garuda Ultimate Restore System   ║${NC}"
    echo -e "${GREEN}║          External Storage Ready      ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo
    echo "Available backup locations:"
    echo
    
    local backup_dirs=($(find_backup_directories))
    
    if [[ ${#backup_dirs[@]} -eq 0 ]]; then
        error "No backup directories found!"
        echo
        echo "Please ensure:"
        echo "1. External drive with backups is connected"
        echo "2. Drive is mounted (should appear in /run/media/)"
        echo "3. Backup directory contains LAST_BACKUP_INFO.txt"
        echo
        exit 1
    fi
    
    # Display available backups
    local i=1
    for dir in "${backup_dirs[@]}"; do
        echo -e "${BLUE}[$i]${NC} $dir"
        show_backup_info "$dir" | sed 's/^/    /'
        echo
        ((i++))
    done
    
    echo -e "${BLUE}[Q]${NC} Quit"
    echo
    read -p "Select backup to restore from [1-${#backup_dirs[@]}]: " choice
    
    case "$choice" in
        [1-9]*)
            if [[ "$choice" -le ${#backup_dirs[@]} ]]; then
                local selected_dir="${backup_dirs[$((choice-1))]}"
                restore_menu "$selected_dir"
            else
                error "Invalid selection!"
                read -p "Press Enter to continue..."
                show_menu
            fi
            ;;
        [qQ])
            echo "Goodbye!"
            exit 0
            ;;
        *)
            error "Invalid selection!"
            read -p "Press Enter to continue..."
            show_menu
            ;;
    esac
}

# Restore menu for selected backup
restore_menu() {
    local backup_dir="$1"
    
    clear
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           Restore Options             ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo
    echo "Selected backup: $backup_dir"
    echo
    show_backup_info "$backup_dir"
    echo
    echo -e "${BLUE}[1]${NC} Restore packages only"
    echo -e "${BLUE}[2]${NC} Restore configurations only"
    echo -e "${BLUE}[3]${NC} Full restore (packages + configs)"
    echo -e "${BLUE}[4]${NC} View backup contents"
    echo -e "${BLUE}[B]${NC} Back to backup selection"
    echo -e "${BLUE}[Q]${NC} Quit"
    echo
    read -p "Choose restore option [1-4]: " choice
    
    case "$choice" in
        1)
            log "Starting package restoration..."
            restore_packages "$backup_dir/packages"
            log "Package restoration completed!"
            ;;
        2)
            warn "This will overwrite current system configurations!"
            read -p "Are you sure? [y/N]: " confirm
            if [[ "$confirm" =~ ^[yY] ]]; then
                log "Starting configuration restoration..."
                restore_configs "$backup_dir/configs"
                log "Configuration restoration completed!"
            fi
            ;;
        3)
            warn "This will restore packages and overwrite system configurations!"
            read -p "Are you sure? [y/N]: " confirm
            if [[ "$confirm" =~ ^[yY] ]]; then
                log "Starting full system restoration..."
                restore_packages "$backup_dir/packages"
                restore_configs "$backup_dir/configs"
                log "Full system restoration completed!"
            fi
            ;;
        4)
            clear
            echo "Backup Contents:"
            echo "================"
            find "$backup_dir" -type f -exec ls -lh {} \; | head -20
            echo
            read -p "Press Enter to continue..."
            restore_menu "$backup_dir"
            return
            ;;
        [bB])
            show_menu
            return
            ;;
        [qQ])
            echo "Goodbye!"
            exit 0
            ;;
        *)
            error "Invalid selection!"
            read -p "Press Enter to continue..."
            restore_menu "$backup_dir"
            return
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
    restore_menu "$backup_dir"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root (use sudo)"
    exit 1
fi

# Main execution
log "Starting Garuda Ultimate Restore System..."
show_menu
