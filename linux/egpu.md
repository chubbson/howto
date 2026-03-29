# eGPU Setup — GTX 1080 Ti via Thunderbolt

Tags: #egpu #nvidia #thunderbolt #gpu

Hardware: Lenovo P14s Gen 5 (TB4) + GTX 1080 Ti (11GB) in Razer Core X V2 enclosure (TB5, backward compatible with TB4)
Use case: gaming, CUDA, external monitor (GNOME + Wayland)

See [[p14s]] for system overview.

## Checklist

### BIOS (before first plug-in)

- [x] Boot into BIOS → Security → Thunderbolt
  > P14s Gen 5: option names differ from ArchWiki. Found a Thunderbolt enable/disable toggle and a second option (name TBD) recommended to enable to avoid eGPU connection problems — enable it.
  > The exact labels "Thunderbolt Security Level" and "Thunderbolt BIOS Assist Mode" were NOT present — update this note with actual names when revisiting BIOS.
- [x] Check current security level from Linux: `cat /sys/bus/thunderbolt/devices/domain0/security`
  > `user` — devices require explicit authorization via `boltctl`. Razer Core X V2 is enrolled and auto-authorized.

### Connect & Authorize

- [x] Plug in eGPU enclosure via Thunderbolt
- [x] Authorize Thunderbolt device: `boltctl list` → `boltctl authorize <uuid>`
  > Razer Core X V2 — uuid: 8ab48780-00c5-3daa-ffff-ffffffffffff, authorized automatically, policy: iommu, 40 Gb/s both directions
- [x] Verify eGPU visible: `lspci | grep -i nvidia`
  > `52:00.0 VGA compatible controller: NVIDIA Corporation GP102 [GeForce GTX 1080 Ti]`
- [x] Note BusID from `lspci` output (convert hex → decimal for Xorg config)
  > After reboot: `37:00.0` → 0x37 = 55 decimal → BusID "PCI:55:0:0"

### Drivers

- [x] Install Nvidia drivers:
  ```
  yay -S nvidia-580xx-dkms
  sudo pacman -S nvidia-prime
  ```
  > **GTX 1080 Ti is Pascal (GP102) — requires proprietary driver from AUR.**
  > - `nvidia-open-dkms` (official repos, 590+): open-source, does NOT support Pascal → probe failure
  > - `nvidia-dkms` / `nvidia` (official repos): Arch dropped proprietary packages from official repos for 590+
  > - `nvidia-580xx-dkms` (AUR): proprietary, covers Maxwell/Pascal/Volta — **correct choice**
  > - `nvidia-470xx-dkms` (AUR): last driver series to support Kepler, but ALSO supports Maxwell/Pascal/Volta/Turing. No GSP firmware. Useful fallback if newer driver fails on Pascal eGPU.
  > `yay -S nvidia-580xx-dkms` also installs `nvidia-580xx-utils` (replaces `nvidia-utils`) and `dkms`.
  > `lib32-nvidia-utils` skipped — multilib repo not enabled. Only needed for 32-bit apps (Steam/Wine).
  > Kernel headers (`linux-headers`) were missing initially, installed separately.
- [x] Verify: `nvidia-smi`
  > GTX 1080 Ti, driver 580.142, CUDA 13.0 ✓

### Initramfs

- [x] Add `thunderbolt` to `MODULES` in `/etc/mkinitcpio.conf`:
  ```
  MODULES=(thunderbolt)
  ```
- [x] Regenerate initramfs:
  ```
  sudo mkinitcpio -P
  ```
  > Ensures thunderbolt module is available early in boot before nvidia driver initializes.

### Kernel Parameters

> **Note:** `pcie_ports=native` dropped — caused display flickering and cursor jumping on the Intel Arc 140V iGPU (takes PCIe management away from firmware, disrupting the Arc display link). Do not re-add.

Current active cmdline: `loglevel=3 quiet pci=assign-busses,hpbussize=0x33,realloc,hpmmiosize=128M,hpmmioprefsize=16G`

- [x] **Cleanup** — `xe.enable_psr=0` removed — no flickering observed, internal display stable without it.

#### Step-by-step debug (add one at a time, reboot, test `nvidia-smi` each time)

- [x] **Step 1** — Add `pci=assign-busses,realloc`
  > Ensures PCI resources/BARs are properly allocated for the eGPU. ArchWiki recommends this for Thunderbolt hotplug.
  ```
  sudo sed -i 's/xe.enable_psr=0"/xe.enable_psr=0 pci=assign-busses,realloc"/' /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  ```
  After reboot: `nvidia-smi` and `ls /dev/nvidia*`

- [x] **Step 2** — Add `nvidia-drm.modeset=1`
  > Enables KMS for nvidia-drm. Required for Wayland. Likely needed even if default is Y — explicit param ensures it's set before driver init.
  ```
  GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet pcie_aspm=off xe.enable_psr=0 pci=assign-busses,realloc nvidia-drm.modeset=1"
  ```

