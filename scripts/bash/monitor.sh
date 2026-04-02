#!/usr/bin/env bash
# ============================================================
# monitor.sh - Real-time System Resource Monitor
# Works on: Linux, Termux
# Usage: bash monitor.sh [interval_seconds]
# ============================================================

INTERVAL="${1:-2}"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

# Hide cursor
tput civis 2>/dev/null
trap 'tput cnorm 2>/dev/null; echo ""; exit 0' INT TERM

get_cpu_usage() {
  if [[ -f /proc/stat ]]; then
    read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    active=$((total - idle - iowait))
    
    if [[ -n "${PREV_TOTAL:-}" ]]; then
      dtotal=$((total - PREV_TOTAL))
      dactive=$((active - PREV_ACTIVE))
      [[ $dtotal -gt 0 ]] && echo $(( (dactive * 100) / dtotal )) || echo 0
    else
      echo 0
    fi
    PREV_TOTAL=$total
    PREV_ACTIVE=$active
  else
    echo "N/A"
  fi
}

get_mem_info() {
  awk '/MemTotal/{total=$2} /MemAvailable/{avail=$2} END{
    used = total - avail
    pct = int(used * 100 / total)
    printf "%d %d %d %d", used/1024, total/1024, avail/1024, pct
  }' /proc/meminfo
}

draw_bar() {
  local pct="$1"
  local width="${2:-30}"
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local color="$GREEN"
  [[ $pct -ge 70 ]] && color="$YELLOW"
  [[ $pct -ge 90 ]] && color="$RED"
  printf "${color}%${filled}s${RESET}${BLUE}%${empty}s${RESET}" | tr ' ' '█' | tr ' ' '░'
}

get_top_processes() {
  ps aux --sort=-%cpu 2>/dev/null | awk 'NR>1 && NR<=6 {
    printf "  %-25s CPU: %5s%%  MEM: %5s%%\n", substr($11,1,25), $3, $4
  }'
}

while true; do
  clear
  CPU_PCT=$(get_cpu_usage)
  read -r MEM_USED MEM_TOTAL MEM_FREE MEM_PCT < <(get_mem_info)
  
  DISK_PCT=$(df / 2>/dev/null | awk 'NR==2{gsub(/%/,""); print $5}')
  DISK_USED=$(df -h / 2>/dev/null | awk 'NR==2{print $3}')
  DISK_TOTAL=$(df -h / 2>/dev/null | awk 'NR==2{print $2}')
  
  UPTIME_SEC=$(cut -d. -f1 /proc/uptime 2>/dev/null)
  UPTIME_H=$((UPTIME_SEC / 3600))
  UPTIME_M=$(( (UPTIME_SEC % 3600) / 60 ))
  UPTIME_S=$((UPTIME_SEC % 60))
  
  echo -e "${BOLD}${CYAN}  ┌─────────────────────────────────────────────────────┐"
  echo -e "  │        🖥️  System Monitor - $(date '+%H:%M:%S')               │"
  echo -e "  └─────────────────────────────────────────────────────┘${RESET}"
  echo -e "  Uptime: ${GREEN}${UPTIME_H}h ${UPTIME_M}m ${UPTIME_S}s${RESET}  |  Refresh: ${INTERVAL}s  |  Press Ctrl+C to exit"
  echo ""
  
  # CPU
  printf "  ${BOLD}CPU Usage:${RESET}  "
  if [[ "$CPU_PCT" =~ ^[0-9]+$ ]]; then
    draw_bar "$CPU_PCT"
    printf "  ${BOLD}%3d%%${RESET}\n" "$CPU_PCT"
  else
    echo "N/A"
  fi
  
  # Memory
  printf "  ${BOLD}Memory:   ${RESET}  "
  draw_bar "$MEM_PCT"
  printf "  ${BOLD}%3d%%${RESET}  (%s MB / %s MB)\n" "$MEM_PCT" "$MEM_USED" "$MEM_TOTAL"
  
  # Disk
  if [[ "$DISK_PCT" =~ ^[0-9]+$ ]]; then
    printf "  ${BOLD}Disk (/):  ${RESET} "
    draw_bar "$DISK_PCT"
    printf "  ${BOLD}%3d%%${RESET}  (%s / %s)\n" "$DISK_PCT" "$DISK_USED" "$DISK_TOTAL"
  fi
  
  echo ""
  echo -e "  ${BOLD}${BLUE}Top Processes (by CPU):${RESET}"
  get_top_processes
  
  # Network stats
  if [[ -f /proc/net/dev ]]; then
    echo ""
    echo -e "  ${BOLD}${BLUE}Network I/O:${RESET}"
    awk 'NR>2 && !/lo:/ {
      gsub(/:/, " ")
      printf "  %-12s RX: %-10s  TX: %s\n", $1, $2" bytes", $10" bytes"
    }' /proc/net/dev | head -4
  fi
  
  echo ""
  sleep "$INTERVAL"
done
