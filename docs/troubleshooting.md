# 🔧 Troubleshooting Guide

## CrossPlatform DevToolkit v2.0.0

---

## Common Issues

### ❌ `bash: ./script.sh: Permission denied`

**Cause:** Script lacks execute permission.

**Fix:**
```bash
chmod +x scripts/bash/*.sh
# or individually:
chmod +x scripts/bash/setup.sh
```

---

### ❌ `python3: command not found`

**Linux:**
```bash
sudo apt install python3     # Ubuntu/Debian
sudo dnf install python3     # Fedora
sudo pacman -S python        # Arch
```

**Termux:**
```bash
pkg install python
```

**Windows:**
Download from [python.org](https://python.org) and check "Add to PATH".

---

### ❌ `git: command not found`

**Linux:**
```bash
sudo apt install git
```

**Termux:**
```bash
pkg install git
```

**Windows:**
Download [Git for Windows](https://git-scm.com/download/win).

---

### ❌ `curl: command not found`

**Linux:**
```bash
sudo apt install curl
```

**Termux:**
```bash
pkg install curl
```

---

### ❌ Colors not showing in Windows CMD

Use **Windows Terminal** instead of old CMD.

Or enable ANSI in CMD:
```cmd
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1
```

---

### ❌ Termux: No file access to `/sdcard`

```bash
termux-setup-storage
# Accept storage permission
# Restart Termux
```

Then access files via `~/storage/shared/`.

---

### ❌ Network check fails

1. Check internet connection
2. Check firewall settings
3. Try:
```bash
ping -c 3 8.8.8.8
curl https://google.com
```

---

### ❌ Script hangs / no output

Check if script is executable:
```bash
ls -la scripts/bash/
```

Run with verbose output:
```bash
bash -x scripts/bash/setup.sh
```

---

### ❌ Python script fails with import error

Install required packages:
```bash
pip3 install -r requirements.txt
# or on Termux:
pip install -r requirements.txt
```

---

## Platform-Specific Notes

### Termux
- No `sudo` command — not needed in Termux
- Use `pkg` instead of `apt`
- Home directory: `/data/data/com.termux/files/home`
- Storage: `~/storage/shared/` (after setup-storage)

### Windows
- Use PowerShell or Windows Terminal for best results
- Run batch files from Command Prompt
- WSL2 can run bash scripts: `wsl bash scripts/bash/setup.sh`

### Linux
- May need `sudo` for system-wide installs
- Check distribution: `cat /etc/os-release`
- Different package managers: apt, dnf, pacman, zypper

---

## Debug Mode

### Bash
```bash
bash -x scripts/bash/setup.sh 2>&1 | tee /tmp/dtk_debug.log
```

### Python
```bash
python3 -v scripts/python/toolkit.py sysinfo
```

### Check log files
```bash
ls ~/.devtoolkit/logs/
cat ~/.devtoolkit/logs/setup_*.log
```

---

## Reporting Bugs

When reporting a bug, include:
1. OS and version
2. Python version (`python3 --version`)
3. Error message (full output)
4. Steps to reproduce
5. Log file contents

---

*Last updated: 2024 | DevToolkit Team*
