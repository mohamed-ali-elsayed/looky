# looky

A simple interactive file search tool. Instead of remembering `find` syntax, you just answer a few questions and looky does the rest.

## What it does

```
+======================================+
|           looky                      |
|     Interactive File Search Tool     |
+======================================+
  Press Enter to skip any filter

Search in [default: current dir]: /home
Part of filename: invoice

Search mode:
  1  Quick  - search now with just what you entered
  2  Full   - more filters: type, size, date, content...
```

Pick **Quick** to search immediately, or **Full** to filter by size, date, file type, content, and more.

After results you can open, move, delete, copy the path to clipboard, or export to a text file.

## Installation

**RHEL / CentOS / Fedora:**
```bash
sudo rpm -ivh https://github.com/mohamed-ali-elsayed/looky/releases/download/v1.0/looky-1.0-1.el9.noarch.rpm
```

**Ubuntu / Debian / Mint:**
```bash
wget https://github.com/mohamed-ali-elsayed/looky/releases/download/v1.0/looky_1.0-1.deb && sudo apt install ./looky_1.0-1.deb
```

## Usage

```bash
looky           # start the tool
looky --help    # show help
```

## Build from source

**RPM:**
```bash
chmod +x build-rpm.sh
./build-rpm.sh
```

**DEB:**
```bash
chmod +x build-deb.sh
./build-deb.sh
```

## Files

| File | Description |
|------|-------------|
| `looky.sh` | the main script |
| `looky.spec` | RPM spec file |
| `control` | Debian control file |
| `build-rpm.sh` | builds the .rpm package |
| `build-deb.sh` | builds the .deb package |
