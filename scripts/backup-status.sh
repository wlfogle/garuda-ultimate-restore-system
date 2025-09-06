# Backup System Status Checker

BACKUP_DIR='./user_home/backups'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e '${BLUE}=== BACKUP SYSTEM STATUS ===${NC}'
echo

# Check last backup dates
echo -e '${YELLOW}📁 Recent Backups:${NC}'
echo "Package backups:"
ls -lt $BACKUP_DIR/packages/native-packages-*.txt | head -3 | awk '{print "  " $6 " " $7 " " $8 " - " $9}'

echo "Config backups:"
ls -lt $BACKUP_DIR/configs/system-configs-*.tar.gz | head -3 | awk '{print "  " $6 " " $7 " " $8 " - " $9}'

echo
echo -e '${YELLOW}📊 Disk Usage:${NC}'
du -sh $BACKUP_DIR/* 2>/dev/null | while read size dir; do
    echo "  $(basename $dir): $size"
done

echo
echo -e '${YELLOW}⏰ Scheduled Backups:${NC}'
if crontab -u lou -l | grep -q backup; then
    echo -e "  ${GREEN}✅ Daily backups are scheduled${NC}"
else
    echo -e "  ${YELLOW}⚠️  No scheduled backups found${NC}"
fi

echo
echo -e '${YELLOW}🔄 Snapshot Systems:${NC}'
if command -v snapper &> /dev/null && snapper list &> /dev/null; then
    SNAP_COUNT=$(snapper list | wc -l)
    echo -e "  ${GREEN}✅ Snapper: $SNAP_COUNT snapshots${NC}"
else
    echo -e "  ${YELLOW}⚠️  Snapper not available${NC}"
fi

if command -v timeshift &> /dev/null; then
    echo -e "  ${GREEN}✅ Timeshift available${NC}"
else
    echo -e "  ${YELLOW}⚠️  Timeshift not available${NC}"
fi

echo
echo -e '${GREEN}🚀 Quick Commands:${NC}'
echo "  View backups: ls -la $BACKUP_DIR/"
echo "  Run backup: $BACKUP_DIR/scripts/daily-backup.sh"
echo "  Restore system: sudo $BACKUP_DIR/scripts/restore-system.sh"