- [x] **Step 3** — Add `nvidia.NVreg_EnableGpuFirmware=0`
  > Disables GSP firmware. GTX 1080 Ti (Pascal/GP102) doesn't support GSP — newer drivers (560+) enable it by default and it can cause init failure on older eGPUs.
  > Result: `nvidia-smi` still "No devices were found". dmesg showed `RmInitAdapter failed! (0x22:0x56:897)` — driver detects GPU on PCIe bus, BARs assigned, but IOMMU (force-enabled by platform) blocks nvidia's DMA init.

- [x] **Step 4** — Add `iommu=pt`
  > IOMMU passthrough mode. `dmesg` showed `DMAR: Intel-IOMMU force enabled due to platform opt in` and repeated `RmInitAdapter failed (0x22:0x56:897)`.
  > Result: IOMMU error gone from dmesg, but `RmInitAdapter failed! (0x22:0x56:897)` persists. PCIe link running at 2.5 GT/s x4 (Gen1). `/usr/lib/firmware/nvidia/gp102/` exists — 580.x ships GSP firmware for Pascal.

- [x] **Step 5** — Remove `nvidia.NVreg_EnableGpuFirmware=0` from cmdline
  > Result: **Still fails.** 580.x makes no GSP attempt before `RmInitAdapter failed!`. Kernel cmdline approach exhausted — moved fix to modprobe.d and expanded pci= params.

- [x] **Step 6** — Fix via modprobe.d + extended pci= params  *(supersedes 470xx fallback plan)*
  > `NVreg_EnableGpuFirmware=0` in modprobe.d (not kernel cmdline) + switching pci= params to `hpbussize=0x33,hpmmiosize=128M,hpmmioprefsize=16G` finally initialized the adapter.
  > Final working cmdline: `loglevel=3 quiet pci=assign-busses,hpbussize=0x33,realloc,hpmmiosize=128M,hpmmioprefsize=16G`
  > See modprobe.d section below. **`nvidia-smi` works.** ✓
  > ~~Switch to nvidia-470xx-dkms~~ — not needed, 580xx works.

- [x] Create `/etc/modprobe.d/nvidia.conf`:
  ```
  softdep nvidia pre: thunderbolt

  options nvidia \
    NVreg_PreserveVideoMemoryAllocations=1 \
    NVreg_TemporaryFilePath=/var/tmp \
    NVreg_UsePageAttributeTable=1 \
    NVreg_EnableGpuFirmware=0

  # NVreg_EnablePCIeGen3=3
  ```
  > `NVreg_EnableGpuFirmware=0` — disables GSP firmware; 580.x has silent GSP init failure for Pascal (GP102) over Thunderbolt. **This was the key fix.**
  > `NVreg_EnablePCIeGen3=3` — not needed. The `2.5 GT/s Gen1 x4` reported by `lspci` is a virtual PCIe link advertised by the Thunderbolt controller — it does not reflect actual bandwidth. Real throughput is determined by the TB link itself (TB4 = 40 Gb/s bidirectional, confirmed via `/sys/bus/thunderbolt/devices/0-1/rx_speed`).
  > `softdep nvidia pre: thunderbolt` — ensures thunderbolt module loads before nvidia.
  > See [[modprobe.d-nvidia]] for full option reference.

- [x] ~~**Pending** — Enable `NVreg_EnablePCIeGen3=3`~~ — **not needed.** The `2.5 GT/s` PCIe link is a Thunderbolt virtual PCIe topology artifact; actual bandwidth is full TB4 (40 Gb/s). See modprobe.d note above.

- [x] Enable Nvidia suspend/hibernate services:
  ```
  sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
  ```
  > nvidia-resume was auto-enabled by nvidia-utils install. All three confirmed enabled.

- [x] Regenerate GRUB config:
  ```
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  ```

### Wayland Hotplug

- [x] ~~Create `/etc/environment.d/50_mesa.conf`~~ — **not needed.** Hotplug tested without it: GPU disappears cleanly on unplug, comes back automatically on replug (`nvidia-smi` recovers, no crashes). The nvidia udev rule (`60-nvidia.rules`) handles device node recreation on plug-in.

### GPU Priority (Wayland/GNOME): Arc as primary, NVIDIA on demand

**Problem:** NVIDIA eGPU gets `card0` (DRM primary) because its driver registers before `i915`. GNOME/Mutter defaults to card0, so everything runs on NVIDIA — wasting power at idle.

**Goal:** Arc handles compositing/desktop; NVIDIA only activates for specific apps (games).

#### Step 1 — Tell GNOME to use Arc's render node

