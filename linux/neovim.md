# Neovim + LazyVim

Tags: #neovim #editor #lazyvim

## Installation

```bash
sudo pacman -S neovim

# Back up existing config if any
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}

# Clone LazyVim starter template
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git  # detach from template, make it your own

nvim   # bootstraps plugins on first launch
```

### Dependencies (for full LSP/tooling support)

```bash
sudo pacman -S nodejs npm python-pynvim gcc ripgrep wl-clipboard lazygit
```

- `nodejs` / `npm` — required by many LSP servers (Mason installs them)
- `python-pynvim` — Python plugin support
- `gcc` — treesitter compiles parsers natively
- `ripgrep` — used by Telescope live grep
- `wl-clipboard` — clipboard integration on Wayland (copy/paste to other apps)
- `lazygit` — integrates directly into LazyVim (`<leader>gg`)

---

## Setup Checklist

- [x] Install neovim + LazyVim starter
- [x] Launch `nvim` and wait for plugin bootstrap to complete
- [x] Run `:checkhealth` — checked, only minor warnings
- [x] Run `:Mason` — installed: `bash-language-server`, `clangd` (C), `solargraph` (Ruby), `omnisharp` (C#)
- [x] Set relative line numbers (already default in LazyVim)
- [ ] Configure lazygit integration
- [ ] Add C# / OmniSharp extra (see below)
- [ ] Install missing treesitter parsers (`bash`, `regex`) via `:TSInstall bash regex`

---

## Modal Editing Basics

LazyVim starts in **Normal mode**. You must switch to Insert mode to type.

| Key | Action |
|-----|--------|
| `i` | Insert before cursor |
| `a` | Insert after cursor |
| `o` | New line below, insert |
| `O` | New line above, insert |
| `Esc` / `jk` | Back to Normal mode |
| `v` | Visual (select) mode |
| `V` | Visual line mode |
| `Ctrl+v` | Visual block mode |

---

## Essential Keybindings

### The Leader Key

`<leader>` is a special prefix key — in LazyVim it is **Space**. You tap it first, then follow with another key to trigger a command. Think of it like a namespace for shortcuts so they don't conflict with normal typing.

Example: `<leader>w` means press Space, then W — saves the file.

Press Space and **wait** — the which-key popup will appear showing all available next keys.

### Files & Navigation

| Key | Action |
|-----|--------|
| `<leader><space>` | Find files (fuzzy) |
| `<leader>/` | Live grep (search in files) |
| `<leader>e` | File explorer (Neo-tree) |
| `<leader>fr` | Recent files |
| `<leader>fb` | Browse buffers |
| `<C-p>` | Find files (alternative) |

### Buffers & Windows

| Key | Action |
|-----|--------|
| `<leader>bb` | Switch buffer |
| `<leader>bd` | Close buffer |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<C-h/j/k/l>` | Move between splits |
| `<leader>-` | Split horizontal |
| `<leader>\|` | Split vertical |

### LSP (Code Intelligence)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover docs |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cd` | Line diagnostics |
| `[d` / `]d` | Previous / next diagnostic |

### Git (lazygit integration)

| Key | Action |
|-----|--------|
| `<leader>gg` | Open lazygit |
| `<leader>gb` | Git blame line |
| `<leader>gd` | Git diff |

### General

| Key | Action |
|-----|--------|
| `<leader>q` | Quit |
| `<leader>w` | Save |
| `<leader>qq` | Quit all |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `<leader>cm` | Open Mason (manage LSPs) |
| `<leader>l` | Open Lazy (plugin manager) |

### Editing (Normal mode)

| Key | Action |
|-----|--------|
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste below |
| `P` | Paste above |
| `gcc` | Toggle comment |
| `gc` + motion | Comment selection |
| `>>`/`<<` | Indent / dedent |
| `=G` | Auto-indent to end of file |
| `ciw` | Change inner word |
| `di"` | Delete inside quotes |

---

## C# / OmniSharp Setup

Add to `~/.config/nvim/lua/plugins/csharp.lua`:

```lua
return {
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = {},
      },
    },
  },
}
```

Then in Mason (`:Mason`), install `omnisharp`.

For `.sln` projects, open the folder containing the `.sln` file:
```bash
nvim .
```

---

## Tips

- **Which-key popup:** press `<leader>` and wait — a menu appears showing all keybindings
- **`:checkhealth`** — diagnose missing dependencies
- **`:Lazy`** — plugin manager UI, update all with `U`
- **`:Mason`** — install/update LSP servers, linters, formatters
- **`ZZ`** — save and quit (faster than `:wq`)
- **`ZQ`** — quit without saving

---

## Related

- [[setup]] — dev environment overview
- [[lazygit]] — git UI (integrates into LazyVim)
