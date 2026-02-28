#!/bin/bash

# ============================================================
#  build.sh — Automates building the looky RPM package
# ============================================================

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}${BOLD}=== looky RPM Build Script ===${RESET}"
echo ""

# 1. Check for rpm-build
if ! command -v rpmbuild &>/dev/null; then
    echo -e "${RED}rpmbuild not found. Install it first:${RESET}"
    echo "  Fedora/RHEL:   sudo dnf install rpm-build rpmdevtools"
    echo "  Ubuntu/Debian: sudo apt install rpm"
    exit 1
fi

# 2. Set up rpmbuild tree in home directory
echo -e "${BOLD}[1/4] Setting up rpmbuild directory tree...${RESET}"
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# 3. Copy files into place
echo -e "${BOLD}[2/4] Copying source files...${RESET}"
cp SOURCES/looky.sh ~/rpmbuild/SOURCES/
cp SPECS/looky.spec ~/rpmbuild/SPECS/

# 4. Build the RPM
echo -e "${BOLD}[3/4] Building RPM...${RESET}"
rpmbuild -bb ~/rpmbuild/SPECS/looky.spec

# 5. Show result
echo ""
echo -e "${BOLD}[4/4] Done! Your RPM package:${RESET}"
find ~/rpmbuild/RPMS -name "looky-*.rpm" | while read f; do
    echo -e "  ${GREEN}▸ $f${RESET}"
done

echo ""
echo -e "${BOLD}To install:${RESET}"
echo "  sudo rpm -ivh ~/rpmbuild/RPMS/noarch/looky-1.0-1.noarch.rpm"
echo ""
echo -e "${BOLD}To test before installing:${RESET}"
echo "  bash SOURCES/looky.sh"
