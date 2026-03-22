# eza

Better `ls` replacement with colors, icons, git integration, and tree view.

Tags: #shell #cli

```bash
sudo pacman -S eza
```

## Aliases

```bash
alias ls='eza'
alias ll='eza -la --git --group-directories-first'
alias lt='eza --tree'
```

## Useful Args

| Arg | Description |
|---|---|
| `-l` | long view (permissions, size, date) |
| `-a` | show hidden files |
| `--git` | show git status per file |
| `--group-directories-first` | list dirs before files |
| `--tree` | tree view |
| `--level=N` | limit tree depth |
| `--icons` | file type icons (needs Nerd Font) |
| `--header` | add column headers |
| `--total-size` | show recursive directory sizes |
| `--git-ignore` | hide files in `.gitignore` |
| `--only-dirs` | list only directories |
| `--only-files` | list only files |
| `--sort size` | sort by field (size, modified, name, etc.) |
| `--reverse` | reverse sort order |

## Examples

```bash
ll                          # long view with git status, dirs first
lt                          # full tree
eza --tree --level=2        # tree limited to 2 levels
eza -la --sort size         # sort by size
eza -la --total-size        # show directory sizes
eza -la --git-ignore        # hide gitignored files
eza --only-dirs             # directories only
```
