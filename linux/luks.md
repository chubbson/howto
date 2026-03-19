# LUKS Encryption

Tags: #luks #encryption #security

See [[p14s]] for disk layout context.

## Setup

- Algorithm: LUKS2 with Argon2id KDF
- No weak pbkdf2 slots
- GRUB never touches LUKS — kernel handles decryption via initramfs

### Key slots

| Slot | Type | Description |
|------|------|-------------|
| 0 | Passphrase | Strong passphrase fallback |
| 2 | FIDO2 | SoloKey #1 |
| 3 | FIDO2 | SoloKey #2 |

See [[solo2]] for SoloKey setup.

## crypttab

```
cryptlvm  /dev/nvme0n1p3  -  fido2-device=auto,token-timeout=10,tries=3
```

- `fido2-device=auto` — auto-detect FIDO2 key
- `token-timeout=10` — seconds to wait for key touch
- `tries=3` — fallback to passphrase after 3 failed attempts

## Boot Flow

```
UEFI → GRUB (silent)
→ kernel starts
→ PIN prompt → SoloKey touch OR Enter → passphrase
→ LUKS unlocks → LVM activates → Arch boots
```

## Useful Commands

```bash
# Show LUKS info
sudo cryptsetup luksDump /dev/nvme0n1p3

# List key slots
sudo cryptsetup luksDump /dev/nvme0n1p3 | grep -i slot

# Test passphrase (dry run)
sudo cryptsetup open --test-passphrase /dev/nvme0n1p3

# Add FIDO2 key
sudo systemd-cryptenroll --fido2-device=auto /dev/nvme0n1p3

# Remove a slot
sudo cryptsetup luksKillSlot /dev/nvme0n1p3 <slot-number>
```

## Backup

LUKS header backed up to USB:
```bash
sudo cryptsetup luksHeaderBackup /dev/nvme0n1p3 --header-backup-file luks-header-backup.img
```

See [[backup]] for full backup setup.

## Recovery

If LUKS header is corrupted, restore from backup:
```bash
sudo cryptsetup luksHeaderRestore /dev/nvme0n1p3 --header-backup-file luks-header-backup.img
```

## Related

- [[p14s]] - disk layout
- [[solo2]] - FIDO2 hardware key
- [[backup]] - LUKS header backup
- [[arch]] - boot troubleshooting
