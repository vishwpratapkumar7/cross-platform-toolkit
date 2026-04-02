# 🚀 CrossPlatform DevToolkit

[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20Termux-blue)](https://github.com/vishwpratapkumar7/cross-platform-toolkit)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20Batch%20%7C%20Python-orange)]()
[![Version](https://img.shields.io/badge/Version-2.0.0-red)]()

> Ek powerful cross-platform toolkit jo **Windows Terminal**, **Linux**, aur **Android Termux** teeno par kaam karta hai! 🎯

---

## 📦 Kya Hai Isme?

```
cross-platform-toolkit/
├── 📁 scripts/
│   ├── bash/          → Linux + Termux scripts (.sh)
│   ├── batch/         → Windows scripts (.bat / .cmd)
│   └── python/        → Cross-platform Python scripts
├── 📁 tools/          → Standalone utility tools
├── 📁 configs/        → Config templates
├── 📁 docs/           → Full documentation
├── 📁 assets/         → Icons, images, resources
├── 📁 samples/        → Sample data files
├── 📁 templates/      → Project templates
└── 📁 modules/        → Reusable code modules
```

---

## ✅ Prerequisites (Pehle Ye Install Karo)

### 🐧 Linux — Ubuntu / Debian / Mint
```bash
sudo apt update
sudo apt install git bash python3 curl wget -y
```

### 🐧 Linux — Arch / Manjaro
```bash
sudo pacman -S git python bash curl wget
```

### 🐧 Linux — Fedora / CentOS / RHEL
```bash
sudo dnf install git python3 bash curl wget -y
```

### 📱 Termux (Android)
```bash
pkg update && pkg upgrade -y
pkg install git python bash curl wget -y
termux-setup-storage   # Storage access ke liye (optional)
```

### 🪟 Windows 10 / 11
1. [Git for Windows](https://git-scm.com/download/win) install karo
2. [Python 3.6+](https://python.org/downloads) install karo
   - ⚠️ Install karte waqt **"Add Python to PATH"** checkbox zaroor tick karo
3. **Windows Terminal** ya **CMD** **Administrator mode** mein kholo
   - Start → "Windows Terminal" → Right click → **Run as Administrator**

---

## ⚡ Installation

### Step 1 — Repository Clone Karo

**Linux / Termux / Windows Git Bash:**
```bash
git clone https://github.com/vishwpratapkumar7/cross-platform-toolkit.git
cd cross-platform-toolkit
```

**Windows CMD / PowerShell:**
```cmd
git clone https://github.com/vishwpratapkumar7/cross-platform-toolkit.git
cd cross-platform-toolkit
```

---

### Step 2 — Setup Script Chalao

#### 🐧 Linux
```bash
chmod +x scripts/bash/*.sh
bash scripts/bash/setup.sh
```

#### 📱 Termux (Android)
```bash
chmod +x scripts/bash/*.sh
bash scripts/bash/setup.sh
```

#### 🪟 Windows (CMD — Administrator mode mein)
```cmd
scripts\batch\setup.bat
```

#### 🐍 Python — Sabhi Platforms (Universal Method)
```bash
# Linux / Termux
python3 scripts/python/setup.py

# Windows
python scripts\python\setup.py
```

---

### Step 3 — PATH Reload Karo

> ⚠️ Yeh step important hai! Bina is step ke `dtk` command kaam nahi karega.

**Linux / Termux (Bash):**
```bash
source ~/.bashrc
```

**Linux (Zsh):**
```bash
source ~/.zshrc
```

**Windows:**
```
Terminal band karo aur nayi window mein kholo
(ya ek baar logout/login karo)
```

---

### Step 4 — Verify Karo (Installation Sahi Hua?)

```bash
# Linux / Termux
python3 scripts/python/toolkit.py --help

# Windows
python scripts\python\toolkit.py --help
```

Agar kuch aisa output aye to installation successful hai ✅:
```
CrossPlatform DevToolkit v2.0.0
Usage: toolkit.py [command] [options]
...
```

---

## 🛠️ Tools — Kaise Use Karein

### 🐧 Linux / Termux (Bash Scripts)

| Tool | Command | Kaam |
|------|---------|------|
| System Info | `bash scripts/bash/sysinfo.sh` | CPU, RAM, OS details |
| Network Check | `bash scripts/bash/netcheck.sh` | Network diagnostics |
| File Organizer | `bash scripts/bash/fileorg.sh ~/Downloads` | Files organize karo |
| Resource Monitor | `bash scripts/bash/monitor.sh` | Live CPU/RAM monitor |
| Auto Backup | `bash scripts/bash/backup.sh /path/to/backup` | Backup banao |
| System Cleaner | `bash scripts/bash/cleaner.sh` | Cache/temp clean karo |

### 🪟 Windows (Batch Scripts)

| Tool | Command | Kaam |
|------|---------|------|
| System Info | `scripts\batch\sysinfo.bat` | System details |
| Network Check | `scripts\batch\netcheck.bat` | Network diagnostics |
| Setup | `scripts\batch\setup.bat` | Initial setup |

### 🐍 Python CLI (Sabhi Platforms)

```bash
# System information
python3 scripts/python/toolkit.py sysinfo

# Network diagnostics
python3 scripts/python/toolkit.py netcheck

# Files organize karo (pehle preview dekho)
python3 scripts/python/toolkit.py fileorg ~/Downloads --dry-run

# Files actually organize karo
python3 scripts/python/toolkit.py fileorg ~/Downloads

# Port scanner
python3 scripts/python/toolkit.py portcheck localhost

# System cleaner
python3 scripts/python/toolkit.py cleaner
```

> 💡 **Windows par** `python3` ki jagah `python` use karo.

---

## 📋 Complete Tools List

| Tool | Kaam | Platform |
|------|------|----------|
| `sysinfo` | System information | All |
| `netcheck` | Network diagnostics | All |
| `fileorg` | File organizer | All |
| `backup` | Auto backup tool | All |
| `monitor` | Resource monitor | Linux/Termux |
| `deploy` | Auto deployment | All |
| `cleaner` | System cleaner | All |
| `portcheck` | Port scanner | All |
| `loganalyzer` | Log analyzer | All |
| `envsetup` | Environment setup | All |

---

## ⚙️ Configuration

Config file apne aap ban jaati hai setup ke baad:

- **Linux / Termux:** `~/.devtoolkit/config/toolkit.conf`
- **Windows:** `%USERPROFILE%\.devtoolkit\config\toolkit.conf`

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
backup_interval = 7
max_backups = 10
```

---

## 🔧 Troubleshooting

### ❌ "Permission denied" error (Linux/Termux)
```bash
chmod +x scripts/bash/*.sh
```

### ❌ `python3: command not found` (Linux)
```bash
sudo apt install python3 -y         # Ubuntu/Debian
sudo dnf install python3 -y         # Fedora
sudo pacman -S python               # Arch
```

### ❌ `python: command not found` (Windows)
- Python ko PATH mein add karo:
  - Control Panel → System → Advanced → Environment Variables → PATH mein Python folder add karo
- Ya Python uninstall karke dobara install karo — is baar **"Add to PATH"** tick karo

### ❌ "Script not found" (Windows)
Make sure aap repository ke root folder mein ho:
```cmd
cd path\to\cross-platform-toolkit
scripts\batch\setup.bat
```

### ❌ Setup.bat kaam nahi kar raha
Administrator mode mein chalao:
- Start → "CMD" ya "Windows Terminal" → Right click → **Run as Administrator**

### ❌ Termux mein storage access nahi
```bash
termux-setup-storage
# Termux band karo aur dobara kholo
```

### ❌ `dtk` command nahi mila after setup (Linux)
```bash
source ~/.bashrc
# ya
source ~/.zshrc
```

---

## 📚 Documentation

Poori documentation `docs/` folder mein hai:

- [Getting Started](docs/getting-started.md)
- [API Reference](docs/api-reference.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Contributing Guide](docs/contributing.md)
- [Changelog](docs/changelog.md)

---

## 🎯 Features

- ✅ **Zero Dependencies** — Basic tools sirf stdlib use karte hain
- ✅ **Auto Detection** — OS aur distro khud detect karta hai
- ✅ **Colorful Output** — Terminal mein colored output
- ✅ **Logging** — Automatic log files `~/.devtoolkit/logs/` mein
- ✅ **Config Files** — Easy customization
- ✅ **Plugin System** — Apne tools se extend karo
- ✅ **Offline Support** — Internet ke bina bhi kaam kare
- ✅ **Unicode Support** — Hindi / Urdu / Emoji support

---

## 🤝 Contributing

PRs welcome hain! Pehle [CONTRIBUTING.md](docs/contributing.md) padho.

---

## 📄 License

MIT License © 2024 CrossPlatform DevToolkit

---

## 🌟 Star karo agar helpful laga!

[⭐ GitHub pe Star do](https://github.com/vishwpratapkumar7/cross-platform-toolkit)
