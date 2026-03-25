# /etc/modprobe.d/nvidia.conf Options

Reference for NVIDIA modprobe options. Current config lives at `/etc/modprobe.d/nvidia.conf`.

## Active Config (P14s eGPU setup)

```
softdep nvidia pre: thunderbolt

options nvidia \
  NVreg_PreserveVideoMemoryAllocations=1 \
  NVreg_TemporaryFilePath=/var/tmp \
  NVreg_UsePageAttributeTable=1 \
  NVreg_EnableGpuFirmware=0 \
  NVreg_EnablePCIeGen3=3
```

---

## Option Reference

### `softdep nvidia pre: thunderbolt`

Ensures the `thunderbolt` kernel module is loaded before `nvidia`. Required for eGPU over Thunderbolt so the PCIe device is visible when the nvidia driver initializes.

Also add `thunderbolt` to `MODULES=()` in `/etc/mkinitcpio.conf` and run `mkinitcpio -P`.

---

### `NVreg_EnableGpuFirmware=0`

Disables GSP (GPU System Processor) firmware, forcing legacy CPU-driven GPU initialization.

- **Default:** `1` (enabled) on supported GPUs
- **When to use:** Pascal (GTX 10xx / GP1xx) over Thunderbolt PCIe with driver 520+. The 580.x driver has a silent GSP init failure for Pascal eGPUs (`RmInitAdapter failed! 0x22:0x56:897`). Setting this to `0` bypasses GSP entirely.
- **Note:** GSP is only available on Turing (RTX 20xx) and newer. Disabling it on Pascal has no downside.

---

### `NVreg_EnablePCIeGen3`

Controls PCIe generation negotiation.

| Value | Behavior |
|-------|----------|
| `0` | Force Gen 2 |
| `1` | Enable Gen 3 if driver considers it safe (default) |
| `2` | Same as `1` (legacy) |
| `3` | Force Gen 3 even if driver flags system as potentially unstable |

- **When to use:** eGPU over Thunderbolt often negotiates at PCIe Gen 1 (2.5 GT/s) when the driver hasn't fully initialized. Setting `3` forces Gen 3 (8 GT/s x4 ≈ 32 Gb/s), which is the expected TB4 speed.

---

### `NVreg_UsePageAttributeTable=1`

Enables Page Attribute Table (PAT) for improved CPU memory management performance.

- **Default:** `0`
- Generally safe to enable on modern x86_64 systems.

---

### `NVreg_PreserveVideoMemoryAllocations=1`

Preserves VRAM contents across suspend/resume cycles.

- **Default:** `0`
- Required for proper suspend/hibernate with nvidia. Pairs with `nvidia-suspend.service`, `nvidia-resume.service`, `nvidia-hibernate.service`.

---

### `NVreg_InitializeSystemMemoryAllocations=0`

Disables zeroing of system memory before GPU use (minor performance gain, minor security tradeoff).

- **Default:** `1`
- Recommended for KDE 6 + Wayland to prevent black screens or freezes on resume.

---

### `NVreg_DynamicPowerManagement=0x02`

Enables fine-grained runtime power management (RTD3).

| Value | Behavior |
|-------|----------|
| `0x00` | Disabled |
| `0x01` | Coarse: power down only when no nvidia apps running |
| `0x02` | Fine: actively power down when GPU is idle |

- See also: `/lib/udev/rules.d/80-nvidia-pm.rules`

---

### `NVreg_RegistryDwords`

Internal driver registry overrides, comma-separated key=value pairs.

```
options nvidia NVreg_RegistryDwords="RMIntrLockingMode=1;"
```

**`RMIntrLockingMode=1`** — Experimental. Improves frame pacing in PRIME configs, especially at high refresh rates (144Hz+). Reduces interrupt-induced frame timing jitter.

---

### `NVreg_EnableResizableBar`

Enables Resizable BAR (ReBAR) support. Allows CPU to access full VRAM instead of a 256MB window.

- Requires BIOS support. Check `lspci -v` for `Resizable BARs` capability.

---

### `options nvidia_drm modeset=1`

Enables kernel modesetting for `nvidia_drm`. **Required** for Wayland and PRIME offload.

Can also be set via kernel parameter: `nvidia-drm.modeset=1` in GRUB cmdline.

---

## Useful Diagnostics

```bash
cat /proc/driver/nvidia/params          # all active driver params
cat /proc/driver/nvidia/version         # driver version
cat /proc/driver/nvidia/gpus/*/information
modinfo nvidia nvidia_drm nvidia_modeset
```

## References

- [Arch Wiki: NVIDIA](https://wiki.archlinux.org/title/NVIDIA)
- [Arch Wiki: External GPU](https://wiki.archlinux.org/title/External_GPU)
- [NVIDIA GSP docs](https://download.nvidia.com/XFree86/Linux-x86_64/570.144/README/gsp.html)
- [NVIDIA dynamic power management](https://download.nvidia.com/XFree86/Linux-x86_64/570.144/README/dynamicpowermanagement.html)
- [nvrm_registry.h](https://github.com/NVIDIA/open-gpu-kernel-modules/blob/main/src/nvidia/interface/nvrm_registry.h)
- [Gist: nvidia.conf reference](https://gist.github.com/denji/52b9b0980ef3dadde0ff3d3ccf74a2a6)
