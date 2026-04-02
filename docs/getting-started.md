# 📖 Getting Started Guide

## CrossPlatform DevToolkit v2.0.0

---

## 1. Prerequisites

### 🐧 Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install git bash python3 curl wget -y
```

### 🐧 Linux (Arch/Manjaro)
```bash
sudo pacman -S git python bash curl wget
```

### 🐧 Linux (Fedora/CentOS)
```bash
sudo dnf install git python3 bash curl wget -y
```

### 📱 Termux (Android)
```bash
pkg update && pkg upgrade -y
pkg install git python bash curl wget -y
termux-setup-storage  # optional, for file access
```

### 🪟 Windows 10/11
1. Install [Git for Windows](https://git-scm.com/download/win)
2. Install [Python 3.10+](https://python.org/downloads)
3. Open **Windows Terminal** (recommended) or CMD

---

## 2. Installation

### Clone Repository
```bash
git clone https://github.com/yourusername/cross-platform-toolkit
cd cross-platform-toolkit
```

### Linux / Termux
```bash
chmod +x scripts/bash/*.sh
bash scripts/bash/setup.sh
```

### Windows
```cmd
scripts\batch\setup.bat
```

### Python (Universal)
```bash
python3 scripts/python/setup.py
# or on Windows:
python scripts\python\setup.py
```

---

## 3. Usage

### 🐧 Bash Scripts

| Script | Command | Description |
|--------|---------|-------------|
| Setup | `bash scripts/bash/setup.sh` | Initial setup |
| System Info | `bash scripts/bash/sysinfo.sh` | System details |
| Network Check | `bash scripts/bash/netcheck.sh` | Network diagnostics |
| File Organizer | `bash scripts/bash/fileorg.sh ~/Downloads` | Organize files |
| Monitor | `bash scripts/bash/monitor.sh` | Live resource monitor |
| Backup | `bash scripts/bash/backup.sh /path/to/backup` | Backup files |

### 🪟 Windows Scripts

| Script | Command | Description |
|--------|---------|-------------|
| Setup | `scripts\batch\setup.bat` | Initial setup |
| System Info | `scripts\batch\sysinfo.bat` | System details |
| Network Check | `scripts\batch\netcheck.bat` | Network diagnostics |

### 🐍 Python CLI

```bash
# Show all commands
python3 scripts/python/toolkit.py

# System information
python3 scripts/python/toolkit.py sysinfo

# Network diagnostics
python3 scripts/python/toolkit.py netcheck

# Organize files (preview)
python3 scripts/python/toolkit.py fileorg ~/Downloads --dry-run

# Organize files (execute)
python3 scripts/python/toolkit.py fileorg ~/Downloads

# Port scanner
python3 scripts/python/toolkit.py portcheck localhost

# System cleaner
python3 scripts/python/toolkit.py cleaner
```

---

## 4. Configuration

Config file location:
- **Linux/Termux**: `~/.devtoolkit/config/toolkit.conf`
- **Windows**: `%USERPROFILE%\.devtoolkit\config\toolkit.conf`

```ini
[general]
version = 2.0.0
log_level = INFO
color_output = true
auto_update = false

[tools]
enable_sysinfo = true
enable_netcheck = true
enable_fileorg = true
enable_backup = true
enable_monitor = true

[backup]
auto_backup = true
interval_days = 7
max_backups = 10
```

---

## 5. Troubleshooting

### "Permission denied" error
```bash
chmod +x scripts/bash/*.sh
```

### Script not found on Windows
Make sure you're in the repository root directory:
```cmd
cd path\to\cross-platform-toolkit
scripts\batch\setup.bat
```

### Termux storage access
```bash
termux-setup-storage
# Then restart Termux
```

### Python not found
```bash
# Check Python installation
python3 --version
# or
python --version

# Install on Termux
pkg install python
```

---

## 6. Project Structure

```
cross-platform-toolkit/
├── README.md                    # Main documentation
├── LICENSE                      # MIT License
├── .gitignore                   # Git ignore rules
├── scripts/
│   ├── bash/                    # Linux + Termux scripts
│   │   ├── setup.sh             # Setup script
│   │   ├── sysinfo.sh           # System info
│   │   ├── netcheck.sh          # Network check
│   │   ├── fileorg.sh           # File organizer
│   │   ├── monitor.sh           # Resource monitor
│   │   ├── backup.sh            # Backup tool
│   │   └── cleaner.sh           # System cleaner
│   ├── batch/                   # Windows scripts
│   │   ├── setup.bat            # Setup script
│   │   ├── sysinfo.bat          # System info
│   │   └── netcheck.bat         # Network check
│   └── python/                  # Cross-platform Python
│       ├── setup.py             # Setup script
│       └── toolkit.py           # Main CLI tool
├── tools/                       # Standalone tools
├── configs/                     # Configuration templates
├── docs/                        # Documentation
├── assets/                      # Images & resources
├── samples/                     # Sample data
├── templates/                   # Project templates
└── modules/                     # Reusable modules
```

---

## 7. Getting Help

- Check `docs/troubleshooting.md`
- Open an issue on GitHub
- Read the full API reference in `docs/api-reference.md`

---

*CrossPlatform DevToolkit v2.0.0 — MIT License*
