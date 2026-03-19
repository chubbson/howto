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
sudo pacman -S qemu-full virt-manager libvirt dnsmasq
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $USER
```

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

## TODO

- [ ] Create Windows VM (qcow2 on /vm)
- [ ] Install Visual Studio
- [ ] Install Teams + Outlook
- [ ] Install SSMS
- [ ] Verify SSMS → SQL Server connection via 192.168.122.1

## Related

- [[p14s]] - system architecture
- [[docker]] - SQL Server on host
