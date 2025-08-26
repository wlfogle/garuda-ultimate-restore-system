# Contributing to Garuda Ultimate Restore System

Thank you for your interest in contributing! This project aims to provide the most reliable backup and restore solution for Garuda Linux users.

## 🤝 How to Contribute

### Reporting Bugs
- Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md)
- Include system information and relevant log files
- Test on a clean Garuda Linux installation if possible

### Suggesting Features
- Open an issue with the `enhancement` label
- Describe the use case and expected behavior
- Consider backward compatibility

### Code Contributions

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Test thoroughly** (see Testing section below)
5. **Commit with clear messages**: `git commit -m 'Add amazing feature'`
6. **Push to your branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

## 🧪 Testing

Before submitting changes, please test:

### Basic Functionality
```bash
# Test backup creation
./scripts/backup-packages.sh
./scripts/backup-configs.sh

# Test status checking
./scripts/backup-status.sh

# Test restore menu (exit without making changes)
sudo ./scripts/restore-system.sh
```

### Installation Testing
```bash
# Test on clean system (VM recommended)
sudo ./install.sh

# Verify services
systemctl status snapper-timeline.timer
systemctl status cronie.service

# Check cron jobs
crontab -l
```

### Recovery Testing
```bash
# Test package restoration (use test packages)
echo "test-package" > /tmp/test-packages.txt
sudo pacman -S --needed $(cat /tmp/test-packages.txt)

# Test configuration restoration (backup first!)
# ONLY test on non-production systems
```

## 📝 Code Standards

### Bash Scripts
- Use `set -euo pipefail` for error handling
- Quote all variables: `"$VARIABLE"`
- Use meaningful variable names
- Add comments for complex logic
- Follow existing formatting style

### Documentation
- Update README.md for new features
- Add examples for new functionality
- Keep installation instructions current
- Document any new dependencies

## 🗂️ Project Structure

```
garuda-ultimate-restore-system/
├── scripts/                 # All backup/restore scripts
├── docs/                   # Documentation
├── .github/                # GitHub-specific files
├── install.sh             # Main installer
├── README.md              # Main documentation
├── LICENSE                # MIT license
└── CONTRIBUTING.md        # This file
```

## ✅ Pull Request Checklist

- [ ] Tested on Garuda Linux
- [ ] Scripts are executable (`chmod +x`)
- [ ] Variables are properly quoted
- [ ] Error handling added where appropriate
- [ ] Documentation updated if needed
- [ ] No hardcoded paths (use variables)
- [ ] Backward compatibility maintained
- [ ] Commit messages are clear

## 🚨 Important Notes

### Security Considerations
- Never commit credentials or personal data
- Be careful with file permissions
- Validate user input in scripts
- Use secure temporary files when needed

### Compatibility
- Test on multiple Garuda editions if possible
- Consider different filesystem types
- Maintain compatibility with existing backups
- Test with both fresh installs and updated systems

## 🆘 Getting Help

- **Questions**: Open a GitHub issue
- **Chat**: Garuda Linux Telegram/Discord
- **Docs**: Check the `docs/` directory
- **Examples**: Look at existing scripts

## 🏆 Recognition

Contributors will be:
- Listed in the project credits
- Mentioned in release notes for significant contributions
- Given credit in commit messages

## 📋 Areas Needing Help

- Testing on different Garuda editions
- Documentation improvements
- Cloud backup integrations
- GUI interface development
- Performance optimizations
- Error handling improvements

## 🎯 Development Goals

- **Reliability**: Every backup should work
- **Simplicity**: Easy to use and understand
- **Flexibility**: Support various use cases
- **Performance**: Fast backups and restores
- **Documentation**: Clear and comprehensive

Thank you for helping make this project better for the Garuda Linux community! 🐉
