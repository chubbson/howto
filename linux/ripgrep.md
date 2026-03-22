# ripgrep (rg)

Faster alternative to `grep` for searching file contents.

Tags: #shell #cli

```bash
sudo pacman -S ripgrep
```

- Recursive by default, no need for `-r`
- Respects `.gitignore` automatically
- Skips binary files and `.git/`
- Colored output
- Integrates with fzf, bat, neovim

## Usage

```bash
rg "term"               # search recursively in current dir
rg "term" src/          # search in specific dir
rg -i "term"            # case insensitive
rg -l "term"            # only show filenames
rg -c "term"            # count matches per file
rg -t py "term"         # search only Python files
rg "term" -g "*.md"     # search only markdown files
rg -A 3 -B 3 "term"    # show 3 lines context around match
rg --no-ignore "term"   # include gitignored files
```

## Related

- [[setup]] — dev environment
