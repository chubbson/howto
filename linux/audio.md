# Audio: Intel Meteor Lake

Tags: #audio #hardware #troubleshooting

## Problem

Intel Meteor Lake-P HD Audio Controller shows only "Dummy Output" in PipeWire. Kernel sees no sound cards (`/proc/asound/cards` empty).

## Root Cause

Two separate issues:

1. **Missing SOF firmware** — Meteor Lake DSP requires firmware binaries (`sof-firmware`) and UCM profiles (`alsa-ucm-conf`) to initialize. Without them, the driver loads but no sound card is registered.

2. **Kernel 6.16+ regression** — A kernel code change broke SOF driver initialization for Meteor Lake. Present in 6.16–6.19+. May or may not be patched in current kernel.

## Fix Plan

- [ ] Install `linux-lts` as fallback kernel in case current kernel has the regression
- [ ] Take snapper snapshots before proceeding
- [ ] Install firmware packages:
  ```bash
  sudo pacman -S sof-firmware alsa-ucm-conf alsa-utils
  ```
- [ ] Reboot into current kernel — if audio works, done
- [ ] If not, reboot into LTS kernel and test there
- [ ] If LTS works, check Arch forums for kernel regression patch status

## Diagnosis Commands

```bash
cat /proc/asound/cards              # should show card, not "no soundcards"
pactl list sinks short              # should show real device, not auto_null
journalctl -b | grep -i sof        # check SOF firmware errors
journalctl -b | grep -i audio      # check audio init errors
```

## References

- [Arch Forums: No built-in speaker audio on Meteor Lake](https://bbs.archlinux.org/viewtopic.php?id=303130)
- [Arch Forums: linux-6.16+ breaks audio on Meteor Lake](https://bbs.archlinux.org/viewtopic.php?id=307728)
- [ArchWiki: Advanced Linux Sound Architecture](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture)
