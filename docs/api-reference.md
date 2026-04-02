# 📚 API Reference

## CrossPlatform DevToolkit v2.0.0

---

## Python Toolkit API

### `toolkit.py` - Main CLI

```
Usage: python3 toolkit.py [command] [options]

Commands:
  sysinfo              System information report
  netcheck             Network diagnostics
  fileorg [DIR]        Organize files by type
  cleaner              Find cleanable files
  portcheck [HOST]     Scan open ports
```

---

### `cmd_sysinfo(args)`

Displays comprehensive system information.

**Output sections:**
- 🏠 System (OS, kernel, hostname, Python version)
- 💻 CPU (processor model, core count)
- 🧠 Memory (total, available, used)
- 💾 Disk (total, used, free, percentage)

**Example:**
```bash
python3 toolkit.py sysinfo
```

---

### `cmd_netcheck(args)`

Runs parallel network connectivity tests.

**Tests performed:**
- TCP connection to major hosts (Google, GitHub, PyPI)
- Local hostname resolution
- Network interface detection

**Options:** None

**Example:**
```bash
python3 toolkit.py netcheck
```

---

### `cmd_fileorg(args)`

Organizes files in a directory into categorized subdirectories.

**Arguments:**
- `dir` (optional): Target directory (default: current)
- `--dry-run` / `-d`: Preview without moving files

**File categories:**
| Category | Extensions |
|----------|-----------|
| Images | jpg, jpeg, png, gif, bmp, webp, svg, heic |
| Videos | mp4, mkv, avi, mov, wmv, flv, webm |
| Audio | mp3, wav, flac, aac, ogg, wma, m4a |
| Documents | pdf, doc, docx, odt, rtf, txt, md |
| Spreadsheets | xls, xlsx, csv, ods, tsv |
| Archives | zip, tar, gz, bz2, 7z, rar, xz |
| Code | py, js, ts, html, css, php, java, sh |
| Data | json, xml, yaml, yml, toml, ini, sql |
| Misc | Everything else |

**Example:**
```bash
python3 toolkit.py fileorg ~/Downloads --dry-run
python3 toolkit.py fileorg ~/Downloads
```

---

### `cmd_cleaner(args)`

Analyzes home directory for cleanable files.

**Checks:**
- Python cache (`__pycache__`, `.pyc`, `.pyo`)
- Node modules (`node_modules`)
- Log files (`.log`)
- Temporary files (`.tmp`, `.temp`)
- macOS artifacts (`.DS_Store`)
- Windows artifacts (`Thumbs.db`)

**Note:** Currently analysis-only. Does not delete files automatically.

---

### `cmd_portcheck(args)`

Scans common ports on a target host.

**Arguments:**
- `host` (optional): Target host (default: `localhost`)

**Scanned ports:**
21 (FTP), 22 (SSH), 23 (Telnet), 25 (SMTP), 53 (DNS),
80 (HTTP), 443 (HTTPS), 3000, 3306 (MySQL), 5432 (PostgreSQL),
6379 (Redis), 8080, 8443, 27017 (MongoDB)

**Example:**
```bash
python3 toolkit.py portcheck
python3 toolkit.py portcheck 192.168.1.100
python3 toolkit.py portcheck github.com
```

---

## Bash Script API

### `setup.sh`

**Functions:**
- `banner()` — Display toolkit banner
- `detect_os()` — Returns: `termux`, `linux`, `macos`, `windows`
- `detect_distro()` — Returns OS distro ID
- `check_requirements()` — Verifies required tools
- `install_missing()` — Installs missing packages
- `create_directories()` — Sets up install directory tree
- `create_config()` — Generates toolkit.conf
- `add_to_path()` — Updates shell RC file
- `show_summary()` — Final status display

**Environment variables:**
```bash
TOOLKIT_VERSION="2.0.0"
INSTALL_DIR="$HOME/.devtoolkit"
LOG_FILE="$INSTALL_DIR/logs/setup_DATE.log"
CONFIG_FILE="$INSTALL_DIR/config/toolkit.conf"
```

---

### `sysinfo.sh`

Standalone — no arguments required.

Outputs sections: SYSTEM, CPU, MEMORY, DISK, NETWORK, TOOLS, UPTIME

---

### `netcheck.sh`

**Configuration variables** (edit at top of script):
```bash
TIMEOUT=5       # Connection timeout in seconds
PING_COUNT=4    # Number of ping packets
```

**Tests:**
1. DNS resolution (4 hosts)
2. ICMP ping (3 DNS servers)
3. HTTP/HTTPS (4 URLs via curl)
4. Rough download speed test
5. Local network interfaces
6. Open port check (localhost)
7. Traceroute (first 5 hops)

---

### `fileorg.sh`

**Arguments:**
```bash
bash fileorg.sh [DIRECTORY] [OPTIONS]
  DIRECTORY     Target directory (default: current)
  -d, --dry-run Preview only, no files moved
  -h, --help    Show help
```

---

### `monitor.sh`

**Arguments:**
```bash
bash monitor.sh [INTERVAL_SECONDS]
  INTERVAL_SECONDS  Refresh interval (default: 2)
```

**Press Ctrl+C to exit.**

**Displays:**
- CPU usage bar
- Memory usage bar
- Disk usage bar
- Top processes by CPU
- Network I/O statistics

---

## Configuration Reference

### toolkit.conf (INI format)

```ini
[general]
version = 2.0.0
install_dir = ~/.devtoolkit
log_level = DEBUG|INFO|WARN|ERROR
color_output = true|false
auto_update = true|false

[network]
timeout = 30
retry_count = 3
proxy_enabled = true|false
proxy_url = http://proxy:port

[tools]
enable_sysinfo = true|false
enable_netcheck = true|false
enable_fileorg = true|false
enable_backup = true|false
enable_monitor = true|false
enable_cleaner = true|false

[backup]
auto_backup = true|false
backup_interval = 7
max_backups = 10
backup_dir = ~/.devtoolkit/backups

[display]
theme = dark|light
language = auto|en|hi
show_banner = true|false
```

---

*API Reference v2.0.0 — CrossPlatform DevToolkit*
