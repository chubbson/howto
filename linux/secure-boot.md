# Secure Boot

Tags: #secure-boot #sbctl #uefi #security

See [[p14s]] for system context. See [[arch]] for GRUB setup.

## Tool: sbctl

`sbctl` manages Secure Boot keys and signs EFI binaries.

## Install

```bash
sudo pacman -S sbctl
```

## Setup

```bash
# Check current status
sbctl status

# Create custom keys
sudo sbctl create-keys

# Enroll keys (include Microsoft keys for compatibility)
sudo sbctl enroll-keys -m

# Sign bootloader and kernel
sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi
sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi
sudo sbctl sign -s /boot/vmlinuz-linux

# Verify signed files
sbctl verify

# List all signed files
sbctl list-files
```

## After kernel update

Signed files need re-signing after kernel updates. With `-s` flag during initial sign, sbctl hooks into pacman and re-signs automatically.

```bash
# Manual re-sign all registered files
sudo sbctl sign-all
```

## Status Check

```bash
sbctl status
# Should show:
# Installed: yes
# Owner GUID: ...
# Setup Mode: Disabled
# Secure Boot: Enabled
```

## TODO

- [ ] Enable Setup Mode in UEFI firmware
- [ ] Run sbctl create-keys + enroll-keys
- [ ] Sign GRUB + kernel
- [ ] Reboot and verify Secure Boot enabled

## Related

- [[p14s]] - setup checklist
- [[arch]] - GRUB config, kernel params
- [[luks]] - full disk encryption (works alongside Secure Boot)
