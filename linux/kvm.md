# KVM / QEMU

Tags: #kvm #qemu #virtualization #windows

See [[p14s]] for architecture overview.

## Architecture

```
Arch Linux (host)
├── KVM/QEMU Windows VM
│   ├── Visual Studio (multiple versions)
│   ├── Teams + Outlook
│   └── SSMS → connects to SQL Server via 192.168.122.1
└── /vm partition (xfs, 923GB)
    ├── windows.qcow2
    └── sqldata/        ← shared with Docker SQL Server
```

SQL Server runs in Docker on the host — Windows VM connects via `192.168.122.1`. See [[docker]].

## Storage

| Path | Type | Purpose |
|------|------|---------|
| `/vm/windows.qcow2` | qcow2 | Windows VM image |
| `/vm/sqldata/` | directory | SQL Server .mdf/.ldf files |

## Install

```bash
sudo pacman -S qemu-full virt-manager libvirt dnsmasq swtpm
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $USER
```

VirtIO drivers ISO (for better disk/network performance):
```bash
yay -S virtio-win
# ISO at: /var/lib/libvirt/images/virtio-win.iso
```

## VM Configuration

- Firmware: UEFI (not BIOS) — required for Windows 11
- Chipset: Q35
- TPM: Emulated, TIS, version 2.0 (requires `swtpm`)
- CPU: host-passthrough, 1 socket, 6 cores, 2 threads
- NIC: virtio (better performance than e1000e)
- Add VirtIO ISO as second CDROM for driver install

## Create VM Disk

```bash
qemu-img create -f qcow2 /vm/windows.qcow2 250G
```

Resize later if needed (VM must be shut down):
```bash
qemu-img resize /vm/windows.qcow2 +50G
# Then extend partition inside Windows via Disk Management
```

## Windows 11 Install — Bypass Requirements

Windows 11 checks for TPM/Secure Boot during install. Bypass before selecting Windows version:

Press **Shift+F10** at the first installer screen to open a command prompt, then:

```cmd
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f
reg add HKLM\SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f
```

Close prompt, then proceed with selecting Windows version.

## Manage VMs

```bash
# List VMs
virsh list --all

# Start VM
virsh start <name>

# Stop VM
virsh shutdown <name>

# Force stop
virsh destroy <name>

# Autostart on boot
virsh autostart <name>
```

## Networking

Default NAT network: `192.168.122.0/24`
Host accessible from VM at: `192.168.122.1`

```bash
# Check network
virsh net-list --all
virsh net-start default
virsh net-autostart default
```

## File Sharing (Samba)

Host shares `/home/me/shared` via Samba. Access from Windows VM:

```
\\192.168.122.1\shared
```

Credentials: username `me`, Samba password (set with `sudo smbpasswd -a me`).

Samba config: `/etc/samba/smb.conf`

```bash
sudo systemctl enable --now smb nmb
```

Note: virtiofs (alternative) requires shared memory which breaks host hibernation — Samba is preferred.

## TODO

- [ ] Create Windows VM (qcow2 on /vm)
- [x] Install Visual Studio
- [ ] Install Teams + Outlook
- [x] Install SSMS
- [x] Verify SSMS → SQL Server connection via 192.168.122.1

## Related

- [[p14s]] - system architecture
- [[docker]] - SQL Server on host
