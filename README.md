# looky

An interactive CLI file search tool — a friendly wrapper around the `find` command.

## What it does

Instead of remembering complex `find` syntax, you just answer simple questions:

```
╔══════════════════════════════╗
║        🔍  File Looky        ║
╚══════════════════════════════╝
  Press Enter to skip any filter

Search directory [default: current dir]: /home/user
Part of filename (e.g. report, .pdf): invoice
File type: f = regular file, d = directory, l = symlink
Your choice [f/d/l]: f
Min size (e.g. 1k, 500k, 1M, 2G — or leave blank): 
Max size (e.g. 10M, 1G — or leave blank): 5M
Modified within last how many days? (e.g. 7 — or leave blank): 30

Assembled command:
  find "/home/user" -iname "*invoice*" -type f -size -5M -mtime -30

Run this search? [Y/n]: Y

Results:
──────────────────────────────────────
  ▸ /home/user/documents/invoice_jan.pdf
  ▸ /home/user/documents/invoice_feb.pdf
──────────────────────────────────────
  Found 2 result(s).
```

## Installation (from RPM)

```bash
# Build the RPM
chmod +x build.sh
./build.sh

# Install it
sudo rpm -ivh ~/rpmbuild/RPMS/noarch/looky-1.0-1.noarch.rpm

# Run it
looky
```

## Dependencies

- `findutils` (provides the `find` command — usually pre-installed on all Linux systems)

## Usage

```bash
looky           # interactive mode
looky --help    # show help
```

## Project Structure

```
looky-package/
├── SOURCES/
│   └── looky.sh       # main script
├── SPECS/
│   └── looky.spec     # RPM spec file
├── build.sh            # automated build script
└── README.md
```
