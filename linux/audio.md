# Audio: Intel Meteor Lake

Tags: #audio #hardware #troubleshooting

## Problem

Intel Meteor Lake-P HD Audio Controller shows only "Dummy Output" in PipeWire. Kernel sees no sound cards (`/proc/asound/cards` empty).

## Root Cause

**Missing SOF firmware** — Meteor Lake DSP requires firmware binaries (`sof-firmware`) and UCM profiles (`alsa-ucm-conf`) to initialize. Without them, the driver loads but no sound card is registered.

Confirmed via journalctl:
```
SOF firmware and/or topology file not found.
 Firmware file: intel/sof-ipc4/mtl/sof-mtl.ri
 Topology file: intel/sof-ipc4-tplg/sof-hda-generic-2ch.tplg
error: sof_probe_work failed err: -2
```

Note: A kernel 6.16 regression affecting Meteor Lake SOF init was reported (Arch Forums) but is **patched and merged upstream** — not a concern on 6.19+.

## Fix

```bash
sudo pacman -S sof-firmware alsa-ucm-conf
```

Then reboot.

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
