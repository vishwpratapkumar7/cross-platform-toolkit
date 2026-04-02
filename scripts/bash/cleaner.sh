#!/usr/bin/env bash
# ============================================================
# cleaner.sh - System Cleaner Tool
# Works on: Linux, Termux
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

DRY_RUN=false
TOTAL_FREED=0

ok()     { echo -e "  ${GREEN}✓${RESET} $1"; }
warn()   { echo -e "  ${YELLOW}!${RESET} $1"; }
skip()   { echo -e "  ${BLUE}-${RESET} $1"; }
step()   { echo -e "\n${BOLD}${CYAN}── $1 ──${RESET}"; }

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

format_size() {
  local bytes="${1:-0}"
  if [[ $bytes -ge 1073741824 ]]; then printf "%.1f GB" "$(echo "$bytes 1073741824" | awk '{printf "%.1f", $1/$2}')";
  elif [[ $bytes -ge 1048576 ]]; then printf "%.1f MB" "$(echo "$bytes 1048576" | awk '{printf "%.1f", $1/$2}')";
  elif [[ $bytes -ge 1024 ]]; then printf "%d KB" $(( bytes / 1024 ));
  else printf "%d B" "$bytes"; fi
}

remove_items() {
  local description="$1"
  local pattern="$2"
  local base_dir="${3:-$HOME}"
  
  local count=0
  local total_size=0
  local items=()
  
  while IFS= read -r item; do
    items+=("$item")
    if [[ -f "$item" ]]; then
      local size
      size=$(stat -c%s "$item" 2>/dev/null || echo 0)
      total_size=$((total_size + size))
    fi
    count=$((count + 1))
  done < <(find "$base_dir" -name "$pattern" 2>/dev/null | head -100)
  
  if [[ $count -eq 0 ]]; then
    skip "$description: nothing found"
    return
  fi
  
  if $DRY_RUN; then
    warn "$description: $count items, ~$(format_size $total_size) [DRY RUN]"
  else
    for item in "${items[@]}"; do
      rm -rf "$item" 2>/dev/null
    done
    ok "$description: removed $count items, freed ~$(format_size $total_size)"
    TOTAL_FREED=$((TOTAL_FREED + total_size))
  fi
}

echo -e "\n${BOLD}${CYAN}  🧹 System Cleaner v2.0.0${RESET}"
$DRY_RUN && echo -e "  ${YELLOW}[DRY RUN MODE]${RESET}"
echo ""

step "Python Cache"
remove_items "Python .pyc files"     "*.pyc"
remove_items "Python __pycache__"    "__pycache__"
remove_items "Python .pyo files"     "*.pyo"

step "Temporary Files"
remove_items "Temp files (.tmp)"     "*.tmp"
remove_items "Temp files (.temp)"    "*.temp"
remove_items "Swap files (.swp)"     "*.swp"
remove_items "Backup files (~)"      "*~"

step "Log Files (Home)"
remove_items "Log files (.log)"      "*.log"

step "OS Artifacts"
remove_items "macOS .DS_Store"       ".DS_Store"
remove_items "Windows Thumbs.db"     "Thumbs.db"
remove_items "Windows desktop.ini"   "desktop.ini"
remove_items "Vim undo files"        ".*.un~"

step "Termux Cache"
if [[ -n "${TERMUX_VERSION:-}" ]]; then
  TERMUX_CACHE="$HOME/../cache"
  if [[ -d "$TERMUX_CACHE" ]]; then
    SIZE=$(du -sb "$TERMUX_CACHE" 2>/dev/null | cut -f1 || echo 0)
    if $DRY_RUN; then
      warn "Termux apt cache: ~$(format_size $SIZE) [DRY RUN]"
    else
      apt-get clean 2>/dev/null && ok "Termux apt cache cleared"
    fi
  fi
fi

step "Package Manager Caches"
if command -v pip3 &>/dev/null; then
  CACHE_DIR=$(pip3 cache dir 2>/dev/null)
  if [[ -d "$CACHE_DIR" ]]; then
    SIZE=$(du -sb "$CACHE_DIR" 2>/dev/null | cut -f1 || echo 0)
    if $DRY_RUN; then
      warn "pip cache: ~$(format_size $SIZE) [DRY RUN]"
    else
      pip3 cache purge 2>/dev/null && ok "pip cache cleared (~$(format_size $SIZE))"
      TOTAL_FREED=$((TOTAL_FREED + SIZE))
    fi
  fi
fi

if command -v npm &>/dev/null; then
  CACHE_DIR=$(npm config get cache 2>/dev/null)
  if [[ -d "$CACHE_DIR" ]]; then
    SIZE=$(du -sb "$CACHE_DIR" 2>/dev/null | cut -f1 || echo 0)
    if $DRY_RUN; then
      warn "npm cache: ~$(format_size $SIZE) [DRY RUN]"
    else
      npm cache clean --force 2>/dev/null && ok "npm cache cleared (~$(format_size $SIZE))"
      TOTAL_FREED=$((TOTAL_FREED + SIZE))
    fi
  fi
fi

echo ""
echo -e "${BOLD}  📊 Summary:${RESET}"
if $DRY_RUN; then
  echo -e "  Run without --dry-run to actually clean"
else
  echo -e "  ${GREEN}Total freed: $(format_size $TOTAL_FREED)${RESET}"
fi
echo ""
