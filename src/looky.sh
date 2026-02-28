#!/bin/bash

# ============================================================
#  looky - Interactive file search tool
#  A user-friendly wrapper around the 'find' command
# ============================================================

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Help ---
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo -e "${BOLD}looky${RESET} - Interactive file search tool"
    echo ""
    echo "Usage: looky [--help]"
    echo ""
    echo "looky will ask you a series of optional questions to build"
    echo "a 'find' command. Just press Enter to skip any filter you"
    echo "don't care about."
    echo ""
    echo "Filters available:"
    echo "  - Search directory"
    echo "  - Part of filename"
    echo "  - File type (file, directory, symlink)"
    echo "  - Size range (min and/or max)"
    echo "  - Modified within last N days"
    exit 0
fi

# --- Header ---
echo ""
echo -e "${CYAN}${BOLD}╔══════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}║        🔍  File Looky        ║${RESET}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════╝${RESET}"
echo -e "${YELLOW}  Press Enter to skip any filter${RESET}"
echo ""

# --- Input Collection ---

# Directory
read -p "$(echo -e ${BOLD}"Search directory"${RESET}" [default: current dir]: ")" dir
dir="${dir:-.}"

# Validate directory
if [ ! -d "$dir" ]; then
    echo -e "${RED}Error: '$dir' is not a valid directory.${RESET}"
    exit 1
fi

# Filename
read -p "$(echo -e ${BOLD}"Part of filename"${RESET}" (e.g. report, .pdf): ")" name

# File type
echo -e "${BOLD}File type${RESET}: f = regular file, d = directory, l = symlink"
read -p "$(echo -e "Your choice [f/d/l]: ")" ftype

# Validate type input
if [ -n "$ftype" ] && [[ ! "$ftype" =~ ^[fdl]$ ]]; then
    echo -e "${YELLOW}Warning: Invalid type '$ftype', skipping type filter.${RESET}"
    ftype=""
fi

# Size range
read -p "$(echo -e ${BOLD}"Min size"${RESET}" (e.g. 1k, 500k, 1M, 2G — or leave blank): ")" minsize
read -p "$(echo -e ${BOLD}"Max size"${RESET}" (e.g. 10M, 1G — or leave blank): ")" maxsize

# Modified within N days
read -p "$(echo -e ${BOLD}"Modified within last how many days?"${RESET}" (e.g. 7 — or leave blank): ")" mdays

# Validate mdays is a number
if [ -n "$mdays" ] && ! [[ "$mdays" =~ ^[0-9]+$ ]]; then
    echo -e "${YELLOW}Warning: '$mdays' is not a valid number, skipping days filter.${RESET}"
    mdays=""
fi

# --- Build the find command ---
cmd="find \"$dir\""

[ -n "$name" ]    && cmd+=" -iname \"*$name*\""
[ -n "$ftype" ]   && cmd+=" -type $ftype"
[ -n "$minsize" ] && cmd+=" -size +$minsize"
[ -n "$maxsize" ] && cmd+=" -size -$maxsize"
[ -n "$mdays" ]   && cmd+=" -mtime -$mdays"

# Add readable output
cmd+=" -print"

# --- Show assembled command ---
echo ""
echo -e "${CYAN}${BOLD}Assembled command:${RESET}"
echo -e "  ${YELLOW}$cmd${RESET}"
echo ""

# --- Confirmation ---
read -p "$(echo -e ${BOLD}"Run this search? [Y/n]: "${RESET})" confirm
confirm="${confirm:-Y}"

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Search cancelled.${RESET}"
    exit 0
fi

# --- Run and collect results ---
echo ""
echo -e "${CYAN}${BOLD}Results:${RESET}"
echo -e "${CYAN}──────────────────────────────────────${RESET}"

results=$(eval $cmd 2>/dev/null)

if [ -z "$results" ]; then
    echo -e "${YELLOW}  No files found matching your criteria.${RESET}"
else
    echo "$results" | while IFS= read -r line; do
        echo -e "  ${GREEN}▸${RESET} $line"
    done

    count=$(echo "$results" | wc -l)
    echo ""
    echo -e "${CYAN}──────────────────────────────────────${RESET}"
    echo -e "  ${BOLD}Found ${GREEN}$count${RESET}${BOLD} result(s).${RESET}"
fi

echo ""
