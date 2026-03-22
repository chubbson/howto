# man

Manual pages for Linux commands, system calls, config files, and more.

Tags: #shell #cli #docs

```bash
sudo pacman -S man-db man-pages
```

## Usage

```bash
man tar              # open manual for tar
man 5 fstab          # open section 5 (config files) for fstab
man -k keyword       # search manuals by keyword
man -f command       # show which sections exist for a command
```

Navigate with arrow keys, `q` to quit.

## Sections

| Section | Content |
|---|---|
| 1 | User commands (`ls`, `tar`, `git`) |
| 2 | System calls (`fork`, `open`, `read`) |
| 3 | Library functions (`printf`, `malloc`) |
| 4 | Special files (`/dev/null`, `/dev/random`) |
| 5 | Config files (`fstab`, `passwd`, `ssh_config`) |
| 6 | Games |
| 7 | Miscellaneous (`ascii`, `regex`, `signal`) |
| 8 | System admin commands (`mount`, `systemctl`, `useradd`) |
