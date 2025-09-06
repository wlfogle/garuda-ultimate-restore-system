---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**System Information:**
- Garuda Linux Edition: [e.g. KDE Dr460nized, GNOME]
- Kernel Version: [run `uname -r`]
- Filesystem: [run `lsblk -f`]
- Available Space: [run `df -h`]

**Script Output**
If applicable, add the output from:
```bash
~/backups/scripts/backup-status.sh
```

**Additional context**
Add any other context about the problem here.

**Log Files**
If applicable, attach relevant portions of:
- `~/backups/backup.log`
- System journal: `journalctl -u snapper-timeline.timer --since today`
