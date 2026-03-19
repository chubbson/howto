# Flatpak

Tags: #flatpak #permissions #security

## App IDs

| App | ID |
|-----|----|
| Obsidian | `md.obsidian.Obsidian` |
| Ungoogled Chromium | `com.github.Eloston.UngoogledChromium` |

## Permission Management

### Inspect

```bash
flatpak info --show-permissions <app-id>
flatpak override --user --show <app-id>
```

### Restrict filesystem access

```bash
# Remove access to home
flatpak override --user --nofilesystem=home <app-id>

# Grant access to specific folder only
flatpak override --user --filesystem=~/Documents <app-id>
```

### Network

```bash
flatpak override --user --unshare=network <app-id>
```

### Reset all overrides

```bash
flatpak override --user --reset <app-id>
```

## Common Commands

```bash
# List installed apps
flatpak list

# Update all
flatpak update

# Remove app
flatpak uninstall <app-id>

# Remove unused runtimes
flatpak uninstall --unused
```

## Related

- [[p14s]] - installed apps
- [[Install]] - setup checklist
