# eGPU Setup — GTX 1070 via Thunderbolt

Tags: #egpu #nvidia #thunderbolt #gpu

Hardware: Lenovo P14s Gen 5 (TB4) + GTX 1070 in Razer Core X V2 enclosure (TB5, backward compatible with TB4)
Use case: gaming, CUDA, external monitor (GNOME + Wayland)

See [[p14s]] for system overview.

## Checklist

### BIOS (before first plug-in)

- [ ] Boot into BIOS → Security → Thunderbolt
- [ ] Set **Thunderbolt Security Level** to `secure` ("One time saved key") — authorized once, then remembered
  > ArchWiki recommends minimum `secure`. `none`/Legacy mode is a DMA attack risk.
- [ ] Set **Thunderbolt BIOS Assist Mode** to `Disabled` — let Linux/kernel manage it
- [ ] Check current security level from Linux: `cat /sys/bus/thunderbolt/devices/domain0/security`

### Connect & Authorize

- [ ] Plug in eGPU enclosure via Thunderbolt
- [ ] Authorize Thunderbolt device: `boltctl list` → `boltctl authorize <uuid>`
- [ ] Verify eGPU visible: `lspci | grep -i nvidia`
- [ ] Note BusID from `lspci` output (convert hex → decimal for Xorg config)

### Drivers

- [ ] Install Nvidia drivers:
  ```
  sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-prime
  ```
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

### Kernel Parameters

- [ ] Add to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`:
  ```
  pcie_ports=native pci=assign-busses,hpbussize=0x33,realloc,hpmmiosize=128M,hpmmioprefsize=16G pcie_aspm=off
  ```
  > `nvidia-drm.modeset=1` and `nvidia_drm.fbdev=1` are enabled by default in current nvidia-utils — no need to set manually. Verify after install: `cat /sys/module/nvidia_drm/parameters/modeset` and `fbdev` should return `Y`.

- [ ] Create `/etc/modprobe.d/nvidia.conf` for suspend/hibernate stability:
  ```
  options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
  ```
  > `NVreg_EnableGpuFirmware=0` only needed if you experience GSP-related issues — GTX 1070 doesn't use GSP anyway.

- [ ] Enable Nvidia suspend/hibernate services:
  ```
  sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
  ```

- [ ] Regenerate GRUB config:
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
