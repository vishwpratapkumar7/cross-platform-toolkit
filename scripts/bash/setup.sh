#!/usr/bin/env bash
# ============================================================
# CrossPlatform DevToolkit - Linux/Termux Setup Script
# Version: 2.0.0
# Author: DevToolkit Team
# ============================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

# ── Variables ────────────────────────────────────────────────
TOOLKIT_VERSION="2.0.0"
INSTALL_DIR="$HOME/.devtoolkit"
LOG_FILE="$INSTALL_DIR/logs/setup_$(date +%Y%m%d_%H%M%S).log"
CONFIG_FILE="$INSTALL_DIR/config/toolkit.conf"

# ── Functions ────────────────────────────────────────────────

banner() {
  echo -e "${CYAN}"
  echo "  ╔══════════════════════════════════════════════════╗"
  echo "  ║        CrossPlatform DevToolkit v${TOOLKIT_VERSION}          ║"
  echo "  ║     Windows | Linux | Termux - Sabhi Chalao!    ║"
  echo "  ╚══════════════════════════════════════════════════╝"
  echo -e "${RESET}"
}

log() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "$timestamp [$level] $message" >> "$LOG_FILE" 2>/dev/null || true
}

info() { echo -e "${BLUE}[INFO]${RESET}  $1"; log "INFO" "$1"; }
success() { echo -e "${GREEN}[OK]${RESET}    $1"; log "SUCCESS" "$1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET}  $1"; log "WARN" "$1"; }
error() { echo -e "${RED}[ERROR]${RESET} $1"; log "ERROR" "$1"; }
step() { echo -e "\n${PURPLE}━━━ $1 ━━━${RESET}"; }

detect_os() {
  if [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d "/data/data/com.termux" ]]; then
    echo "termux"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    echo "windows"
  else
    echo "unknown"
  fi
}

detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "${ID:-unknown}"
  else
    echo "unknown"
  fi
}

check_requirements() {
  step "Requirements Check"
  local missing=()
  
  local tools=("git" "curl" "python3" "bash")
  for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
      success "$tool found: $(command -v $tool)"
    else
      warn "$tool not found"
      missing+=("$tool")
    fi
  done
  
  if [[ ${#missing[@]} -gt 0 ]]; then
    warn "Missing tools: ${missing[*]}"
    install_missing "${missing[@]}"
  fi
}

install_missing() {
  local os
  os=$(detect_os)
  info "Installing missing packages for: $os"
  
  case "$os" in
    termux)
      pkg update -y 2>/dev/null
      for pkg in "$@"; do
        pkg install -y "$pkg" 2>/dev/null && success "Installed: $pkg" || warn "Could not install: $pkg"
      done
      ;;
    linux)
      local distro
      distro=$(detect_distro)
      case "$distro" in
        ubuntu|debian|linuxmint)
          sudo apt-get update -qq
          for pkg in "$@"; do
            sudo apt-get install -y "$pkg" 2>/dev/null && success "Installed: $pkg" || warn "Could not install: $pkg"
          done
          ;;
        fedora|rhel|centos)
          for pkg in "$@"; do
            sudo dnf install -y "$pkg" 2>/dev/null && success "Installed: $pkg" || warn "Could not install: $pkg"
          done
          ;;
        arch|manjaro)
          for pkg in "$@"; do
            sudo pacman -S --noconfirm "$pkg" 2>/dev/null && success "Installed: $pkg" || warn "Could not install: $pkg"
          done
          ;;
      esac
      ;;
  esac
}

create_directories() {
  step "Creating Directory Structure"
  local dirs=(
    "$INSTALL_DIR"
    "$INSTALL_DIR/bin"
    "$INSTALL_DIR/logs"
    "$INSTALL_DIR/config"
    "$INSTALL_DIR/cache"
    "$INSTALL_DIR/plugins"
    "$INSTALL_DIR/backups"
    "$INSTALL_DIR/temp"
  )
  
  for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
    success "Created: $dir"
  done
}

create_config() {
  step "Creating Configuration"
  cat > "$CONFIG_FILE" <<CONFIG
# CrossPlatform DevToolkit Configuration
# Generated: $(date)
# Version: ${TOOLKIT_VERSION}

[general]
version = ${TOOLKIT_VERSION}
install_dir = ${INSTALL_DIR}
log_level = INFO
color_output = true
auto_update = false

[network]
timeout = 30
retry_count = 3
proxy_enabled = false

[tools]
enable_sysinfo = true
enable_netcheck = true
enable_fileorg = true
enable_backup = true
enable_monitor = true
enable_cleaner = true

[backup]
auto_backup = true
backup_interval = 7
max_backups = 10
backup_dir = ${INSTALL_DIR}/backups

[display]
theme = dark
language = auto
show_banner = true
CONFIG
  success "Config created: $CONFIG_FILE"
}

add_to_path() {
  step "Adding to PATH"
  local shell_rc=""
  
  if [[ -n "${BASH_VERSION:-}" ]] || [[ "$SHELL" == *"bash"* ]]; then
    shell_rc="$HOME/.bashrc"
  elif [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == *"zsh"* ]]; then
    shell_rc="$HOME/.zshrc"
  fi
  
  if [[ -n "$shell_rc" ]]; then
    local path_line="export PATH=\"$INSTALL_DIR/bin:\$PATH\""
    if ! grep -q "devtoolkit" "$shell_rc" 2>/dev/null; then
      echo "" >> "$shell_rc"
      echo "# CrossPlatform DevToolkit" >> "$shell_rc"
      echo "$path_line" >> "$shell_rc"
      success "Added to $shell_rc"
    else
      info "Already in PATH"
    fi
  fi
}

show_summary() {
  echo -e "\n${GREEN}${BOLD}"
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║       ✅ Installation Complete!          ║"
  echo "  ╠══════════════════════════════════════════╣"
  echo "  ║  Install Dir : $INSTALL_DIR"
  echo "  ║  Config      : $CONFIG_FILE"
  echo "  ║  Log         : $LOG_FILE"
  echo "  ╠══════════════════════════════════════════╣"
  echo "  ║  Run: source ~/.bashrc && dtk --help    ║"
  echo "  ╚══════════════════════════════════════════╝"
  echo -e "${RESET}"
}

# ── Main ─────────────────────────────────────────────────────
main() {
  banner
  
  OS=$(detect_os)
  DISTRO=$(detect_distro)
  
  info "Detected OS: ${BOLD}$OS${RESET}"
  [[ "$OS" == "linux" ]] && info "Detected Distro: ${BOLD}$DISTRO${RESET}"
  
  create_directories
  touch "$LOG_FILE"
  
  check_requirements
  create_config
  add_to_path
  show_summary
}

main "$@"
