#!/usr/bin/env bash
# ============================================================
# fileorg.sh - Smart File Organizer
# Sorts files into folders by type/extension
# Works on: Linux, Termux, macOS
# ============================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

MOVED=0
SKIPPED=0
ERRORS=0
DRY_RUN=false
TARGET_DIR="${1:-.}"

# ── File Type Categories ─────────────────────────────────────
declare -A FILE_TYPES=(
  ["Images"]="jpg jpeg png gif bmp tiff tif webp svg ico heic heif raw cr2 nef arw"
  ["Videos"]="mp4 mkv avi mov wmv flv webm m4v 3gp mpeg mpg vob ts m2ts"
  ["Audio"]="mp3 wav flac aac ogg wma m4a opus ape alac aiff"
  ["Documents"]="pdf doc docx odt rtf txt md markdown rst tex"
  ["Spreadsheets"]="xls xlsx csv ods tsv"
  ["Presentations"]="ppt pptx odp key"
  ["Archives"]="zip tar gz bz2 7z rar xz zst tar.gz tar.bz2 tar.xz"
  ["Code"]="py js ts jsx tsx html htm css scss sass php rb java cpp c h cs go rs swift kt lua pl sh bash zsh fish ps1 bat cmd"
  ["Data"]="json xml yaml yml toml ini cfg conf sql db sqlite"
  ["Fonts"]="ttf otf woff woff2 eot"
  ["eBooks"]="epub mobi azw azw3 fb2 cbr cbz"
  ["Executables"]="exe msi dmg deb rpm AppImage apk"
  ["Torrents"]="torrent"
)

get_category() {
  local ext="${1,,}"
  for category in "${!FILE_TYPES[@]}"; do
    for known_ext in ${FILE_TYPES[$category]}; do
      [[ "$ext" == "$known_ext" ]] && echo "$category" && return
    done
  done
  echo "Misc"
}

usage() {
  cat <<EOF
${BOLD}Usage:${RESET} $(basename "$0") [DIRECTORY] [OPTIONS]

${BOLD}Options:${RESET}
  -d, --dry-run     Show what would happen (no actual moves)
  -h, --help        Show this help

${BOLD}Examples:${RESET}
  $(basename "$0") ~/Downloads         # Organize Downloads
  $(basename "$0") . --dry-run         # Preview changes
  $(basename "$0") /sdcard/DCIM        # Organize camera (Termux)

EOF
  exit 0
}

# Parse args
for arg in "${@:-}"; do
  case "$arg" in
    -d|--dry-run) DRY_RUN=true ;;
    -h|--help) usage ;;
  esac
done

[[ ! -d "$TARGET_DIR" ]] && { echo -e "${RED}Error: '$TARGET_DIR' is not a directory${RESET}"; exit 1; }

TARGET_DIR=$(realpath "$TARGET_DIR")
LOG_FILE="${TARGET_DIR}/.fileorg_$(date +%Y%m%d_%H%M%S).log"

echo -e "\n${BOLD}${CYAN}  📁 Smart File Organizer${RESET}"
echo -e "  Directory: ${YELLOW}$TARGET_DIR${RESET}"
$DRY_RUN && echo -e "  ${YELLOW}[DRY RUN MODE - No files will be moved]${RESET}"
echo ""

find "$TARGET_DIR" -maxdepth 1 -type f | while IFS= read -r file; do
  filename=$(basename "$file")
  
  # Skip hidden files and this script's log
  [[ "$filename" == .* ]] && continue
  [[ "$filename" == *.log ]] && continue
  
  extension="${filename##*.}"
  [[ "$extension" == "$filename" ]] && extension="no_extension"
  
  category=$(get_category "$extension")
  dest_dir="$TARGET_DIR/$category"
  dest_file="$dest_dir/$filename"
  
  # Handle duplicates
  if [[ -f "$dest_file" ]]; then
    base="${filename%.*}"
    ext="${filename##*.}"
    counter=1
    while [[ -f "$dest_dir/${base}_${counter}.${ext}" ]]; do
      ((counter++))
    done
    dest_file="$dest_dir/${base}_${counter}.${ext}"
  fi
  
  if $DRY_RUN; then
    echo -e "  ${BLUE}[PREVIEW]${RESET} $filename → ${category}/"
    ((MOVED++))
  else
    mkdir -p "$dest_dir"
    if mv "$file" "$dest_file"; then
      echo -e "  ${GREEN}✓${RESET} $filename → ${category}/"
      echo "MOVED: $file → $dest_file" >> "$LOG_FILE"
      ((MOVED++))
    else
      echo -e "  ${RED}✗${RESET} Failed: $filename"
      ((ERRORS++))
    fi
  fi
done

echo ""
echo -e "${BOLD}  📊 Summary:${RESET}"
echo -e "  ${GREEN}Moved/Preview:  $MOVED${RESET}"
echo -e "  ${YELLOW}Skipped:       $SKIPPED${RESET}"
echo -e "  ${RED}Errors:        $ERRORS${RESET}"
$DRY_RUN || echo -e "  📋 Log: $LOG_FILE"
echo ""
