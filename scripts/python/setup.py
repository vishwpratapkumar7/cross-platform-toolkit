#!/usr/bin/env python3
# ============================================================
# setup.py - CrossPlatform DevToolkit Python Setup
# Works on: Windows, Linux, macOS, Termux
# Python 3.6+
# ============================================================

import os
import sys
import platform
import subprocess
import shutil
import json
import time
import socket
from pathlib import Path
from datetime import datetime

# ── Platform Detection ───────────────────────────────────────

def detect_platform():
    """Detect operating system and environment."""
    info = {
        "os": platform.system(),
        "os_release": platform.release(),
        "os_version": platform.version(),
        "machine": platform.machine(),
        "python": platform.python_version(),
        "is_termux": "TERMUX_VERSION" in os.environ or os.path.exists("/data/data/com.termux"),
        "is_windows": platform.system() == "Windows",
        "is_linux": platform.system() == "Linux",
        "is_macos": platform.system() == "Darwin",
        "hostname": socket.gethostname(),
        "username": os.environ.get("USERNAME") or os.environ.get("USER", "unknown"),
    }
    
    if info["is_termux"]:
        info["environment"] = "Termux (Android)"
    elif info["is_windows"]:
        info["environment"] = "Windows"
    elif info["is_linux"]:
        try:
            with open("/etc/os-release") as f:
                for line in f:
                    if line.startswith("PRETTY_NAME="):
                        info["distro"] = line.split("=", 1)[1].strip().strip('"')
                        break
        except:
            info["distro"] = "Linux"
        info["environment"] = info.get("distro", "Linux")
    elif info["is_macos"]:
        info["environment"] = f"macOS {platform.mac_ver()[0]}"
    else:
        info["environment"] = "Unknown"
    
    return info

# ── Colors ───────────────────────────────────────────────────

class Colors:
    RED = "\033[0;31m"
    GREEN = "\033[0;32m"
    YELLOW = "\033[1;33m"
    BLUE = "\033[0;34m"
    CYAN = "\033[0;36m"
    BOLD = "\033[1m"
    RESET = "\033[0m"
    
    @classmethod
    def disable(cls):
        for attr in ["RED", "GREEN", "YELLOW", "BLUE", "CYAN", "BOLD", "RESET"]:
            setattr(cls, attr, "")

# Disable colors on Windows if not supported
if platform.system() == "Windows":
    try:
        import ctypes
        kernel32 = ctypes.windll.kernel32
        kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
    except:
        Colors.disable()

C = Colors

# ── Output Helpers ───────────────────────────────────────────

def banner():
    print(f"\n{C.CYAN}{C.BOLD}")
    print("  ╔══════════════════════════════════════════════════╗")
    print("  ║     CrossPlatform DevToolkit v2.0.0             ║")
    print("  ║     Python Cross-Platform Setup Script          ║")
    print("  ╚══════════════════════════════════════════════════╝")
    print(f"{C.RESET}")

def info(msg):  print(f"  {C.BLUE}[INFO]{C.RESET}   {msg}")
def ok(msg):    print(f"  {C.GREEN}[OK]{C.RESET}     {msg}")
def warn(msg):  print(f"  {C.YELLOW}[WARN]{C.RESET}   {msg}")
def error(msg): print(f"  {C.RED}[ERROR]{C.RESET}  {msg}")
def step(msg):  print(f"\n{C.BOLD}{C.BLUE}  ── {msg} ──{C.RESET}")

def progress(msg, duration=0.5):
    sys.stdout.write(f"  {C.CYAN}...{C.RESET} {msg}")
    sys.stdout.flush()
    time.sleep(duration)
    print(f"\r  {C.GREEN}✓  {C.RESET} {msg}")

# ── Directory Setup ──────────────────────────────────────────

def setup_directories(install_dir: Path) -> dict:
    step("Creating Directory Structure")
    dirs = {
        "root":     install_dir,
        "bin":      install_dir / "bin",
        "logs":     install_dir / "logs",
        "config":   install_dir / "config",
        "cache":    install_dir / "cache",
        "plugins":  install_dir / "plugins",
        "backups":  install_dir / "backups",
        "temp":     install_dir / "temp",
    }
    
    for name, path in dirs.items():
        path.mkdir(parents=True, exist_ok=True)
        ok(f"Created: {path}")
    
    return dirs

