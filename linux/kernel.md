# Linux Kernel

## Current Version

**7.0.9-arch1-1** (updated 2026-05-21, upgraded from 7.0.5)

## Linux 7.0 Major Release Highlights

Source: [kernelnewbies.org/Linux_7.0](https://kernelnewbies.org/Linux_7.0)

### Performance
- Swap subsystem rewrite (~20% speedup in Redis benchmarks)
- Faster PID allocation (10–16% less lock contention on thread create/teardown)
- `close_range()` complexity improved from O(range) to O(active FDs)
- New sheaf-based slab allocator replaces partial-slab management
- `kmalloc_obj()` family adds type-safe kernel allocations

### Filesystems
- **BTRFS**: experimental logical remapping tree for better I/O reliability
- **XFS**: live self-healing via filesystem health event delivery to userspace
- **NTFS3**: delayed-allocation support
- **NFS**: v4.2 POSIX ACL support added

### Networking
- AccECN (Accurate ECN) enabled by default — richer TCP congestion signals per RTT

### Security
- ML-DSA X.509 signature support
- SHA-1 module signing removed
- Clang static analysis for lock/context correctness at compile time
- io_uring per-task cBPF filtering for opcode restrictions

### Scheduler
- `rseq` time-slice extension to protect userspace critical sections from preemption
- Preemption models collapsed to two (full and lazy) on modern architectures
- Classic voluntary preemption model removed

### Storage / Drivers
- UBLK: batch I/O and integrity data support
- zram: compressed data writeback
- Expanded zoned storage GC capabilities

### Removals
- "Laptop mode" removed
- Legacy `linuxrc`-based initrd support partially removed

## Patch History (7.0.x)

Changelogs: [7.0.6](https://cdn.kernel.org/pub/linux/kernel/v7.x/ChangeLog-7.0.6) · [7.0.7](https://cdn.kernel.org/pub/linux/kernel/v7.x/ChangeLog-7.0.7) · [7.0.8](https://cdn.kernel.org/pub/linux/kernel/v7.x/ChangeLog-7.0.8) · [7.0.9](https://cdn.kernel.org/pub/linux/kernel/v7.x/ChangeLog-7.0.9)

### 7.0.6
- Networking: rxrpc packet unsharing fix

### 7.0.7
- Security: ksmbd ACE SID validation (OOB read in SMB); RDMA/rxe rejects unknown opcodes; HMAC key no longer leaked in crypto/caam logs
- AMD CPU/Zen2: prevent improper resource isolation in operation cache
- f2fs: multiple fixes (fsync, inline data, extent node race, FIEMAP boundary)
- MPTCP: ADD_ADDR retransmission, subflow socket options, fastclose with SO_LINGER
- BPF arena: fix use-after-free on fork (VMAs marked `VM_DONTCOPY`)
- mmc: Kingston/Sandisk eMMC quirks; MDT date fix for post-2025 dates

### 7.0.8
- Security: ptrace — accessing kernel threads now requires `CAP_SYS_PTRACE` (Qualys advisory)

### 7.0.9
- Security: AMD GPU/AMDKFD bounds checking; VRAM zeroed on allocation; DRM/XE rejects unsafe PAT indices
- SCTP: use-after-free in SCTP_SENDALL during association peel-off
- Vsock: accept queue leak, non-linear buffer handling
- AMDGPU: GART table zero-initialized; KIQ ring sync guarded during GPU reset
- DRM/AMD Display: reverted dither policy change for 10bpc (restores color precision)
- Cgroup: deferred CSS percpu_ref kill to prevent A-A deadlock during pidns teardown
