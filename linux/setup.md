# Dev Environment Setup

Tags: #dev #vscode #dotnet #git #terminal

See [[p14s]] for system overview.

## AUR Helper (yay)

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## Terminal: Kitty

```bash
sudo pacman -S kitty ttf-jetbrains-mono-nerd otf-codenewroman-nerd
```

Config: `~/.config/kitty/kitty.conf`

Key shortcuts:
- `Ctrl+Shift+Enter` — new split
- `Ctrl+Shift+T` — new tab
- `Ctrl+Shift+L` — cycle layouts
- `Ctrl+Shift+R` — resize mode (W/N/T/S to resize, Ctrl+W/N/T/S to double step)
- `Ctrl+Shift+[` — previous window
- `Ctrl+Shift+]` — next window
- `Ctrl+Shift+F7` — show window numbers overlay (focus)
- `Ctrl+Shift+1`…`9` — switch to window by number
- `Ctrl+Shift+F5` — reload config
- `Ctrl+Shift+=` — increase font size
- `Ctrl+Shift+-` — decrease font size
- `Ctrl+Shift+Backspace` — reset font size

## Shell: zsh + Oh My Zsh + Powerlevel10k

```bash
sudo pacman -S zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
chsh -s /usr/bin/zsh
```

Set theme in `~/.zshrc`:
```
ZSH_THEME="powerlevel10k/powerlevel10k"
```

Configure prompt:
```bash
p10k configure
```

### Plugins

Enabled in `~/.zshrc` `plugins=(...)`:
- `git` — aliases (`gst`, `gco`, `gp`, etc.)
- `z` — frecent directory jumping (`z foo`)
- `sudo` — double `Esc` to prepend sudo to last command
- `dirhistory` — `Alt+←/→` back/forward, `Alt+↑` parent dir
- `zsh-autosuggestions` — grey inline suggestions from history, `→` to accept
- `fast-syntax-highlighting` — colors commands as you type (green=valid, red=invalid)

Install required plugins:
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
```

### fzf (fuzzy finder)

```bash
sudo pacman -S fzf
```

Add to `~/.zshrc`:
```bash
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
```

Key shortcuts:
- `Ctrl+R` — fuzzy search history
- `Ctrl+T` — fuzzy find files, paste path at cursor
- `Alt+C` — fuzzy find directories, cd into selected

`**` + `Tab` triggers fzf completion after most commands:
```bash
kill -9 **<Tab>       # fuzzy select process
ssh **<Tab>           # fuzzy select known host
git checkout **<Tab>  # fuzzy select branch
```

## eza (better ls)

```bash
sudo pacman -S eza
```

See [[eza]] for full args reference.

Aliases in `~/.zshrc`:
```bash
alias ls='eza'
alias ll='eza -la --git --group-directories-first'
alias lt='eza --tree'
```

## bat (better cat)

```bash
sudo pacman -S bat
```

- Syntax highlighting, line numbers, git change indicators
- Auto-paging for long files

```bash
bat file.txt          # instead of cat
bat --plain file.txt  # no decorations
```

## ripgrep (better grep)

```bash
sudo pacman -S ripgrep
```

See [[ripgrep]] for full reference.

## btop (resource monitor)

```bash
sudo pacman -S btop
```

Better `htop` — CPU, memory, network, disk I/O graphs all at once. Launch with `btop`.

## man & tldr (documentation)

```bash
sudo pacman -S man-db man-pages tldr
```

- [[man]] — full manuals, `man tar`, `man 5 fstab`
- [[tldr]] — practical examples, `tldr tar` (run `tldr -u` first to update cache)

## Editor: VS Code

```bash
yay -S visual-studio-code-bin
```

Disable telemetry: Settings → Telemetry Level → off

Extensions installed:
- **ms-mssql.mssql** — SQL Server (mssql)
- **ms-dotnettools.csharp** — C# Dev Kit
- **CucumberOpen.cucumber-official** — Cucumber/Reqnroll

Note: Reqnroll has no VS Code extension — use Cucumber extension instead. Full Reqnroll IDE support is Visual Studio 2022 only.

## .NET SDK

```bash
sudo pacman -S dotnet-sdk aspnet-runtime aspnet-targeting-pack
```

## Git UI: lazygit

```bash
sudo pacman -S lazygit
```

Launch inside a repo:
```bash
lazygit
```

## SQL Tools

- **VS Code mssql extension** — query editor, connects to SQL Server
- **Azure Data Studio** (`yay -S azuredatastudio-bin`) — retired Feb 2026, kept as backup
- **SSMS** — in Windows VM, for full DBA/profiler functionality

## TODO

- [x] Run `p10k configure` after logout/login (needs zsh as default shell active)
- [ ] Install and configure Neovim (relative line numbers, plugins)
- [ ] Fix VS Code SQL Profiler (needs active connection context before launching)

## Related

- [[p14s]] - system overview
- [[docker]] - SQL Server
- [[kvm]] - Windows VM
