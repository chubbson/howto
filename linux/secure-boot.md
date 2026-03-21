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

### 1. Enter UEFI Setup Mode

In UEFI firmware settings, clear all Secure Boot keys (deletes the Platform Key → enters Setup Mode). Do **not** re-enable Secure Boot yet.

On ThinkPads the setting is under **Security → Secure Boot**. Look for one of:
- "Reset to Setup Mode" or "Clear All Secure Boot Keys"
- Switch "Secure Boot Mode" from **Standard** → **Custom**, then delete keys

Just disabling Secure Boot is not enough — the Platform Key must actually be deleted.

Confirm from running OS:
```bash
sbctl status
# Setup Mode: Enabled
```

If `sbctl enroll-keys` fails with "File is immutable", the firmware is not truly in Setup Mode — go back and ensure all keys are cleared (not just Secure Boot disabled).

### 2. Create and enroll keys

```bash
sudo sbctl create-keys

# Always use -m to include Microsoft keys — required on ThinkPads
# (firmware/OpROMs are Microsoft-signed; omitting -m can brick the system)
sudo sbctl enroll-keys -m
```

Enrolling the Platform Key exits Setup Mode. Secure Boot is now active on next boot.

### 3. Reinstall GRUB with modules embedded

Required before signing — `grub-install` produces a new unsigned EFI binary. Also needed because since GRUB 2.06, `insmod` is blocked at runtime under Secure Boot (shim path). With `--disable-shim-lock` (own-keys path), GRUB's lockdown is bypassed so `insmod` still works, but `tpm` is embedded anyway.

```bash
sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB \
  --modules="tpm" --disable-shim-lock
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 4. Sign EFI binaries

First discover all unsigned binaries UEFI will load:
```bash
sbctl verify
```

Then sign each flagged file with `-s` to register it for automatic re-signing via pacman hook:
```bash
sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi
sudo sbctl sign -s /boot/EFI/arch/fwupdx64.efi
sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi
sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi
sudo sbctl sign -s /boot/vmlinuz-linux

# Fallback bootloader path — may not exist
# sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI

# Confirm nothing missed
sudo sbctl verify
```

### 5. Reboot and verify

```bash
bootctl
# Secure Boot: enabled (user)  ← (user) confirms your keys are active

sbctl status
```

## After kernel update

The `-s` flag registers files with sbctl's pacman hook — re-signing happens automatically on `pacman -Syu`.

If you install a new kernel variant (e.g. `linux-lts`), sign it once manually:
```bash
sudo sbctl sign -s /boot/vmlinuz-linux-lts
```

Check registered files:
```bash
sbctl list-files
```

## TODO

- [x] Enable Setup Mode in UEFI firmware
- [x] Run sbctl create-keys + enroll-keys -m
- [x] Reinstall GRUB with --disable-shim-lock
- [x] Sign all EFI binaries (use sbctl verify to discover)
- [ ] Reboot and verify Secure Boot enabled (user mode)

## Related

- [[p14s]] - setup checklist
- [[arch]] - GRUB config, kernel params
- [[luks]] - full disk encryption (works alongside Secure Boot)
