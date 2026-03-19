# Snapper

Tags: #snapper #btrfs #snapshots #backup

Snapshot manager for btrfs. See [[p14s]] for filesystem layout.

## Configs

| Config | Volume | Timeline |
|--------|--------|----------|
| root | vg0-root | yes (auto) |
| home | vg0-home | no (manual only) |

snap-pac creates pre/post snapshots automatically on every `pacman` / [[yay]] update.

## Commands

### Create

```bash
sudo snapper -c root create --description "before doing X"
sudo snapper -c root create --description "important change" --userdata "important=yes"
sudo snapper -c home create --description "before doing X"
```

### List

```bash
sudo snapper -c root list
sudo snapper -c home list
```

### Rollback (undo changes between two snapshots)

```bash
sudo snapper -c root undochange 1..2
```

### Delete

```bash
sudo snapper -c root delete <number>
sudo snapper -c home delete <number>
```

### Mark as important

```bash
sudo snapper -c root modify --userdata "important=yes" <number>
```

## Config Limits

### Root

```ini
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
TIMELINE_LIMIT_HOURLY="3"
TIMELINE_LIMIT_DAILY="5"
TIMELINE_LIMIT_WEEKLY="2"
TIMELINE_LIMIT_MONTHLY="1"
TIMELINE_LIMIT_YEARLY="0"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="3"
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="1800"
SPACE_LIMIT="0.5"
FREE_LIMIT="0.2"
```

### Home

```ini
TIMELINE_CREATE="no"
TIMELINE_CLEANUP="yes"
NUMBER_LIMIT="5"
NUMBER_LIMIT_IMPORTANT="3"
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="1800"
SPACE_LIMIT="0.1"
FREE_LIMIT="0.2"
```

## Services

```bash
# Check timers are running
systemctl status snapper-timeline.timer
systemctl status snapper-cleanup.timer
```

## Related

- [[p14s]] - filesystem layout
- [[arch]] - pacman / system updates
- [[yay]] - AUR updates (also triggers snap-pac)
- [[backup]] - USB backup
