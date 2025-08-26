# 🛡️ Garuda Linux Ultimate Restore System

> **The most comprehensive, bulletproof backup and restore solution for Garuda Linux**

A complete disaster recovery system that provides multiple layers of protection against system failures, data corruption, package conflicts, and hardware issues.

## ✨ Features

- 🔄 **Automated Daily Backups** - Set it and forget it
- 📦 **Complete Package Management** - Track and restore all installed packages  
- ⚙️ **Configuration Preservation** - Backup all system and user configurations
- 📸 **Multiple Snapshot Systems** - Timeshift + Snapper integration
- 🚑 **Emergency Recovery** - Boot repair and disaster recovery tools
- 🎯 **One-Click Restore** - Easy-to-use restoration interface
- 📊 **Status Monitoring** - Check backup health and history
- 💾 **External Drive Sync** - Automatic off-site backups

## 🚀 Quick Start

### Installation
```bash
# Clone the repository
git clone https://github.com/wlfogle/garuda-ultimate-restore-system.git
cd garuda-ultimate-restore-system

# Run the installation script
sudo ./install.sh
```

### Basic Usage
```bash
# Run the main restore interface
sudo /home/$USER/backups/scripts/restore-system.sh

# Check backup status
/home/$USER/backups/scripts/backup-status.sh

# Manual backup
/home/$USER/backups/scripts/daily-backup.sh
```

## 📋 What Gets Backed Up

- **System Packages**: Complete list of native and AUR packages
- **Configurations**: `/etc/`, `~/.config/`, `~/.local/`, and other critical configs
- **Boot Configuration**: GRUB settings and boot files
- **User Data**: Desktop files and custom applications
- **System State**: Complete filesystem snapshots via Timeshift/Snapper

## 🔧 Recovery Scenarios

| Scenario | Solution | Recovery Time |
|----------|----------|---------------|
| System won't boot | Emergency boot repair | ~5 minutes |
| Broken package system | Package restoration | ~15 minutes |
| Corrupted configurations | Config file restoration | ~5 minutes |
| Bad system update | Snapshot rollback | ~10 minutes |
| Complete system failure | Full restoration | ~30 minutes |
| Hardware failure | New system setup | ~1 hour |

## 🗂️ System Architecture

```
/home/$USER/backups/
├── scripts/                  # All backup and restore scripts
│   ├── restore-system.sh     # Main restoration interface
│   ├── backup-status.sh      # System status checker
│   ├── daily-backup.sh       # Automated backup runner
│   ├── backup-packages.sh    # Package list backup
│   └── backup-configs.sh     # Configuration backup
├── packages/                 # Package lists and versions
├── configs/                  # Configuration archives
├── data/                     # User data backups
├── RESTORE_GUIDE.md         # Detailed recovery procedures
└── backup.log              # Operation history
```

## 🚨 Emergency Recovery

### From Live USB
```bash
# Boot from Garuda live USB
sudo mount /dev/nvme0n1p2 /mnt  # Adjust device as needed
sudo arch-chroot /mnt
bash /home/$USER/backups/scripts/restore-system.sh
```

### Boot Repair Only
```bash
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=garuda
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 📊 Backup Schedule

- **Daily at 2 AM**: Automated backups via cron
- **Before system updates**: Automatic snapshots via Snapper
- **Manual**: Run scripts anytime
- **External sync**: Daily sync to mounted external drives

## 🛠️ System Requirements

- **Garuda Linux** (any edition)
- **BTRFS filesystem** (for snapshots)
- **Minimum 2GB free space** for backups
- **Optional**: External drive for off-site backups

## 📖 Documentation

- [Installation Guide](docs/installation.md)
- [Recovery Procedures](docs/recovery.md)
- [Configuration Options](docs/configuration.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Advanced Usage](docs/advanced.md)

## 🔍 Testing Your Backups

**Critical**: Always test your restore procedures!

```bash
# Check backup integrity
/home/$USER/backups/scripts/backup-status.sh

# Verify recent backups exist
ls -la /home/$USER/backups/packages/
ls -la /home/$USER/backups/configs/

# Test package restoration (dry run)
echo "Test packages:" $(head -5 /home/$USER/backups/packages/native-packages-*.txt)
```

## 🤝 Contributing

Found a bug or want to improve the system? Contributions welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues**: Use GitHub Issues for bugs and feature requests
- **Garuda Forum**: [forum.garudalinux.org](https://forum.garudalinux.org/)
- **Documentation**: Check the `docs/` directory

## ⚡ Quick Commands Reference

| Command | Purpose |
|---------|---------|
| `sudo ./scripts/restore-system.sh` | Main restoration menu |
| `./scripts/backup-status.sh` | Check system status |
| `./scripts/daily-backup.sh` | Run manual backup |
| `sudo timeshift --list` | List Timeshift snapshots |
| `sudo snapper list` | List Snapper snapshots |
| `crontab -l` | View scheduled backups |

---

**⚠️ Remember**: The best backup is the one you've tested!

Built with ❤️ for the Garuda Linux community.