- [ ] Add to `/etc/environment`:
  ```
  MUTTER_DEBUG_NUM_DUMMY_MODS=0
  ```
  > Actually use: check which env var your Mutter version supports. The render node approach:
  ```
  # /etc/environment
  GNOME_MUTTER_RENDERNODE=/dev/dri/renderD128
  ```
  > `renderD128` = Arc (`00:02.0`), `renderD129` = NVIDIA (`37:00.0`). Verify with:
  ```
  ls -la /dev/dri/by-path/
  ```
- [ ] Reboot and verify in nvtop: Arc (dev 0) should show compositor activity, NVIDIA (dev 1) should idle at ~0%

#### Step 2 — Run a game on eGPU via Steam

- [ ] In Steam → game Properties → **Launch Options**:
  ```
  __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only %command%
  ```
  > `__GLX_VENDOR_LIBRARY_NAME=nvidia` — for OpenGL games
  > `__VK_LAYER_NV_optimus=NVIDIA_only` — for Vulkan games
  > Both can coexist in the same launch option string

- [ ] Verify game is running on NVIDIA: check nvtop while game is running — NVIDIA GPU utilization should spike

#### Prerequisites

- [ ] `nvidia-drm.modeset=1` must be in kernel params (currently missing from cmdline):
  ```
  # /etc/default/grub
  GRUB_CMDLINE_LINUX_DEFAULT="... nvidia-drm.modeset=1"
  ```
  ```
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  ```
  > Required for PRIME render offload to work on Wayland

### PRIME Offload (run any program on eGPU)

- [ ] To run a program on eGPU:
  ```
  prime-run <program>
  # or manually:
  __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia <program>
  ```

#### Identifying GPUs

**Wayland** uses DRM device nodes (`/dev/dri/card*`). Map PCI address to node:
```
ls -la /dev/dri/by-path/
```
> e.g. `pci-0000:37:00.0-card → ../card0` (NVIDIA), `pci-0000:00:02.0-card → ../card1` (Arc)

**Xorg** uses BusID in decimal. Convert PCI address hex → decimal:
> `37:00.0` → 0x37 = 55 decimal → BusID `PCI:55:0:0`

### Secure Boot

- [ ] Re-sign kernel/bootloader after driver install:
  ```
  sudo sbctl sign-all
  ```
- [ ] Verify: `sudo sbctl list-files`

### Reboot & Verify

- [x] Reboot with eGPU connected
- [x] Check eGPU detected: `lspci | grep -i nvidia`
  > `52:00.0 VGA compatible controller: NVIDIA Corporation GP102 [GeForce GTX 1080 Ti]` ✓
- [x] Check driver loaded: `lsmod | grep nvidia`
  > `nvidia`, `nvidia_modeset`, `nvidia_drm`, `nvidia_uvm` all loaded ✓
- [x] Check device nodes exist: `ls /dev/nvidia*`
  > `/dev/nvidia0`, `/dev/nvidiactl`, `/dev/nvidia-modeset`, `/dev/nvidia-uvm`, `/dev/nvidia-uvm-tools` ✓
- [x] Check CUDA/compute: `nvidia-smi`
  > GTX 1080 Ti, 580.142, CUDA 13.0, 32°C idle ✓
- [x] Check PCIe link speed:
  ```
  cat /sys/bus/pci/devices/0000:37:00.0/current_link_speed
  cat /sys/bus/pci/devices/0000:37:00.0/current_link_width
  ```
  > Reports `2.5 GT/s` (Gen1) x4 — this is **expected**. Thunderbolt presents a virtual PCIe link at Gen1 speed; actual throughput is the TB link rate.
  > Check real TB bandwidth: `cat /sys/bus/thunderbolt/devices/0-1/rx_speed` → `20.0 Gb/s` (TB4 = 20 rx + 20 tx = 40 Gb/s total) ✓
- [ ] Test PRIME offload: `prime-run glxinfo | grep renderer`
- [ ] Test external monitor (connect to eGPU enclosure display output)

## Notes

- Hotplug into a running Wayland/GNOME session should work via module reload (see workflow below)
- Hot-unplug requires unloading nvidia modules first — do not disconnect without doing so
- Thunderbolt bandwidth limits PCIe lanes — expect some performance overhead vs native PCIe
- `lspci` reports `2.5 GT/s PCIe` (Gen1) x4 for the eGPU — this is a **virtual PCIe link** created by the TB controller and does not reflect real bandwidth. Actual throughput = TB link speed (TB4: 40 Gb/s bidirectional). Check with `cat /sys/bus/thunderbolt/devices/0-1/rx_speed`
- For Wayland hotplugging without reboot, unload/reload nvidia modules:
  ```
  sudo rmmod nvidia_uvm nvidia_drm nvidia_modeset nvidia
  # connect eGPU
  sudo modprobe nvidia-drm
  ```

## Related

- [[p14s]] - system overview
- [[secure-boot]] - sbctl signing
- [[arch]] - kernel parameters
- [[modprobe.d-nvidia]] - nvidia modprobe options reference
