Install [[ProtonVPN]] on Arch
Install [[rust]]
Install [[solo2]]

## P14s Setup Checklist

See [[p14s]] for full system context.

### Security & Boot

- [ ] [[luks]] - verify LUKS slots (passphrase + 2x SoloKey)
- [ ] [[secure-boot]] - sbctl setup
- [ ] [[solo2]] PAM FIDO2 for login/sudo

### SSH & Keys

- [ ] [[ssh]] - generate ed25519-sk key
- [ ] [[ssh]] - enroll second SoloKey
- [ ] [[ssh]] - add public key to GitHub
- [ ] [[ssh]] - test `ssh -T git@github.com`
- [ ] [[ssh]] - ssh-agent + passphrase
- [ ] Clone Obsidian vault via SSH

### System

- [ ] fwupd firmware updates (`sudo fwupdmgr update`)
- [ ] Intel Arc drivers (`i915.force_probe` — see [[arch]])
- [ ] Nvidia eGPU drivers (GTX 1070)
- [ ] Hibernation/sleep config (lid=suspend, power=hibernate)

### Dev Environment

- [ ] [[docker]] - install + SQL Server setup
- [ ] [[kvm]] - KVM/QEMU + Windows VM
- [ ] Windows VM: Visual Studio, Teams, Outlook, SSMS

### Apps & Permissions

- [ ] [[flatpak]] - review permissions for Obsidian, Chromium

### Backup

- [ ] [[backup]] - test backup.sh run
- [ ] [[snapper]] - verify timeline + cleanup timers running
