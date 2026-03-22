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
  > Bus 52 decimal = 0x34 hex → BusID "PCI:82:0:0" — verify after reboot

### Drivers

- [x] Install Nvidia drivers:
  ```
  sudo pacman -S nvidia-dkms nvidia-utils nvidia-prime
  ```
  > `lib32-nvidia-utils` skipped — multilib repo not enabled. Only needed for 32-bit apps (Steam/Wine).
  > **Use `nvidia-dkms` (proprietary), NOT `nvidia-open-dkms`.** GTX 1080 Ti is Pascal (GP102) — open-source nvidia modules only support Turing (RTX 20xx / GTX 16xx) and newer. Using open modules causes probe failure: "does not include the required GPU".
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

- [x] Add to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`:
  ```
  pcie_ports=native pci=assign-busses,hpbussize=0x33,realloc,hpmmiosize=128M,hpmmioprefsize=16G pcie_aspm=off
  ```
  > `nvidia-drm.modeset=1` and `nvidia_drm.fbdev=1` are enabled by default in current nvidia-utils — no need to set manually. Verify after install: `cat /sys/module/nvidia_drm/parameters/modeset` and `fbdev` should return `Y`.
  > `hpmmioprefsize=16G` — if eGPU fails to initialize or system is unstable, reduce to `512M`.

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

- [ ] Reboot with eGPU connected
- [ ] Check eGPU detected: `lspci | grep -i nvidia`
- [ ] Check driver loaded: `lsmod | grep nvidia`
- [ ] Check CUDA/compute: `nvidia-smi`
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
