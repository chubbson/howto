# Known Problems & Fixes

Tags: #troubleshooting

A running log of issues encountered and their fix status.

## 2026-03-22 — Hibernate Resume: Kernel Panic (Caps Lock Blink)

**Status:** Fixed 2026-03-22 — `HibernateMode=shutdown` in `/etc/systemd/sleep.conf`. PSR=2 (default) restored.

**Symptom:** After closing lid for several hours:
1. LUKS PIN prompt on wake (expected — system hibernated to encrypted swap)
2. After PIN entry, caps lock LED blinks indefinitely → must hard reboot (10s power button)

Caps lock blinking = kernel panic during hibernate resume.

**Current sleep config:**
- `logind.conf`: `HandleLidSwitch=suspend-then-hibernate`, `HandlePowerKey=hibernate`
- `sleep.conf`: `HibernateDelaySec=30min`
- GNOME: `power-button-action='hibernate'` (fixed 2026-03-22, was `'suspend'`)
- Lid close → suspend → hibernate after 30 min
- Power button → hibernate directly

**Hibernate setup is correct:**
- Kernel param: `resume=/dev/vg0/swap` ✓
- Initramfs hook: `resume` present in HOOKS, after `lvm2` ✓
- `linux-firmware 20260309-1` — up to date ✓
- Kernel: `6.19.9-arch1-1`
- GPU: Intel Arc 140V `[8086:7d55]` (Meteor Lake-P), i915 driver

**Root cause:** `HibernateMode=platform` (ACPI S4) is broken on Meteor Lake.

Hibernate has two parts: saving (write RAM → swap) and restoring (read swap → RAM). Both worked fine. The panic happened in between — in how the system powers off after saving:

- **`platform` mode (broken):** After writing the image, hands off to ACPI firmware to enter S4 hardware sleep state. MTL advertises S4 in ACPI tables but the implementation is broken — same story as S3 being replaced by S0ix. The firmware S4 path corrupted state, causing a kernel panic when the kernel tried to restore.
- **`shutdown` mode (works):** After writing the image, does a normal kernel power-off. No firmware involvement. On next boot, initramfs detects the hibernation image in swap and restores it cleanly.

PSR was a red herring — `i915: Selective fetch area calculation failed in pipe A` errors are real i915 bugs but were not causing the panic. Panic happened before journald starts so the real cause was never logged directly.

**Fix:**
```
# /etc/systemd/sleep.conf
HibernateMode=shutdown
```

Remove any `i915.enable_psr=N` from GRUB cmdline — PSR is unrelated and default (PSR=2) is fine.

---

## 2026-03-22 — Audio: Dummy Output (Intel Meteor Lake)

**Status:** Pending fix

**Symptom:** Only "Dummy Output" in PipeWire, no sound cards detected.

**Cause:** Missing SOF firmware + possible kernel 6.16+ regression.

See [[audio]] for full details and fix plan.

---

## 2025-10-30 — Broken GDM after pacman -Syu

**Status:** Fixed

**Symptom:** GNOME didn't start after system update.

**Fix:** Added missing `gdm-greeter` entry to `/etc/shadow`:
```
gdm-greeter:!*:0::::::
```

---

## Unknown date — VM broke GRUB

**Status:** Fixed

**Symptom:** GRUB broken after VM operation.

**Fix:**
```bash
mount /dev/sda3 /mnt
mount /dev/sda1 /mnt/boot
grub-install --target=x86_64-efi --efi-directory=/mnt/boot --root-directory=/mnt --recheck
```

---
