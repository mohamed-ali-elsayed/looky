#!/bin/bash

# looky - friendly wrapper around the find command

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo -e "${BOLD}looky${RESET} - find files without remembering find syntax"
    echo ""
    echo "Usage:  looky"
    echo ""
    echo "Quick mode   asks only for directory and filename, then runs"
    echo "Full mode    asks everything: type, size, date, content, owner..."
    echo ""
    echo "After results you can open, move, delete, copy path, or export"
    exit 0
fi

file_size() {
    [ ! -f "$1" ] && echo "-" && return
    local b
    b=$(stat -c%s "$1" 2>/dev/null || echo 0)
    (( b >= 1073741824 )) && printf "%.1fG" "$(echo "scale=1; $b/1073741824" | bc)" && return
    (( b >= 1048576    )) && printf "%.1fM" "$(echo "scale=1; $b/1048576"    | bc)" && return
    (( b >= 1024       )) && printf "%.1fK" "$(echo "scale=1; $b/1024"       | bc)" && return
    printf "%dB" "$b"
}

file_date() {
    stat -c "%y" "$1" 2>/dev/null | cut -d'.' -f1
}

clear
echo ""
echo -e "${CYAN}${BOLD}+======================================+${RESET}"
echo -e "${CYAN}${BOLD}|           looky                      |${RESET}"
echo -e "${CYAN}${BOLD}|     Interactive File Search Tool     |${RESET}"
echo -e "${CYAN}${BOLD}+======================================+${RESET}"
echo -e "${DIM}  Press Enter to skip any filter${RESET}"
echo ""

# directory
read -p "$(echo -e "${BOLD}Search in${RESET} ${DIM}[default: current dir]${RESET}: ")" dir
dir="${dir:-.}"
if [ ! -d "$dir" ]; then
    echo -e "${RED}$dir is not a valid directory.${RESET}"
    exit 1
fi

# filename
read -p "$(echo -e "${BOLD}Part of filename${RESET} ${DIM}(e.g. invoice, report, .pdf)${RESET}: ")" name
echo ""

# quick or full
echo -e "${BOLD}Search mode:${RESET}"
echo -e "  ${BOLD}1${RESET}  Quick  - search now with just what you entered"
echo -e "  ${BOLD}2${RESET}  Full   - more filters: type, size, date, content..."
echo ""
read -p "$(echo -e "${BOLD}Choose [1/2]${RESET} ${DIM}[default: 1]${RESET}: ")" mode
mode="${mode:-1}"
echo ""

ext="" ; ftype="" ; owner="" ; minsize="" ; maxsize="" ; mdays="" ; content="" ; exclude="" ; maxresults="" ; exportfile=""

if [ "$mode" == "2" ]; then

    echo -e "${BOLD}${CYAN}[ File details ]${RESET}"

    read -p "$(echo -e "${BOLD}Extension${RESET} ${DIM}(e.g. pdf, log - without the dot)${RESET}: ")" ext

    echo -e "${DIM}  f = regular file   d = directory   l = symlink${RESET}"
    read -p "$(echo -e "${BOLD}File type${RESET} ${DIM}[f/d/l]${RESET}: ")" ftype
    if [ -n "$ftype" ] && [[ ! "$ftype" =~ ^[fdl]$ ]]; then
        echo -e "${YELLOW}Invalid, skipping type filter.${RESET}"
        ftype=""
    fi

    read -p "$(echo -e "${BOLD}Owned by${RESET} ${DIM}(e.g. root)${RESET}: ")" owner
    echo ""

    echo -e "${BOLD}${CYAN}[ Size ]${RESET}"
    echo -e "${DIM}  Units: k = KB   M = MB   G = GB${RESET}"
    read -p "$(echo -e "${BOLD}Min size${RESET} ${DIM}(e.g. 1M)${RESET}: ")" minsize
    read -p "$(echo -e "${BOLD}Max size${RESET} ${DIM}(e.g. 500M)${RESET}: ")" maxsize
    echo ""

    echo -e "${BOLD}${CYAN}[ Date ]${RESET}"
    read -p "$(echo -e "${BOLD}Modified in the last N days${RESET} ${DIM}(e.g. 7)${RESET}: ")" mdays
    if [ -n "$mdays" ] && ! [[ "$mdays" =~ ^[0-9]+$ ]]; then
        echo -e "${YELLOW}Not a number, skipping.${RESET}"
        mdays=""
    fi
    echo ""

    echo -e "${BOLD}${CYAN}[ Content ]${RESET}"
    read -p "$(echo -e "${BOLD}Files containing this text${RESET} ${DIM}(leave blank to skip)${RESET}: ")" content
    echo ""

    echo -e "${BOLD}${CYAN}[ Other ]${RESET}"
    read -p "$(echo -e "${BOLD}Exclude subfolder${RESET} ${DIM}(e.g. node_modules)${RESET}: ")" exclude
    read -p "$(echo -e "${BOLD}Max results to show${RESET} ${DIM}(leave blank for all)${RESET}: ")" maxresults
    read -p "$(echo -e "${BOLD}Export results to file${RESET} ${DIM}(enter filename or leave blank)${RESET}: ")" exportfile
    echo ""

fi

# build the command
cmd="find \"$dir\""

if [ -n "$exclude" ]; then
    cmd+=" -path \"*/$exclude\" -prune -o"
fi

