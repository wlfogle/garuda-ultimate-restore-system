# Changelog

## [v2.0.0] - 2025-09-06 - CRITICAL FIX: External Storage Priority

### 🚨 BREAKING CHANGES & CRITICAL FIXES
- **FIXED MAJOR DESIGN FLAW**: Backup system no longer stores backups in `/home` by default
- **NEW**: External storage is now prioritized automatically - backups survive system reinstalls
- **BREAKING**: Default backup location changed from `/home/$USER/backups` to external drives

### ✨ New Features
- **Smart Storage Detection**: Automatically finds and uses external drives
- **Reinstall-Safe Backups**: Backups stored externally survive complete system wipes
- **Storage Type Warnings**: Clear warnings when using internal storage (risky)
- **Improved Restore Interface**: Enhanced menu system with backup location detection
- **External Drive Priority**: Checks `/run/media/`, `/mnt/`, `/media/` locations first

### 🔧 Technical Improvements
- **Auto-Mount Detection**: Scans for mounted external drives automatically
- **Fallback Strategy**: Uses local storage only as last resort with warnings
- **Better Error Handling**: Improved error messages and validation
- **Robust Path Handling**: Fixed glob pattern issues in location detection

### 📋 Storage Priority Order
1. `/run/media/$USER/*/Home-Backup` (User external drives)
2. `/run/media/$USER/*/garuda-backups` 
3. `/run/media/$USER/*/Backups`
4. `/mnt/*/backups` (Mounted drives)
5. `/media/*/backups`
6. `/opt/garuda-backups` (Local fallback - WARNING issued)
7. `/var/backups/garuda` (Local fallback - WARNING issued)

### 🛠️ Migration Guide
If you have existing backups in `/home/$USER/backups`:
1. Connect an external drive
2. Copy backups: `cp -r /home/$USER/backups /path/to/external/drive/`
3. Use new scripts that automatically detect external storage
4. Old backups in `/home` will be lost during reinstall

### 🔄 New Scripts
- `daily-backup-improved.sh` - External storage priority backup
- `restore-system-improved.sh` - Enhanced restore with external drive support

### ⚠️ Important Notes
- **This fixes the critical flaw** where backups would be lost during system reinstalls
- External storage is now **mandatory** for safe backups
- System will warn if forced to use internal storage
- Existing installations should migrate backups to external storage immediately

---

## [v1.0.0] - Previous Version
- Original backup system with `/home` storage (UNSAFE for reinstalls)
- Basic package and configuration backup
- Timeshift integration
- Local storage only
