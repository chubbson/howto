# Backup

Tags: #backup #luks #recovery

See [[p14s]] for disk layout. See [[luks]] for LUKS header backup.

## USB Stick

| Device | Size | Filesystem | Mount | Purpose |
|--------|------|------------|-------|---------|
| sdb | 462GB | - | - | backup USB |
| sdb1 | 10GB | - | `/mnt/backup/p14sg5/` | system backups |
| sdb2 | ~452GB | - | - | storage |

## Mount

```bash
sudo mount /dev/sdb1 /mnt/backup/p14sg5/
```

Use PARTUUID to mount regardless of device name (sda/sdb can shift):

```bash
# Get PARTUUID
sudo blkid /dev/sda1

# Mount by PARTUUID
sudo mount /dev/disk/by-partuuid/bd09407f-01 /mnt/backup
```

## Backup Contents

Located at `/mnt/backup/p14sg5/`:

| File | Description |
|------|-------------|
| `luks-header-backup.img` | LUKS header (critical — keep safe) |
| `partition-table-backup.sfdisk` | GPT partition table |
| `lvm-backup.cfg` | LVM config |
| `crypttab-backup` | crypttab |
| `fstab-backup` | fstab |
| `grub-backup` | GRUB config |
| `mkinitcpio-backup` | initramfs config |

Script: `/mnt/backup/p14sg5/backup.sh`

## Commands

### LUKS header backup

```bash
sudo cryptsetup luksHeaderBackup /dev/nvme0n1p3 \
  --header-backup-file /mnt/backup/p14sg5/luks-header-backup.img
```

### Partition table backup

```bash
sudo sfdisk -d /dev/nvme0n1 > /mnt/backup/p14sg5/partition-table-backup.sfdisk
```

### LVM backup

```bash
sudo vgcfgbackup -f /mnt/backup/p14sg5/lvm-backup.cfg vg0
```

### LUKS header restore (recovery)

```bash
sudo cryptsetup luksHeaderRestore /dev/nvme0n1p3 \
  --header-backup-file /mnt/backup/p14sg5/luks-header-backup.img
```

## Restore

Mount the USB first, then navigate to the timestamped backup folder:

```bash
sudo mount /dev/disk/by-partuuid/bd09407f-01 /mnt/backup
BACKUP=/mnt/backup/p14sg5/<timestamp>
```

### Partition table

```bash
sudo sfdisk /dev/nvme0n1 < $BACKUP/partition-table-backup.sfdisk
```

### LVM config

```bash
sudo vgcfgrestore -f $BACKUP/lvm-backup.cfg vg0
```

### System configs

```bash
sudo cp $BACKUP/crypttab-backup /etc/crypttab
sudo cp $BACKUP/fstab-backup /etc/fstab
sudo cp $BACKUP/mkinitcpio-backup /etc/mkinitcpio.conf
sudo cp $BACKUP/grub-backup /etc/default/grub
sudo cp $BACKUP/grub-cfg-backup /boot/grub/grub.cfg
sudo cp -r $BACKUP/snapper-configs/* /etc/snapper/configs/
```

### Secure Boot keys

```bash
sudo cp -r $BACKUP/secureboot-keys /var/lib/sbctl/keys
sudo sbctl enroll-keys -m
sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi
sudo sbctl sign -s /boot/vmlinuz-linux
# sign remaining files as needed — see [[secure-boot]]
```

## TODO

- [x] Test backup.sh run
- [ ] Verify LUKS header backup is readable
- [ ] Store USB in safe location

## Related

- [[luks]] - encryption setup
- [[p14s]] - setup checklist
- [[snapper]] - btrfs snapshots (separate from this backup)
