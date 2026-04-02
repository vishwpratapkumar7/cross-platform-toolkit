#!/usr/bin/env bash
# ============================================================
# backup.sh - Smart Backup Tool
# Works on: Linux, Termux, macOS
# Usage: bash backup.sh [SOURCE] [OPTIONS]
# ============================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

VERSION="2.0.0"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_ROOT="${HOME}/.devtoolkit/backups"
MAX_BACKUPS=10
COMPRESS=true
VERIFY=true

source_dirs=()
exclude_patterns=(".git" "node_modules" "__pycache__" "*.pyc" ".cache" "*.tmp" "*.log")

usage() {
  cat <<EOF
${BOLD}Usage:${RESET} $(basename "$0") [SOURCE...] [OPTIONS]

${BOLD}Arguments:${RESET}
  SOURCE          Directory or file to backup (can repeat)

${BOLD}Options:${RESET}
  -o, --output    Backup destination (default: ~/.devtoolkit/backups)
  -n, --name      Backup name (default: auto-generated)
  -c, --no-compress  Skip compression
  -v, --no-verify    Skip verification
  -l, --list      List existing backups
  -r, --restore   Restore from backup
  -h, --help      Show this help

${BOLD}Examples:${RESET}
  $(basename "$0") ~/Projects
  $(basename "$0") ~/Documents ~/Downloads -o /sdcard/Backups
  $(basename "$0") --list
  $(basename "$0") --restore backup_20240101_120000.tar.gz

EOF
  exit 0
}

info()    { echo -e "  ${BLUE}[INFO]${RESET}   $1"; }
ok()      { echo -e "  ${GREEN}[OK]${RESET}     $1"; }
warn()    { echo -e "  ${YELLOW}[WARN]${RESET}   $1"; }
error()   { echo -e "  ${RED}[ERROR]${RESET}  $1" >&2; }
step()    { echo -e "\n${BOLD}${CYAN}  ── $1 ──${RESET}"; }

format_size() {
  local bytes="$1"
  if [[ $bytes -ge 1073741824 ]]; then
    echo "$(( bytes / 1073741824 )) GB"
  elif [[ $bytes -ge 1048576 ]]; then
    echo "$(( bytes / 1048576 )) MB"
  elif [[ $bytes -ge 1024 ]]; then
    echo "$(( bytes / 1024 )) KB"
  else
    echo "$bytes B"
  fi
}

list_backups() {
  step "Existing Backups"
  if [[ ! -d "$BACKUP_ROOT" ]] || [[ -z "$(ls -A "$BACKUP_ROOT" 2>/dev/null)" ]]; then
    warn "No backups found in $BACKUP_ROOT"
    return
  fi
  
  echo -e "\n  ${BOLD}Backups in ${BACKUP_ROOT}:${RESET}\n"
  local total_size=0
  local count=0
  
  while IFS= read -r file; do
    if [[ -f "$file" ]]; then
      local size
      size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
      local formatted_size
      formatted_size=$(format_size "$size")
      local date_str
      date_str=$(stat -c%y "$file" 2>/dev/null | cut -d. -f1 || date -r "$file" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "N/A")
      printf "  ${GREEN}%-45s${RESET} %8s  %s\n" "$(basename "$file")" "$formatted_size" "$date_str"
      total_size=$((total_size + size))
      count=$((count + 1))
    fi
  done < <(find "$BACKUP_ROOT" -maxdepth 1 -name "*.tar.gz" -o -name "*.tar.bz2" | sort -r)
  
  echo ""
  info "Total: $count backups, $(format_size $total_size)"
}

rotate_backups() {
  local count
  count=$(find "$BACKUP_ROOT" -maxdepth 1 -name "backup_*.tar.*" | wc -l)
  
  if [[ $count -ge $MAX_BACKUPS ]]; then
    warn "Max backups ($MAX_BACKUPS) reached, removing oldest..."
    find "$BACKUP_ROOT" -maxdepth 1 -name "backup_*.tar.*" | sort | head -n $(( count - MAX_BACKUPS + 1 )) | while read -r old; do
      rm -f "$old"
      warn "Removed old backup: $(basename "$old")"
    done
  fi
}

do_backup() {
  local backup_name="${1:-backup_${TIMESTAMP}}"
  
  echo -e "\n${BOLD}${CYAN}  💾 Smart Backup Tool v${VERSION}${RESET}"
  echo -e "  Time: $(date '+%Y-%m-%d %H:%M:%S')"
  
  if [[ ${#source_dirs[@]} -eq 0 ]]; then
    error "No source directory specified"
    usage
  fi
  
  step "Preparing Backup"
  mkdir -p "$BACKUP_ROOT"
  
  local exclude_args=()
  for pat in "${exclude_patterns[@]}"; do
    exclude_args+=(--exclude="$pat")
  done
  
  local archive_name="${backup_name}.tar"
  $COMPRESS && archive_name="${backup_name}.tar.gz"
  local archive_path="${BACKUP_ROOT}/${archive_name}"
  
  step "Creating Archive"
  info "Source(s):"
  for src in "${source_dirs[@]}"; do
    info "  → $src"
  done
  info "Destination: $archive_path"
  
  local start_time
  start_time=$(date +%s)
  
  if $COMPRESS; then
    tar -czf "$archive_path" "${exclude_args[@]}" "${source_dirs[@]}" 2>/dev/null
  else
    tar -cf "$archive_path" "${exclude_args[@]}" "${source_dirs[@]}" 2>/dev/null
  fi
  
  local end_time
  end_time=$(date +%s)
  local duration=$(( end_time - start_time ))
  
  ok "Archive created in ${duration}s"
  
  if $VERIFY; then
    step "Verifying Archive"
    if tar -tzf "$archive_path" &>/dev/null; then
      ok "Verification passed"
    else
      error "Verification FAILED!"
      exit 1
    fi
  fi
  
  local size
  size=$(stat -c%s "$archive_path" 2>/dev/null || stat -f%z "$archive_path" 2>/dev/null || echo 0)
  
  step "Creating Manifest"
  local manifest="${BACKUP_ROOT}/${backup_name}.manifest"
  cat > "$manifest" <<MANIFEST
# Backup Manifest
created: $(date '+%Y-%m-%d %H:%M:%S')
archive: $archive_name
size: $(format_size $size)
sources:
$(for s in "${source_dirs[@]}"; do echo "  - $s"; done)
exclude:
$(for p in "${exclude_patterns[@]}"; do echo "  - $p"; done)
compressed: $COMPRESS
verified: $VERIFY
MANIFEST
  ok "Manifest: $manifest"
  
  rotate_backups
  
  echo -e "\n  ${GREEN}${BOLD}✅ Backup Complete!${RESET}"
  echo -e "  Archive: ${YELLOW}$archive_path${RESET}"
  echo -e "  Size:    $(format_size $size)"
  echo -e "  Time:    ${duration}s\n"
}

# Parse arguments
BACKUP_NAME="backup_${TIMESTAMP}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--output)    BACKUP_ROOT="$2"; shift 2 ;;
    -n|--name)      BACKUP_NAME="$2"; shift 2 ;;
    -c|--no-compress) COMPRESS=false; shift ;;
    -v|--no-verify) VERIFY=false; shift ;;
    -l|--list)      list_backups; exit 0 ;;
    -h|--help)      usage ;;
    -*)             warn "Unknown option: $1"; shift ;;
    *)              source_dirs+=("$1"); shift ;;
  esac
done

do_backup "$BACKUP_NAME"