[ -n "$ftype" ]   && cmd+=" -type $ftype"
[ -n "$name" ]    && cmd+=" -iname \"*$name*\""
[ -n "$ext" ]     && cmd+=" -iname \"*.$ext\""
[ -n "$owner" ]   && cmd+=" -user $owner"
[ -n "$minsize" ] && cmd+=" -size +$minsize"
[ -n "$maxsize" ] && cmd+=" -size -$maxsize"
[ -n "$mdays" ]   && cmd+=" -mtime -$mdays"

if [ -n "$content" ]; then
    cmd+=" -type f -print0 2>/dev/null | xargs -0 grep -l \"$content\" 2>/dev/null"
else
    cmd+=" -print"
fi

echo -e "${CYAN}${BOLD}Command:${RESET}"
echo -e "  ${YELLOW}$cmd${RESET}"
echo ""

read -p "$(echo -e "${BOLD}Run? [Y/n]${RESET}: ")" confirm
confirm="${confirm:-Y}"
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Cancelled.${RESET}"
    exit 0
fi

# run
echo ""
echo -e "${CYAN}${BOLD}Results:${RESET}"
echo -e "${CYAN}--------------------------------------------------------${RESET}"

results=$(eval "$cmd" 2>/dev/null)

if [ -z "$results" ]; then
    echo -e "${YELLOW}  Nothing found.${RESET}"
    echo ""
    exit 0
fi

[ -n "$maxresults" ] && [[ "$maxresults" =~ ^[0-9]+$ ]] && results=$(echo "$results" | head -n "$maxresults")

i=1
while IFS= read -r f; do
    if [ -f "$f" ]; then
        sz=$(file_size "$f")
        dt=$(file_date "$f")
        printf "  ${GREEN}%3d${RESET}  ${GREEN}>${RESET} %-55s ${DIM}%6s  %s${RESET}\n" "$i" "$f" "$sz" "$dt"
    else
        printf "  ${MAGENTA}%3d${RESET}  ${MAGENTA}>${RESET} %s\n" "$i" "$f"
    fi
    ((i++))
done <<< "$results"

count=$(echo "$results" | wc -l)
echo ""
echo -e "${CYAN}--------------------------------------------------------${RESET}"
echo -e "  ${BOLD}Found ${GREEN}$count${RESET}${BOLD} result(s).${RESET}"
echo ""

if [ -n "$exportfile" ]; then
    echo "$results" > "$exportfile"
    echo -e "${GREEN}Saved to: $exportfile${RESET}"
    echo ""
fi

# actions
echo -e "${BOLD}What do you want to do?${RESET}"
echo -e "  ${BOLD}1${RESET}  Open a file"
echo -e "  ${BOLD}2${RESET}  Copy path to clipboard"
echo -e "  ${BOLD}3${RESET}  Move files to another folder"
echo -e "  ${BOLD}4${RESET}  Delete a file"
echo -e "  ${BOLD}5${RESET}  Done"
echo ""
read -p "$(echo -e "${BOLD}Choice [1-5]${RESET}: ")" action

case $action in
    1)
        read -p "Result number: " num
        f=$(echo "$results" | sed -n "${num}p")
        if [ -f "$f" ]; then
            command -v xdg-open &>/dev/null && xdg-open "$f" 2>/dev/null & \
                echo -e "${GREEN}Opening: $f${RESET}" \
                || echo -e "${YELLOW}xdg-open not available. Path: $f${RESET}"
        else
            echo -e "${RED}Invalid number.${RESET}"
        fi
        ;;
    2)
        read -p "Result number: " num
        f=$(echo "$results" | sed -n "${num}p")
        if [ -n "$f" ]; then
            if command -v xclip &>/dev/null; then
                echo -n "$f" | xclip -selection clipboard
                echo -e "${GREEN}Copied: $f${RESET}"
            elif command -v xsel &>/dev/null; then
                echo -n "$f" | xsel --clipboard --input
                echo -e "${GREEN}Copied: $f${RESET}"
            else
                echo -e "${YELLOW}No clipboard tool found. Path: $f${RESET}"
            fi
        fi
        ;;
    3)
        read -p "Destination folder: " dest
        [ ! -d "$dest" ] && mkdir -p "$dest" && echo -e "${YELLOW}Created: $dest${RESET}"
        echo "$results" | while IFS= read -r f; do
            [ -f "$f" ] && mv "$f" "$dest/" && echo -e "${GREEN}Moved: $f${RESET}"
        done
        ;;
    4)
        read -p "Result number (or 'all'): " num
        if [ "$num" == "all" ]; then
            read -p "$(echo -e "${RED}Delete all results? [y/N]${RESET}: ")" sure
            if [[ "$sure" =~ ^[Yy]$ ]]; then
                echo "$results" | while IFS= read -r f; do
                    [ -f "$f" ] && rm "$f" && echo -e "${RED}Deleted: $f${RESET}"
                done
            else
                echo "Cancelled."
            fi
        else
            f=$(echo "$results" | sed -n "${num}p")
            if [ -f "$f" ]; then
                read -p "$(echo -e "${RED}Delete '$f'? [y/N]${RESET}: ")" sure
                [[ "$sure" =~ ^[Yy]$ ]] && rm "$f" && echo -e "${RED}Deleted.${RESET}" || echo "Cancelled."
            else
                echo -e "${RED}Invalid number.${RESET}"
            fi
        fi
        ;;
    *)
        echo -e "${DIM}Bye!${RESET}"
        ;;
esac

echo ""
