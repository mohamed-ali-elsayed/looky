#!/bin/bash

# build-rpm.sh - builds the looky RPM package

set -e

if ! command -v rpmbuild &>/dev/null; then
    echo "rpmbuild not found. Install it first:"
    echo "  sudo dnf install rpm-build rpmdevtools"
    exit 1
fi

mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

cp looky.sh ~/rpmbuild/SOURCES/looky.sh
cp looky.spec ~/rpmbuild/SPECS/looky.spec

rpmbuild -bb ~/rpmbuild/SPECS/looky.spec

echo ""
echo "Done! RPM package:"
find ~/rpmbuild/RPMS -name "looky-*.rpm"
echo ""
echo "To install:"
echo "  sudo rpm -ivh ~/rpmbuild/RPMS/noarch/looky-1.0-1.el9.noarch.rpm"
