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
without needing to remember the syntax of the 'find' command.

It asks simple questions about:
  - Part of the filename
  - File type (file, directory, or symlink)
  - Size range (minimum and/or maximum)
  - Last modification date

Every field is optional — the user only fills in what they know.
looky then assembles and runs the appropriate find command,
showing results with color-coded output and a result count.

%install
mkdir -p %{buildroot}/usr/local/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/local/bin/looky

%files
/usr/local/bin/looky

%changelog
* Wed Feb 25 2026 Your Name <you@email.com> - 1.0-1
- Initial release of looky
