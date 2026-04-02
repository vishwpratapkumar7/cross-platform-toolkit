#!/usr/bin/env python3
# ============================================================
# toolkit.py - Main CLI Entry Point
# CrossPlatform DevToolkit v2.0.0
# ============================================================

import os
import sys
import platform
import subprocess
import shutil
import socket
import json
import time
import argparse
import threading
import signal
from pathlib import Path
from datetime import datetime, timedelta
from collections import defaultdict
from typing import Optional, List, Dict, Any

# ── Colors ───────────────────────────────────────────────────
class C:
    R   = "\033[0;31m"
    G   = "\033[0;32m"
    Y   = "\033[1;33m"
    B   = "\033[0;34m"
    P   = "\033[0;35m"
    CY  = "\033[0;36m"
    BO  = "\033[1m"
    RE  = "\033[0m"
    UL  = "\033[4m"

# ── Utilities ────────────────────────────────────────────────
def clear(): os.system("cls" if os.name == "nt" else "clear")
def is_termux(): return "TERMUX_VERSION" in os.environ
def is_windows(): return platform.system() == "Windows"

def run(cmd: str, capture=True, timeout=30) -> tuple:
    try:
        result = subprocess.run(
            cmd, shell=True, capture_output=capture,
            text=True, timeout=timeout
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Timeout"
    except Exception as e:
        return -1, "", str(e)

# ── Commands ─────────────────────────────────────────────────

def cmd_sysinfo(args):
    """Show detailed system information."""
    print(f"\n{C.BO}{C.CY}  🖥️  System Information{C.RE}\n")
    
    sections = {
        "🏠 System": {
            "OS": f"{platform.system()} {platform.release()}",
            "Version": platform.version()[:60],
            "Architecture": platform.machine(),
            "Hostname": socket.gethostname(),
            "Python": platform.python_version(),
            "Platform": platform.platform()[:60],
        },
        "💻 CPU": {
            "Processor": platform.processor()[:60] or "N/A",
            "Cores (logical)": str(os.cpu_count()),
        },
        "📁 Filesystem": {},
    }
    
    # Memory
    try:
        with open("/proc/meminfo") as f:
            meminfo = dict(line.split(":") for line in f.read().splitlines() if ":" in line)
        total = int(meminfo["MemTotal"].split()[0]) // 1024
        avail = int(meminfo["MemAvailable"].split()[0]) // 1024
        sections["🧠 Memory"] = {
            "Total": f"{total} MB",
            "Available": f"{avail} MB",
            "Used": f"{total - avail} MB",
        }
    except:
        pass
    
    # Disk
    try:
        stat = shutil.disk_usage("/")
        sections["💾 Disk (/)"] = {
            "Total": f"{stat.total // (1024**3)} GB",
            "Used": f"{stat.used // (1024**3)} GB",
            "Free": f"{stat.free // (1024**3)} GB",
            "Used %": f"{(stat.used / stat.total * 100):.1f}%",
        }
    except:
        pass
    
    for section, data in sections.items():
        if not data: continue
        print(f"  {C.BO}{section}{C.RE}")
        for k, v in data.items():
            print(f"    {C.CY}{k:<20}{C.RE}: {v}")
        print()

def cmd_netcheck(args):
    """Run network diagnostics."""
    print(f"\n{C.BO}{C.CY}  🌐 Network Diagnostics{C.RE}\n")
    
    def check_host(host, port, name):
        try:
            start = time.time()
            sock = socket.create_connection((host, port), timeout=5)
            latency = (time.time() - start) * 1000
            sock.close()
            print(f"  {C.G}✓{C.RE} {name:<25} {latency:.0f}ms")
        except Exception as e:
            print(f"  {C.R}✗{C.RE} {name:<25} FAILED ({e})")
    
    hosts = [
        ("8.8.8.8", 53, "Google DNS"),
        ("1.1.1.1", 53, "Cloudflare DNS"),
        ("github.com", 443, "GitHub"),
        ("google.com", 443, "Google"),
        ("pypi.org", 443, "PyPI"),
        ("stackoverflow.com", 443, "StackOverflow"),
    ]
    
    print(f"  {C.BO}Connectivity Tests:{C.RE}")
    threads = []
    for host, port, name in hosts:
        t = threading.Thread(target=check_host, args=(host, port, name))
        threads.append(t)
        t.start()
    for t in threads:
        t.join()
    
    print(f"\n  {C.BO}Local Network:{C.RE}")
    try:
        hostname = socket.gethostname()
        local_ip = socket.gethostbyname(hostname)
        print(f"  Hostname: {hostname}")
        print(f"  Local IP: {local_ip}")
    except:
        pass
    
    print()

def cmd_fileorg(args):
    """Organize files in a directory."""
    target = Path(args.dir if hasattr(args, "dir") and args.dir else ".")
    dry_run = hasattr(args, "dry_run") and args.dry_run
    
    CATEGORIES = {
        "Images":       [".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".svg", ".heic", ".raw"],
        "Videos":       [".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv", ".webm", ".m4v"],
        "Audio":        [".mp3", ".wav", ".flac", ".aac", ".ogg", ".wma", ".m4a", ".opus"],
        "Documents":    [".pdf", ".doc", ".docx", ".odt", ".rtf", ".txt", ".md", ".tex"],
        "Spreadsheets": [".xls", ".xlsx", ".csv", ".ods", ".tsv"],
        "Archives":     [".zip", ".tar", ".gz", ".bz2", ".7z", ".rar", ".xz"],
        "Code":         [".py", ".js", ".ts", ".html", ".css", ".php", ".java", ".cpp", ".c", ".go", ".rs", ".sh"],
        "Data":         [".json", ".xml", ".yaml", ".yml", ".toml", ".ini", ".sql", ".db"],
    }
    
    ext_map = {}
    for cat, exts in CATEGORIES.items():
        for ext in exts:
            ext_map[ext] = cat
    
    print(f"\n{C.BO}{C.CY}  📁 File Organizer{C.RE}")
    print(f"  Directory: {target.resolve()}")
    dry_run and print(f"  {C.Y}[DRY RUN MODE]{C.RE}")
    print()
    
    moved = 0
    for item in target.iterdir():
        if item.is_dir() or item.name.startswith("."):
            continue
        cat = ext_map.get(item.suffix.lower(), "Misc")
        dest = target / cat / item.name
        
        if dry_run:
            print(f"  {C.B}→{C.RE} {item.name} → {cat}/")
        else:
            (target / cat).mkdir(exist_ok=True)
            item.rename(dest)
            print(f"  {C.G}✓{C.RE} {item.name} → {cat}/")
        moved += 1
    
    print(f"\n  Done: {moved} file(s) {'would be ' if dry_run else ''}organized\n")

def cmd_cleaner(args):
    """Clean temp files and caches."""
    print(f"\n{C.BO}{C.CY}  🧹 System Cleaner{C.RE}\n")
    
    patterns = [
        ("Python cache", ["**/__pycache__", "**/*.pyc", "**/*.pyo"]),
        ("Node modules", ["**/node_modules"]),
        ("Log files", ["**/*.log"]),
        ("Temp files", ["**/*.tmp", "**/*.temp"]),
        ("DS_Store", ["**/.DS_Store"]),
        ("Thumbs.db", ["**/Thumbs.db"]),
    ]
    
    home = Path.home()
    total_size = 0
    
    for name, glob_list in patterns:
        count = 0
        size = 0
        for g in glob_list:
            for p in home.glob(g):
                try:
                    if p.is_file():
                        size += p.stat().st_size
                        count += 1
                except:
                    pass
        
        if count > 0:
            size_mb = size / (1024 * 1024)
            print(f"  {C.Y}!{C.RE} {name}: {count} files ({size_mb:.2f} MB)")
            total_size += size
        else:
            print(f"  {C.G}✓{C.RE} {name}: Clean")
    
    print(f"\n  Total potential cleanup: {total_size / (1024*1024):.2f} MB\n")

def cmd_portcheck(args):
    """Scan common ports on localhost."""
    host = getattr(args, "host", "localhost")
    print(f"\n{C.BO}{C.CY}  🔌 Port Scanner - {host}{C.RE}\n")
    
    COMMON_PORTS = {
        21: "FTP", 22: "SSH", 23: "Telnet", 25: "SMTP",
        53: "DNS", 80: "HTTP", 110: "POP3", 143: "IMAP",
        443: "HTTPS", 993: "IMAPS", 995: "POP3S",
        3000: "Node.js Dev", 3306: "MySQL", 5432: "PostgreSQL",
        5900: "VNC", 6379: "Redis", 8080: "HTTP Alt",
        8443: "HTTPS Alt", 9200: "Elasticsearch", 27017: "MongoDB",
    }
    
    open_ports = []
    
    for port, service in COMMON_PORTS.items():
        try:
            sock = socket.create_connection((host, port), timeout=0.5)
            sock.close()
            print(f"  {C.G}OPEN  {C.RE} {port:<6} {service}")
            open_ports.append(port)
        except:
            print(f"  {C.R}CLOSED{C.RE} {port:<6} {service}")
    
    print(f"\n  Open ports: {len(open_ports)}/{len(COMMON_PORTS)}\n")

# ── CLI Parser ───────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        prog="dtk",
        description=f"{C.BO}CrossPlatform DevToolkit v2.0.0{C.RE}",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Commands:
  sysinfo              System information
  netcheck             Network diagnostics  
  fileorg [DIR]        Organize files
  cleaner              Find cleanable files
  portcheck [HOST]     Scan ports

Examples:
  python toolkit.py sysinfo
  python toolkit.py netcheck
  python toolkit.py fileorg ~/Downloads --dry-run
  python toolkit.py portcheck 192.168.1.1
        """
    )
    
    subparsers = parser.add_subparsers(dest="command")
    
    subparsers.add_parser("sysinfo", help="System information")
    subparsers.add_parser("netcheck", help="Network diagnostics")
    
    fileorg_p = subparsers.add_parser("fileorg", help="Organize files")
    fileorg_p.add_argument("dir", nargs="?", default=".", help="Directory to organize")
    fileorg_p.add_argument("--dry-run", "-d", action="store_true")
    
    subparsers.add_parser("cleaner", help="System cleaner")
    
    port_p = subparsers.add_parser("portcheck", help="Port scanner")
    port_p.add_argument("host", nargs="?", default="localhost")
    
    args = parser.parse_args()
    
    commands = {
        "sysinfo":   cmd_sysinfo,
        "netcheck":  cmd_netcheck,
        "fileorg":   cmd_fileorg,
        "cleaner":   cmd_cleaner,
        "portcheck": cmd_portcheck,
    }
    
    if args.command in commands:
        commands[args.command](args)
    else:
        print(f"\n{C.BO}{C.CY}  🚀 CrossPlatform DevToolkit v2.0.0{C.RE}")
        print(f"  Platform: {platform.system()} {'(Termux)' if is_termux() else ''}")
        print(f"\n  {C.BO}Available Commands:{C.RE}")
        for cmd, fn in commands.items():
            print(f"    {C.G}{cmd:<15}{C.RE} {fn.__doc__}")
        print(f"\n  Run: python toolkit.py <command> --help\n")

if __name__ == "__main__":
    signal.signal(signal.SIGINT, lambda s, f: sys.exit(0))
    main()