# ── Configuration ────────────────────────────────────────────

def create_config(config_path: Path, platform_info: dict):
    step("Creating Configuration")
    config = {
        "version": "2.0.0",
        "created": datetime.now().isoformat(),
        "platform": platform_info,
        "settings": {
            "log_level": "INFO",
            "color_output": True,
            "auto_update": False,
            "theme": "dark",
            "language": "auto",
        },
        "tools": {
            "sysinfo": True,
            "netcheck": True,
            "fileorg": True,
            "backup": True,
            "monitor": True,
            "cleaner": True,
        },
        "network": {
            "timeout": 30,
            "retry_count": 3,
            "proxy_enabled": False,
        },
        "backup": {
            "auto_backup": True,
            "interval_days": 7,
            "max_backups": 10,
        }
    }
    
    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, default=str)
    
    ok(f"Config saved: {config_path}")
    return config

# ── Requirement Check ────────────────────────────────────────

def check_requirements():
    step("Checking Requirements")
    
    python_version = tuple(int(x) for x in platform.python_version_tuple())
    if python_version >= (3, 6):
        ok(f"Python {platform.python_version()} ✓")
    else:
        error(f"Python 3.6+ required, got {platform.python_version()}")
        sys.exit(1)
    
    tools = {
        "git":     "Version control",
        "curl":    "HTTP client",
        "wget":    "File downloader",
        "ssh":     "Secure shell",
        "pip":     "Python package manager",
        "node":    "JavaScript runtime (optional)",
        "docker":  "Container platform (optional)",
        "tmux":    "Terminal multiplexer (optional)",
    }
    
    found = []
    missing = []
    
    for tool, desc in tools.items():
        path = shutil.which(tool)
        if path:
            try:
                result = subprocess.run(
                    [tool, "--version"],
                    capture_output=True, text=True, timeout=3
                )
                version = (result.stdout or result.stderr).strip().split("\n")[0]
                ok(f"{tool}: {version[:50]}")
            except:
                ok(f"{tool}: installed at {path}")
            found.append(tool)
        else:
            if "(optional)" not in desc:
                warn(f"{tool} not found ({desc})")
            else:
                info(f"{tool} not found ({desc})")
            missing.append(tool)
    
    info(f"Found: {len(found)}/{len(tools)} tools")
    return found, missing

# ── Network Check ────────────────────────────────────────────

def check_network():
    step("Network Connectivity")
    hosts = [
        ("Google DNS", "8.8.8.8", 53),
        ("Cloudflare", "1.1.1.1", 53),
        ("GitHub", "github.com", 443),
        ("PyPI", "pypi.org", 443),
    ]
    
    for name, host, port in hosts:
        try:
            sock = socket.create_connection((host, port), timeout=5)
            sock.close()
            ok(f"Connected to {name} ({host}:{port})")
        except Exception as e:
            warn(f"Cannot reach {name}: {e}")

# ── Summary ──────────────────────────────────────────────────

def show_summary(platform_info: dict, install_dir: Path):
    print(f"\n{C.GREEN}{C.BOLD}")
    print("  ╔══════════════════════════════════════════════════╗")
    print("  ║           ✅ Setup Complete!                    ║")
    print("  ╠══════════════════════════════════════════════════╣")
    print(f"  ║  Platform  : {platform_info['environment']:<34}║")
    print(f"  ║  Python    : {platform.python_version():<34}║")
    print(f"  ║  Install   : {str(install_dir)[:34]:<34}║")
    print("  ╠══════════════════════════════════════════════════╣")
    print("  ║  Run: python scripts/python/toolkit.py --help  ║")
    print("  ╚══════════════════════════════════════════════════╝")
    print(f"{C.RESET}")

# ── Main ─────────────────────────────────────────────────────

def main():
    banner()
    
    platform_info = detect_platform()
    info(f"Detected: {C.BOLD}{platform_info['environment']}{C.RESET}")
    info(f"Python: {platform_info['python']}")
    info(f"Machine: {platform_info['machine']}")
    
    install_dir = Path.home() / ".devtoolkit"
    
    dirs = setup_directories(install_dir)
    config = create_config(dirs["config"] / "toolkit.json", platform_info)
    found, missing = check_requirements()
    check_network()
    show_summary(platform_info, install_dir)

if __name__ == "__main__":
    main()
