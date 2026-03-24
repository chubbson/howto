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
- [ ] Check current security level from Linux: `cat /sys/bus/thunderbolt/devices/domain0/security`

### Connect & Authorize

- [x] Plug in eGPU enclosure via Thunderbolt
- [x] Authorize Thunderbolt device: `boltctl list` → `boltctl authorize <uuid>`
  > Razer Core X V2 — uuid: 8ab48780-00c5-3daa-ffff-ffffffffffff, authorized automatically, policy: iommu, 40 Gb/s both directions
- [x] Verify eGPU visible: `lspci | grep -i nvidia`
  > `52:00.0 VGA compatible controller: NVIDIA Corporation GP102 [GeForce GTX 1080 Ti]`
- [ ] Note BusID from `lspci` output (convert hex → decimal for Xorg config)
  > After reboot: `6a:00.0` → 0x6a = 106 decimal → BusID "PCI:106:0:0"

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
- [ ] Verify: `nvidia-smi`

### Initramfs

- [ ] Add `thunderbolt` to `MODULES` in `/etc/mkinitcpio.conf`:
  ```
  MODULES=(... thunderbolt)
  ```
- [ ] Regenerate initramfs:
  ```
  sudo mkinitcpio -P
  ```
  > Only needed if eGPU is not detected on cold boot. Not required when root is on NVMe — thunderbolt module loads fine without early initramfs inclusion. Skip and add only if boot detection issues appear.

### Kernel Parameters

> **Note:** `pcie_ports=native` dropped — caused display flickering and cursor jumping on the Intel Arc 140V iGPU (takes PCIe management away from firmware, disrupting the Arc display link). Do not re-add.

Current active cmdline: `loglevel=3 quiet pcie_aspm=off xe.enable_psr=0 pci=assign-busses,realloc nvidia-drm.modeset=1 iommu=pt`

- [ ] **Cleanup** — Check if `xe.enable_psr=0` can be removed once eGPU is stable
  > PSR (Panel Self Refresh) was disabled to work around Arc iGPU display issues. May no longer be needed — test by removing it and checking for flickering/cursor issues on internal display. Unrelated to eGPU but lives in the same cmdline.

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
  ```
  GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet pcie_aspm=off xe.enable_psr=0 pci=assign-busses,realloc nvidia-drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0"
  ```
  > This matches the working machine config (minus `nvidia_drm.fbdev=1` which causes "Flip event timeout" on drivers 545+).
  > Result: `nvidia-smi` still "No devices were found". dmesg showed `RmInitAdapter failed! (0x22:0x56:897)` — driver detects GPU on PCIe bus, BARs assigned, but IOMMU (force-enabled by platform) blocks nvidia's DMA init.

- [x] **Step 4** — Add `iommu=pt`
  > IOMMU passthrough mode. `dmesg` showed `DMAR: Intel-IOMMU force enabled due to platform opt in` and repeated `RmInitAdapter failed (0x22:0x56:897)`. The strict IOMMU DMA translation was blocking nvidia's adapter init. `iommu=pt` disables strict translation, allowing the driver to initialize.
  ```
  GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet pcie_aspm=off xe.enable_psr=0 pci=assign-busses,realloc nvidia-drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0 iommu=pt"
  ```
  > Result: IOMMU error gone from dmesg, but `RmInitAdapter failed! (0x22:0x56:897)` persists. IOMMU was not the root cause (or not the only one). BARs are properly allocated (Region 1: 256M prefetchable at 0x4010000000, Region 3: 32M prefetchable). PCIe link running at 2.5 GT/s x4 (Gen1) via TB4 root port 00:07.2. `/usr/lib/firmware/nvidia/gp102/` exists — 580.x ships GSP firmware for Pascal.

- [ ] **Step 5** — Remove `nvidia.NVreg_EnableGpuFirmware=0`
  > 580.x driver ships GSP firmware for gp102 (GTX 1080 Ti). Setting `NVreg_EnableGpuFirmware=0` may be blocking firmware that 580.x now requires for Pascal. Try with GSP enabled.
  ```
  GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet pcie_aspm=off xe.enable_psr=0 pci=assign-busses,realloc nvidia-drm.modeset=1 iommu=pt"
  ```
  After reboot: `nvidia-smi` and `sudo dmesg | grep -iE "nvrm|gsp|firmware"`

- [x] Create `/etc/modprobe.d/nvidia.conf` for suspend/hibernate stability:
  ```
  options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
  ```
  > `NVreg_EnableGpuFirmware=0` only needed if you experience GSP-related issues — GTX 1070 doesn't use GSP anyway.

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

- [ ] Create `/etc/environment.d/50_mesa.conf`:
  ```
  __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json
  ```

### PRIME Offload (iGPU primary, eGPU on demand)

- [ ] Create `/etc/X11/xorg.conf.d/80-igpu-primary-egpu-offload.conf`:
  ```
  Section "Device"
      Identifier "Device0"
      Driver     "modesetting"
  EndSection

  Section "Device"
      Identifier "Device1"
      Driver     "nvidia"
      BusID      "PCI:<decimal-bus-id>"
      Option     "AllowExternalGpus" "True"
  EndSection
  ```
  > BusID: convert hex from `lspci` to decimal (e.g. `1a:10.3` → `26:16:3`)

- [ ] To run a program on eGPU:
  ```
  prime-run <program>
  # or
  __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia <program>
  ```

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
- [ ] Check device nodes exist: `ls /dev/nvidia*`
- [ ] Check CUDA/compute: `nvidia-smi`
  > Currently fails: "No devices were found" — driver loads but GPU not initialized. Working through kernel param steps above.
- [ ] Test PRIME offload: `prime-run glxinfo | grep renderer`
- [ ] Test external monitor (connect to eGPU enclosure display output)

## Notes

- Hotplug into a running Wayland/GNOME session should work via module reload (see workflow below)
- Hot-unplug requires unloading nvidia modules first — do not disconnect without doing so
- Thunderbolt bandwidth limits PCIe lanes — expect some performance overhead vs native PCIe
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
