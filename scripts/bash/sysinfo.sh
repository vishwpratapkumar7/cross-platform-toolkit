#!/usr/bin/env bash
# ============================================================
# sysinfo.sh - System Information Tool
# Works on: Linux, Termux, macOS
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

divider() { echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }
label()   { printf "${CYAN}%-20s${RESET}: ${GREEN}%s${RESET}\n" "$1" "$2"; }

echo -e "\n${BOLD}${YELLOW}  ⚙️  System Information Report${RESET}"
echo -e "  Generated: $(date '+%Y-%m-%d %H:%M:%S')\n"

divider
echo -e "${BOLD} 🖥️  SYSTEM${RESET}"
divider
label "Hostname"     "$(hostname 2>/dev/null || echo 'N/A')"
label "OS"           "$(uname -s)"
label "Kernel"       "$(uname -r)"
label "Architecture" "$(uname -m)"
label "Shell"        "$SHELL"

if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  label "Distro"     "${PRETTY_NAME:-$ID}"
fi

if [[ -n "${TERMUX_VERSION:-}" ]]; then
  label "Environment" "Termux v${TERMUX_VERSION}"
fi

divider
echo -e "${BOLD} 💻  CPU${RESET}"
divider
if [[ -f /proc/cpuinfo ]]; then
  CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
  CPU_CORES=$(nproc 2>/dev/null || grep -c "^processor" /proc/cpuinfo)
  CPU_FREQ=$(grep -m1 "cpu MHz" /proc/cpuinfo | cut -d: -f2 | xargs | cut -d. -f1)
  label "Model"      "${CPU_MODEL:-Unknown}"
  label "Cores"      "$CPU_CORES"
  label "Frequency"  "${CPU_FREQ:-N/A} MHz"
fi

if command -v uptime &>/dev/null; then
  LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
  label "Load Avg"   "${LOAD:-N/A}"
fi

divider
echo -e "${BOLD} 🧠  MEMORY${RESET}"
divider
if [[ -f /proc/meminfo ]]; then
  MEM_TOTAL=$(awk '/MemTotal/{printf "%.1f GB", $2/1024/1024}' /proc/meminfo)
  MEM_FREE=$(awk '/MemAvailable/{printf "%.1f GB", $2/1024/1024}' /proc/meminfo)
  MEM_USED=$(awk '/MemTotal/{total=$2} /MemAvailable/{avail=$2} END{printf "%.1f GB", (total-avail)/1024/1024}' /proc/meminfo)
  SWAP_TOTAL=$(awk '/SwapTotal/{printf "%.1f GB", $2/1024/1024}' /proc/meminfo)
  label "Total RAM"  "$MEM_TOTAL"
  label "Used"       "$MEM_USED"
  label "Free"       "$MEM_FREE"
  label "Swap"       "$SWAP_TOTAL"
fi

divider
echo -e "${BOLD} 💾  DISK${RESET}"
divider
df -h 2>/dev/null | awk 'NR>1 && /^\// {printf "  %-20s %s used of %s (%s)\n", $6, $3, $2, $5}'

divider
echo -e "${BOLD} 🌐  NETWORK${RESET}"
divider
if command -v ip &>/dev/null; then
  ip addr show 2>/dev/null | awk '/inet / && !/127.0.0.1/ {print "  " $NF ": " $2}'
elif command -v ifconfig &>/dev/null; then
  ifconfig 2>/dev/null | awk '/inet / && !/127.0.0.1/ {print "  " $2}'
fi

if command -v curl &>/dev/null; then
  PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || echo "N/A")
  label "Public IP"  "$PUBLIC_IP"
fi

divider
echo -e "${BOLD} 🔧  TOOLS${RESET}"
divider
TOOLS=("git" "python3" "python" "node" "npm" "docker" "curl" "wget" "vim" "nano" "htop" "tmux" "ssh")
for tool in "${TOOLS[@]}"; do
  if command -v "$tool" &>/dev/null; then
    VER=$(${tool} --version 2>&1 | head -1 | grep -oP '\d+\.\d+[\.\d]*' | head -1)
    printf "  ${GREEN}✓${RESET} %-15s %s\n" "$tool" "${VER:-installed}"
  else
    printf "  ${RED}✗${RESET} %-15s %s\n" "$tool" "not installed"
  fi
done

divider
echo -e "${BOLD} ⏰  UPTIME${RESET}"
divider
if [[ -f /proc/uptime ]]; then
  UPTIME_SEC=$(cut -d. -f1 /proc/uptime)
  UPTIME_DAYS=$((UPTIME_SEC / 86400))
  UPTIME_HOURS=$(( (UPTIME_SEC % 86400) / 3600 ))
  UPTIME_MINS=$(( (UPTIME_SEC % 3600) / 60 ))
  label "Uptime"     "${UPTIME_DAYS}d ${UPTIME_HOURS}h ${UPTIME_MINS}m"
fi
label "Boot Time"    "$(who -b 2>/dev/null | awk '{print $3, $4}' || echo 'N/A')"
divider
echo ""
