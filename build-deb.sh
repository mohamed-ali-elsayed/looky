#!/bin/bash

# ============================================================
#  build-deb.sh — Builds the looky .deb package
# ============================================================

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}${BOLD}=== looky .deb Build Script ===${RESET}"
echo ""

# Check for dpkg-deb
if ! command -v dpkg-deb &>/dev/null; then
    echo -e "${RED}dpkg-deb not found. Install it first:${RESET}"
    echo "  sudo apt install dpkg"
    exit 1
fi

echo -e "${BOLD}[1/3] Setting up package structure...${RESET}"
mkdir -p looky_1.0-1/DEBIAN
mkdir -p looky_1.0-1/usr/local/bin

echo -e "${BOLD}[2/3] Copying files...${RESET}"
cp looky.sh looky_1.0-1/usr/local/bin/looky
cp control looky_1.0-1/DEBIAN/control
chmod 0755 looky_1.0-1/usr/local/bin/looky

echo -e "${BOLD}[3/3] Building .deb package...${RESET}"
dpkg-deb --build looky_1.0-1

echo ""
echo -e "${GREEN}${BOLD}Done! Package created: looky_1.0-1.deb${RESET}"
echo ""
echo -e "${BOLD}To install:${RESET}"
echo "  sudo dpkg -i looky_1.0-1.deb"
echo ""
echo -e "${BOLD}To uninstall:${RESET}"
echo "  sudo dpkg -r looky"
