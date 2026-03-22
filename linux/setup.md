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
- `Ctrl+Shift+R` — resize mode
- `Ctrl+Shift+F5` — reload config

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

## Related

- [[p14s]] - system overview
- [[docker]] - SQL Server
- [[kvm]] - Windows VM
