Name:           looky
Version:        1.0
Release:        1%{?dist}
Summary:        Interactive file search tool — a friendly wrapper around find

License:        GPL-3.0
BuildArch:      noarch
Requires:       findutils

Source0:        looky.sh

%description
looky is an interactive CLI tool that helps users search for files
without needing to remember the syntax of the find command.

It asks simple questions about filename, type, size, modification
date, content, and owner. Every field is optional — just press
Enter to skip it. A quick mode lets the user search instantly with
just a directory and filename.

After results, the user can open, move, delete, copy the file path
to clipboard, or export the list to a text file.

%install
mkdir -p %{buildroot}/usr/local/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/local/bin/looky

%files
/usr/local/bin/looky

%changelog
* Fri Mar 06 2026 Mohamed Ali Elsayed <your@email.com> - 1.0-1
- Initial release of looky
