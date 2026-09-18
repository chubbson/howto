# Raspberry Pi 5 + Calyx EBD050 + OpenWRT Home Router

Created: 2026-08-25
Context: Swiss home office setup (Sunrise network)

## Project Goal

Build a 5G-powered home internet router using:

- Raspberry Pi 5 8GB as main processor
- Pimoroni NVMe Base Duo for NVMe SSD boot (250GB+)
- Teltonika Calyx EBD050 5G HAT (full 5G, not RedCap)
- OpenWRT 25.12.5 as operating system
- 4× Teltonika PR1US540 SMA antennas for 5G connectivity
- Sunrise Switzerland as cellular provider (5G SA + RedCap support)

Use case: work from home (RDP 3200×1600, Teams video calls, Slack screen
sharing) + roommate Netflix streaming (4K). Requires low latency and
consistent throughput.

## Hardware Status

### Delivered & installed

| Item | Status | Details |
|---|---|---|
| Raspberry Pi 5 (8GB) | ✅ Received | Pi 5 B, 8GB LPDDR4X |
| Pimoroni NVMe Base Duo | ✅ Received | Supports 2230–2280 SSDs |
| NVMe SSD (250GB+) | ✅ Installed | Kingston NV2 2280 in Slot 0 |
| Teltonika Calyx EBD050 | ✅ Received | Full 5G HAT+ (EBD050) |
| 4× Teltonika PR1US540 antennas | ✅ Received | All cover n78 band (3300–3800 MHz) |
| Official Pi 5 Active Cooler | ✅ Installed | Mounted on Pi 5 CPU (thermal pads + push-pins) |
| Official 27W USB-C PSU | ✅ In use | Switched from laptop USB-C charger (2026-08-25) |
| 16mm GPIO stacking header | ✅ Received | Needed for Calyx HAT + cooler clearance |
| M2.5 standoffs (20–25mm) | ✅ Received | Needed for Calyx mechanical support |
| microSD card (8GB+) | ✅ Received | Used temporarily for EEPROM update |
| Sunrise SIM (nano) | ✅ Received | Data plan activated |
| Ethernet cable | ✅ Available | Laptop ↔ Pi connection established |

### Software environment

| Component | Status | Version |
|---|---|---|
| Raspberry Pi OS | ✅ Used | For EEPROM update only (removed after) |
| OpenWRT | ✅ Running | 25.12.5, r33051-f5dae5ece4 |
| Boot method | ✅ NVMe | `BOOT_ORDER=0xf416` configured in EEPROM |
| Package manager | ⚠️ APK | OpenWRT 25.12.5 switched from opkg → apk |

## What Was Done (Successful)

### Phase 1: Hardware assembly

- Installed NVMe SSD into Pimoroni NVMe Base Duo Slot 0
- Connected PCIe ribbon cable (Pi 5 ↔ NVMe Base Duo)
- Bolted Pi 5 onto NVMe Base Duo using 12mm standoffs + 20mm bolts
- Installed Official Pi 5 Active Cooler on CPU (thermal pads + push-pins)
- Connected Active Cooler fan to Pi 5 JST fan header
- Assembled minimal stack (Pi + NVMe Base)

### Phase 2: EEPROM configuration

- Updated EEPROM firmware to "latest" branch (May 2026)
- Set boot order: `BOOT_ORDER=0xf416` (NVMe → SD → USB)
- Fixed NVMe power-saving issue by adding to `/boot/firmware/cmdline.txt`:

  ```
  nvme_core.default_ps_max_latency_us=0 pcie_aspm=off pcie_port_pm=off
  ```

### Phase 3: NVMe boot verification

- Verified NVMe detection via `lsblk` (shows 232.9GB)
- Downloaded OpenWRT 25.12.5 image to Pi via SSH
- Flashed OpenWRT to NVMe using `dd`
- Removed microSD card
- Booted OpenWRT from NVMe successfully
- Confirmed `/` mounted on `/dev/nvme0n1p2` via `df -h`

### Phase 4: Basic OpenWRT access

- Connected via SSH to 192.168.1.1 (default LAN IP)
- Set root password
- Identified package manager change (opkg → apk)

### Phase 5: Calyx HAT mounted, 5G cellular internet working (2026-08-25)

- Mounted the Calyx HAT (16mm GPIO stacking header + M2.5 standoffs),
  connected all 4× Teltonika PR1US540 antennas, inserted the Sunrise
  nano-SIM (moved over from the Zyxel NR2101 mobile router, which was
  being retired from the internet-gateway role as part of this
  project — expected to lose its own internet temporarily).
- Modem (Quectel RG520N-EB) enumerated on USB but **did not
  auto-bind** to `qmi_wwan`/`option` — see "Calyx modem USB driver
  not binding" below for the root cause and fix.
- Installed: `luci-proto-modemmanager kmod-usb-serial kmod-usb-net
  kmod-usb-serial-wwan kmod-usb-serial-option kmod-usb-net-qmi-wwan
  kmod-usb-net-cdc-mbim` (on top of the `kmod-usb-net-qmi-wwan uqmi
  comgt luci-proto-qmi modemmanager` installed earlier). Ended up
  using **ModemManager** (LuCI `Network > Interfaces`, protocol
  `ModemManager`, device "Quectel - RG520N-EB") rather than raw
  `uqmi` — `uqmi` failed with "Failed to connect to service" on every
  `cdc-wdm` device even after the manual driver bind (likely the
  missing `QMI_WWAN_QUIRK_SET_DTR` flag that's normally auto-applied
  for known VID:PIDs — see below), while ModemManager's own modem
  detection worked without issue.
- New interface `mobile` (device `wwan0`), protocol `ModemManager`,
  APN `internet` (Sunrise default), PIN blank, Authentication `none`.
  Came up with a real carrier-assigned IP (`10.128.169.68/29`, CGNAT
  as expected) and immediately started passing real traffic.
- Added `mobile` to the WAN firewall zone (alongside `wan`, `wan6`,
  `wwan`, `phone`) with `masq='1'` — confirmed via `uci show firewall`.
- **Verified end-to-end**: with the laptop's WiFi disabled (so its
  *only* route was Ethernet → Pi), `ping 8.8.8.8` from the laptop
  succeeded (`ip route get 8.8.8.8` confirmed the path went via
  `10.0.0.1 dev enp0s31f6`) — 17–119ms, ~38ms avg. Direct ping from
  the Pi itself via `wwan0` was tighter (16–34ms), matching the doc's
  original 15–30ms 5G SA latency target. **Core project goal (5G
  router providing LAN internet) achieved.**

## Current Blockers / Issues

### Internet access on Pi — RESOLVED (2026-08-25)

- Fixed by configuring the Pi's onboard WiFi (`radio0`/`phy0-sta0`,
  Broadcom/Cypress BCM4345/6 via `brcmfmac`, SDIO) as a client (`wwan`
  network interface, DHCP) joining the home WiFi.
- Gotcha: `radio0` is configured `band='5g'` (5GHz only). The home router's
  base SSID (`Zyxel_57AA`) is 2.4GHz-only; the 5GHz SSID is
  `Zyxel_57AA_5G`. Pointing `wireless.wwan.ssid` at the 2.4GHz SSID caused
  the STA to never associate (driver got stuck retrying background scans —
  looked like a `brcmfmac` "Failed to initiate sched scan" bug, but a raw
  `iw dev phy0-sta0 scan` bypasses the band restriction and can see 2.4GHz
  APs even though the STA never can). Fix: set the STA SSID to the 5GHz
  variant (`Zyxel_57AA_5G`) to match the radio's configured band.
- Also cleared `wireless.wwan.bgscan` (set to empty) as part of the fix,
  though the SSID/band mismatch was the actual root cause.
- `wwan` got a DHCP lease (192.168.225.59/24, gateway 192.168.225.1) and
  internet is confirmed working (ping + DNS resolution).
- `apk update` succeeded — 11,120 packages available across all repos.
- Installed QMI/modem stack:
  `apk add kmod-usb-net-qmi-wwan uqmi comgt luci-proto-qmi modemmanager`
  (18 packages, ~30.8 MiB) — all installed cleanly.

### SSH/LAN unreachable after LAN IP change — RESOLVED (2026-08-25)

- Symptom: SSH to the documented default LAN IP (`192.168.1.1`) stopped
  working. Ethernet link (L1) was always up, but the laptop never got a
  DHCP lease or even a usable on-link IPv6 route on that interface.
  WiFi (`wwan`) showed the Pi with a cached-looking IP but the home
  router's client list reported 0 connected devices at one point.
- Root cause (two separate issues):
  1. The LAN IP had already been changed to `10.0.0.1` (per the
     "recommend changing to 10.0.0.1" note below) but
     `network.lan.netmask` was never set. This OpenWRT/netifd build
     defaults to `/32` (single host) when `netmask` is omitted — unlike
     older opkg-based builds which defaulted to `/24`. A `/32` LAN
     address breaks DHCP/routing for any other device on the segment,
     which is why the Ethernet side never handed out a lease.
  2. Separately, `wwan` (the onboard WiFi uplink) is assigned to
     OpenWRT's WAN firewall zone, which blocks incoming SSH by default
     (`Connection refused`, not a timeout). This is correct/expected
     behavior, not a bug — WiFi `wwan` was never meant to be a
     management path, only an internet uplink.
- Fix: set the missing netmask explicitly and restart networking:
  ```
  uci set network.lan.netmask='255.255.255.0'
  uci commit network
  /etc/init.d/network restart
  ```
  After this, the laptop got a normal DHCP lease (`10.0.0.x/24`) over
  Ethernet and SSH to `10.0.0.1` worked immediately.
- Diagnosis path that got us there: confirmed laptop-side WiFi/internet
  was fine → confirmed physical Ethernet link (`carrier`/`LOWER_UP`) was
  up but no DHCP/RA → power-cycled the Pi → connected HDMI+keyboard
  directly (console access) → `ip a` showed `br-lan` at `10.0.0.1/32` →
  `uci show network` confirmed `network.lan` had no `netmask` key.

### Active Cooler fan not spinning under OpenWRT — RESOLVED (2026-08-25)

- Symptom: official Pi 5 Active Cooler fan ran fine under Raspberry Pi OS
  (SD card) but never spun up after booting OpenWRT from NVMe.
- Diagnosis: fan hardware and driver are fine (`hwmon3` = `pwmfan`,
  `pwm1_enable=1`, forcing `pwm1` manually spins the fan at real RPM via
  `fan1_input`). Root cause: this OpenWRT build's device tree for
  `thermal_zone0` only defines a single `critical` trip point at 110°C —
  none of the intermediate "active" trip points that Raspberry Pi OS's
  downstream DT ships (which ramp the fan starting ~50°C) are present.
  The `pwm-fan` cooling device exists but has no cooling-map driving it at
  normal operating temps, so it silently stays at 0 forever.
- Fix: added a small userspace fan-control loop instead of relying on the
  kernel thermal governor:
  - `/usr/bin/fanctl.sh` — polls `/sys/class/thermal/thermal_zone0/temp`
    every 5s, writes `/sys/class/hwmon/hwmon<N>/pwm1` (found dynamically
    via `grep -l pwmfan /sys/class/hwmon/hwmon*/name`) using a step curve:
    0 below 50°C, 80 at 50–59°C, 150 at 60–69°C, 255 at ≥70°C.
  - `/etc/init.d/fancontrol` — procd service (`START=95`, `USE_PROCD=1`,
    `respawn`) that launches `fanctl.sh` on boot.
  - Enabled + started via `/etc/init.d/fancontrol enable && start`.
- Gotcha while creating these files over SSH: pasting multi-line heredocs
  (`cat > file << 'EOF' ... EOF`) got auto-indented by the terminal,
  which silently broke the OpenWRT init script's special two-argument
  shebang (`#!/bin/sh /etc/rc.common` — the kernel requires `#!` at byte
  0 to invoke the `/etc/rc.common` wrapper that actually calls
  `start_service()`). A leading-space shebang causes `ash` to fall back
  to running the file as a plain script — it defines `start_service` but
  never calls it, so `start` exits 0 with no error and nothing happens.
  Fixed by writing the init script with a single-line `printf '...\n...'
  > file` instead of a multi-line heredoc, avoiding the auto-indent
  entirely. (`fanctl.sh` itself was unaffected by the same indentation
  since it's invoked explicitly as `/bin/sh /usr/bin/fanctl.sh`, not via
  its own shebang.)
- Verified: manually forcing `pwm1` to 200 while below 50°C got reverted
  to 0 within one 5s loop cycle, confirming the control loop is live.

### NVMe boot-time controller drop + root fs corruption — RESOLVED (2026-08-25)

- Symptom: after an earlier abrupt power loss (laptop USB-C charger,
  not the official PSU, in use at the time), every subsequent boot
  crashed at the same kernel timestamp (~34s uptime) with:
  ```
  nvme nvme0: controller is down; will reset: CSTS=0xffffffff, PCI_STATUS=0x10
  nvme nvme0: Does your device have a faulty power saving mode enabled?
  nvme nvme0: Disabling device after reset failure: -19
  EXT4-fs (nvme0n1p2): I/O error while writing superblock
  init: Failed to start preinit: I/O error
  ```
  The NVMe controller dropped off the PCIe bus mid-boot (likely during
  the ext4 journal replay write burst triggered by the earlier unclean
  shutdown), corrupting the root filesystem further on each retry —
  a self-reinforcing loop. Attaching the official 27W PSU (vs. the
  laptop charger, suspected undervoltage) did **not** fix it — same
  crash, same LBA region, same timestamp every time, pointing away
  from pure power delivery and toward the PCIe/NVMe power-saving
  quirk itself.
- Real root cause found via `cat /boot/firmware/cmdline.txt` (read
  through a USB-NVMe enclosure, laptop-side, after booting to OpenWRT
  failsafe mode `[f] + Enter` early in boot): the
  `nvme_core.default_ps_max_latency_us=0 pcie_aspm=off
  pcie_port_pm=off` fix documented in "Phase 2: EEPROM configuration"
  above was **missing** from the live file — almost certainly lost
  when the FAT boot partition (`nvme0n1p1`) was left in the dirty
  "not properly unmounted" state from the same power-loss event.
- Fix (two parts, both needed):
  1. Pulled the NVMe SSD, connected it to the laptop via a USB-NVMe
     enclosure (showed up as `/dev/sdc`, `sdc1`=boot/vfat,
     `sdc2`=rootfs/ext4). Ran `sudo fsck.ext4 -f -y /dev/sdc2` —
     recovered the journal, fixed one inode-bitmap padding issue,
     filesystem marked modified/clean.
  2. Re-added the missing cmdline options to
     `/boot/firmware/cmdline.txt` (edited directly off the enclosure
     mount) — restoring `nvme_core.default_ps_max_latency_us=0
     pcie_aspm=off pcie_port_pm=off` on the same line as the existing
     `console=... root=... rootwait` options (must stay one line).
  3. Unmounted (`umount /run/media/*/boot`), disconnected the
     enclosure, reinstalled the SSD, reseated the PCIe ribbon cable,
     rebooted on the official 27W PSU. Boot completed with no NVMe
     errors; SSH/LAN reachable again immediately after.
- Diagnostic notes for next time:
  - OpenWRT failsafe mode on this (ext4-rootfs, not squashfs+overlay)
    NVMe image still mounts the real root partition directly — you
    **cannot** `fsck` it from within failsafe on the same boot media;
    an external enclosure (or a different boot medium entirely) is
    required.
  - The `FAT-fs (nvme0n1p1): Volume was not properly unmounted...`
    warning on `nvme0n1p1` shows up on effectively every boot log this
    session, including fully successful ones — it's a low-priority
    cosmetic flag on the FAT boot partition, not itself a sign of the
    ext4 root corruption. Don't confuse the two.
  - A crash recurring at the *exact same kernel timestamp* across
    reboots is a strong signal of a deterministic boot-sequence
    trigger (e.g. journal replay, a specific driver probe) rather than
    random power-supply noise — worth checking cmdline/config drift
    before assuming it's purely a power/hardware fault.

### Missing hardware — RESOLVED (2026-08-25)

16mm GPIO stacking header and M2.5 standoffs (20–25mm) now in hand.
Nothing left blocking the Calyx HAT mount.

### Calyx modem (Quectel RG520N-EB) USB driver not binding — RESOLVED, needs persistence follow-up (2026-08-25)

- Symptom: modem enumerated fine on USB (`Manufacturer: Quectel`,
  VID:PID `2c7c:0801`, multiple interfaces incl. one with descriptor
  string `RG520N-EB`), but **no driver bound to any interface** —
  no `/dev/cdc-wdm*`, no `/dev/ttyUSB*`, despite `qmi_wwan` being
  loaded.
- Root cause: `2c7c:0801` isn't in this kernel's built-in
  `qmi_wwan`/`option` device-ID tables — a newer Quectel module ahead
  of the shipped driver's ID list.
- Fix applied (session-only, does **not** survive reboot):
  ```
  echo "2c7c 0801" > /sys/bus/usb/drivers/qmi_wwan/new_id
  ```
  This created `/dev/cdc-wdm0-3` / `wwan0-3` (one per interface —
  this modem exposes multiple QMI functions). Raw `uqmi` against any
  of these still failed with "Failed to connect to service" —
  probably because manually forcing the bind via `new_id` skips the
  `QMI_WWAN_QUIRK_SET_DTR` quirk flag that the driver would normally
  apply automatically for a recognized VID:PID, so the modem never
  actually got its DTR line raised and stayed unresponsive at the
  QMI-service level.
- What actually worked: **ModemManager**, not raw `uqmi`/`qmi` proto.
  Installed `luci-proto-modemmanager` (`modemmanager` +
  `kmod-usb-net-qmi-wwan` already present from earlier). LuCI's
  ModemManager interface page detected "Quectel - RG520N-EB" as a
  selectable modem device without further fuss, and the resulting
  `mobile` interface came up cleanly with a real carrier IP — see
  Phase 5 above.
- **Open follow-up**: the `new_id` bind is not persisted anywhere.
  After a reboot, the modem will very likely go back to not binding
  any driver until the `echo ... > .../qmi_wwan/new_id` command is
  re-run. Needs a boot-time fix — e.g. an `/etc/init.d/` script or
  `/etc/hotplug.d/usb` rule that runs that `echo` early enough for
  ModemManager to then pick up the device. **Not yet done** — verify
  after the next reboot and add the persistence script if the modem
  doesn't come back up on its own.

### Modem now binding via cdc_mbim, not qmi_wwan — earlier persistence concern may be moot (2026-08-26)

- `mmcli -m 0` now reports `drivers: cdc_mbim, option1`, not `qmi_wwan`.
  At some point between the original bring-up and this session, the
  modem started enumerating/binding via **MBIM** instead of the
  manually-forced QMI path (`echo "2c7c 0801" >
  .../qmi_wwan/new_id`) described in "Calyx modem USB driver not
  binding" above.
- Unclear exactly when/why this changed (possibly a reboot re-probed
  the device on `cdc_mbim` first since MBIM was never blocked, or the
  interface descriptor ordering picked a different driver this time).
  Not yet root-caused.
- Practical effect: the modem bound and connected cleanly via
  ModemManager this session with **no manual driver bind needed at
  all** — the earlier "does it survive a reboot" concern about the
  `qmi_wwan new_id` persistence may be moot if MBIM keeps winning.
  **Still needs a real reboot test** to confirm this is reliable and
  not coincidental.

### Signal strength checking via ModemManager (2026-08-26)

- Quick check: `mmcli -m 0` — summary includes `signal quality: N%`
  (often shows `(cached)` and can be stale/misleading, e.g. read `10%`
  and `0%` at different points with no clear pattern) and current
  `access tech`.
- Detailed per-RAT numbers:
  ```
  mmcli -m 0 --signal-setup=5   # poll every 5s
  mmcli -m 0 --signal-get       # read rsrp/s:n per access tech
  ```
  Observed over several reads: LTE RSRP ~-112 to -115 dBm (poor,
  cell-edge), 5G RSRP ~-99 to -104 dBm (poor). **5G S/N was pinned at
  exactly -23.00 dB across every single read (3+ consecutive polls,
  5s apart)** while RSRP drifted normally — strong sign this specific
  field is a stale/placeholder value from ModemManager rather than a
  live measurement, likely because the NR carrier is only a secondary
  EN-DC component (LTE-anchored), not actually decoding real downlink
  data. Don't trust the 5G S/N number as-is.
- Wanted to cross-check with Quectel-native `AT+QCSQ` /
  `AT+QENG="servingcell"` via `mmcli -m 0 --command=...`, but
  ModemManager blocks arbitrary AT passthrough unless the daemon
  itself is running in `--debug` mode.
- **Gotcha, don't repeat**: restarting ModemManager manually in debug
  mode (`/etc/init.d/modemmanager stop; ModemManager --debug &`) to
  unlock AT passthrough caused it to **completely fail to detect the
  modem** (`[base-manager] unsupported automatic device scan` in the
  debug log, then `mmcli -L` → "No modems were found", LuCI's Cellular
  Network page showed `Network device is not present`). OpenWRT's
  normal `/etc/init.d/modemmanager start` apparently wires up device
  discovery via an explicit hotplug/netifd mechanism that the bare
  `ModemManager --debug &` invocation doesn't get. Had to `killall
  ModemManager; /etc/init.d/modemmanager start` to recover — took
  a short interruption of the live cellular connection to fix.
  **Conclusion: don't use the debug-mode trick on this box while it's
  the live WAN path** — if AT-level signal detail is needed again,
  find another way (e.g. a scheduled brief maintenance window) rather
  than restarting the daemon live.
- Also noticed `operator name: Galaxus` in `mmcli -m 0` output instead
  of "Sunrise" — `operator id: 22802` is still Sunrise's real
  MCC/MNC, so this is just MVNO/wholesale branding surfacing through
  (Digitec Galaxus's mobile brand runs on Sunrise), not a sign the SIM
  is on the wrong network.

### Modem health check (2026-09-08)

- Ad-hoc check via `mmcli -m 0` / `--signal-get` / `ip route` / `ping`:
  state `connected`, `registration: home` (Sunrise/Galaxus), still binding
  via `cdc_mbim` (the stable driver path, not the manual `qmi_wwan
  new_id` bind). Default route present via `wwan0`. `ping 8.8.8.8`: 3/3,
  0% loss, 23–52ms.
- Signal: LTE RSRP -116 dBm / S/N -4.5 dB, 5G RSRP -104 dBm / S/N -23.0
  dB — weak-to-poor on both, consistent with the 2026-08-26 readings
  above. The 5G S/N is again pinned at exactly -23.00 dB, matching the
  previously-flagged suspected stale/placeholder value — not a new
  issue.
- **Location: home office** (the Pi's normal operating position, not a
  one-off placement) — the weak signal here is the readout that
  actually matters for this project's use case, since this is where it
  runs day to day. Worth factoring into any antenna placement /
  external-antenna-cable decisions.
- Conclusion: everything functionally healthy, no action needed. Signal
  strength remains the one soft spot, unchanged from prior sessions.
- **Enabled SSH access for remote checks**: added a FIDO2
  hardware-security-key-backed SSH public key to root's
  `authorized_keys` via LuCI (System → Administration → SSH-Keys).
  Requires the physical key present (and occasionally a touch) to
  authenticate — no passwordless/unattended access was set up, by
  choice, to avoid giving standing automated root access to the router.

### WiFi hotspot / cable-free management — concurrent AP+STA does NOT work on this radio (2026-08-26)

- Goal: let the onboard WiFi (`radio0`, Cypress **CYW43455**
  802.11ac/b/g/n — corrects the earlier "Broadcom/Cypress BCM4345/6"
  guess in "Internet access on Pi" above, which was the wrong chip
  model) act as a management AP (`pi5-modem` SSID, WPA2, bound to
  `network='lan'`) so the laptop wouldn't need an Ethernet cable,
  while *also* keeping the existing `wwan` STA client link to the
  `Pixel_7718` phone hotspot.
- Set it up via LuCI (Network → Wireless → enable the disabled
  `OpenWrt`/Master entry, set SSID/WPA2 key, keep the `Pixel_7718`
  client enabled) expecting the CYW43455/brcmfmac driver to handle
  concurrent AP+STA cleanly (the same technique used in common
  Pi-as-travel-router guides).
- **Result: it does not work reliably on this driver/firmware combo.**
  `logread -f` showed `phy0-ap0` (AP) and `phy0-sta0` (STA) flapping
  up/down in lockstep continuously, roughly once per second, for
  minutes on end — bringing up the AP interface knocks the STA
  offline (`wpa_supplicant: CTRL-EVENT-DISCONNECTED ...
  locally_generated=1`), which re-triggers `phy0-ap0` re-init too, in
  an unbroken feedback loop. The AP interface never stays up long
  enough for a client to complete association + DHCP, so laptops
  could see the `pi5-modem` SSID (it does broadcast) but could never
  actually finish connecting.
- **Fix**: disabled the `Pixel_7718` STA client entirely (LuCI →
  Wireless → Disable, or `uci set wireless.wwan.disabled='1'; uci
  commit wireless; wifi reload`) and ran the radio **AP-only**. This
  immediately stopped the flapping and the `pi5-modem` AP became
  stable — laptop connected successfully and stayed connected.
- Confirmed viable *only* because the Calyx modem is now the WAN path
  (see below) — cutting the `Pixel_7718` STA uplink no longer means
  losing internet, since it was never providing WAN once the modem
  came up.

### `mobile` interface's default route silently vanished from the kernel table (2026-08-26)

- Symptom: after switching to AP-only WiFi, `pi5-modem` clients (and
  briefly the Pi itself) got `Destination Net Unreachable` pinging
  `8.8.8.8`, even though `mmcli -m 0` showed the modem `state:
  connected` and `ping -I wwan0 8.8.8.8` from the Pi worked fine
  minutes earlier.
- Root cause: `ip route show default` had **no `0.0.0.0/0` entry at
  all** — only the two directly-connected subnet routes (`10.0.0.0/24
  dev br-lan`, `10.128.169.64/29 dev wwan0`). `ip route get 8.8.8.8`
  failed even from the Pi itself with "Network unreachable" at that
  point. Yet `ifstatus mobile` still *reported* a default route
  (`nexthop 10.128.169.69`) as part of its config — netifd's view of
  the interface's routes had drifted from what was actually in the
  kernel table. Firewall/NAT config was fine throughout (`mobile` is
  correctly in the `wan` zone with `masq='1'`, `lan → wan` forwarding
  is `ACCEPT`) — this was purely a missing-route issue, not a
  firewall one.
- Likely trigger: one of the several `wifi reload` / network restarts
  from the AP+STA experimentation above silently dropped the
  kernel-side default route without netifd re-adding it (netifd only
  reinstalls a given interface's routes on that interface's own
  up/down transition, not as a side effect of unrelated `wifi
  reload`s).
- Fix: bounce the interface to force netifd to reinstall its routes
  from scratch:
  ```
  ifdown mobile
  ifup mobile
  ip route show default   # confirm 0.0.0.0/0 via wwan0 reappears
  ```
- **Verified end-to-end again after the fix**: laptop connected to
  `pi5-modem` WiFi (no Ethernet), `ping 8.8.8.8` — 7/7 packets, 0%
  loss, 28–128ms.
- **Hardened (2026-08-26)**: added a cron watchdog via LuCI (System →
  Scheduled Tasks, which just edits root's crontab). Live config as of
  2026-08-29 (interval tightened from the original 5 minutes to 2):
  ```
  */2 * * * * ping -c 2 -W 3 -I wwan0 8.8.8.8 >/dev/null 2>&1 || { ifdown mobile; sleep 3; ifup mobile; }
  ```
  Every 2 minutes, pings out over `wwan0`; on failure, bounces the
  `mobile` interface to force netifd to reinstall its routes (the same
  manual fix used above). Only triggers the brief reconnect blip when
  connectivity is already broken. No cron service restart needed —
  OpenWRT's cron daemon picks up crontab changes automatically.

### WiFi AP disassociations — not caused by Ethernet unplugging, not a LuCI misconfiguration (2026-08-29)

- Symptom reported: laptop's WiFi connection to `pi5-modem` (and
  internet through it) appeared to only work while the Pi's Ethernet
  cable was also plugged in — unplugging it seemed to kill the WiFi
  link too, not just internet-via-WiFi.
- Checked `logread` retrospectively (had to check *after* reconnecting
  Ethernet, since pulling the Pi's own `eth0` kills the very SSH
  session used to observe it live). Correlated `eth0: Link is Down`
  events against `hostapd`'s `STA ... disassociated` events:

  | `eth0` down at | STA disassociated at | gap |
  |---|---|---|
  | 15:36:49 | 15:36:52 | 3s |
  | 15:40:16 | 15:40:47 | 31s |
  | *(no eth0 event nearby)* | 15:45:34 | — |

  The inconsistent gap (3s vs 31s) and the third disassociation with
  **no eth0 event anywhere near it** rules out a direct/deterministic
  causal link between unplugging Ethernet and the WiFi dropping.
- Double-checked LuCI config across Cellular Network status, Network →
  Interfaces, Wireless Overview, and System → Scheduled Tasks — nothing
  misconfigured; `mobile` and `lan` were both up continuously for
  30+ minutes at the time, the watchdog cron wasn't the trigger either
  (its run timestamps didn't line up tightly with the disassociation
  events, and no `wwan0 link is down` followed any cron tick, meaning
  its ping was succeeding, not triggering the `ifdown`/`ifup` fallback).
- **Conclusion**: this is the same pre-existing AP-mode instability on
  the onboard `CYW43455`/`brcmfmac` radio identified earlier (see
  "Advanced Settings" jitter investigation elsewhere in this doc) —
  not a config mistake, not caused by the Ethernet cable specifically.
  Already tried and ruled out as fixes: disabling WiFi power-save,
  disabling SDIO bus autosuspend (`power/control` → `on`). No further
  fix identified. **Standing recommendation: treat `pi5-modem` WiFi as
  convenience-only; use Ethernet for anything that needs to stay
  reliably connected.**

### WiFi AP goes fully unreachable after Ethernet flaps — root cause found: `brcmfmac` firmware timeout (2026-09-08)

- Follow-up to "WiFi AP disassociations" above, prompted by testing
  unplugging the Ethernet cable at each end in turn (laptop end, then
  Pi end) to see whether either reproduces a full WiFi outage rather
  than just a disassociation.
- **Laptop-end unplug**: the WiFi association to `pi5-modem` survived
  at the 802.11 level (no `hostapd` disassociation logged), but the
  link degraded badly in real time — packet loss up to ~80%, then
  (once loss cleared) latency spikes from ~400ms up to ~2.9s. No new
  root cause here beyond the pre-existing general radio flakiness.
- **Pi-end unplug**: this time the `pi5-modem` SSID **disappeared
  entirely** from WiFi scans on the client — not just degraded, not
  found at all — until the cable was plugged back into the Pi, at
  which point it reappeared (though it then took a couple of minutes
  and some flapping before a client could actually re-associate and
  stay associated).
- `logread` from the Pi during that window showed the actual mechanism
  for the first time:
  ```
  hostapd: phy0-ap0: STA ... disassociated
  ...
  kernel: brcmf_cfg80211_del_station: SCB_DEAUTHENTICATE_FOR_REASON failed -110
  brcmfmac: brcmf_cfg80211_change_bss: ap_isolate iovar failed: ret=-110
  ```
  repeated several times over about a minute, alongside more
  disassociate/re-associate churn, only clearing up once `eth0`
  flapped Up → Down → Up again on a cable reseat and settled Up.
- **`-110` is `ETIMEDOUT`** — the `brcmfmac` driver tried to issue a
  command to the WiFi chip's own firmware and got no response,
  repeatedly. This is a firmware-level hang on the onboard
  `CYW43455`, not a `hostapd`/config-level issue, and it happened
  specifically in the window around the Pi-side Ethernet link
  flapping — a much more concrete (if still unconfirmed-as-causal)
  lead than the inconsistent-timing result from 2026-08-29.
- **Not yet confirmed**: whether this is deterministically triggered
  by the `eth0` link changing (e.g. shared power/interrupt/bus
  contention between the onboard Ethernet MAC and the WiFi chip on
  the Pi 5), or a coincidental firmware fault that happened to occur
  in the same window twice. Worth a repeat test (unplug Pi-side
  Ethernet again, watch for the same `ret=-110` errors) before
  treating it as fully confirmed.
- **Practical takeaway unchanged for now**: same standing
  recommendation as 2026-08-29 — don't rely on `pi5-modem` WiFi for
  anything that must stay up, especially not while also
  connecting/disconnecting the Pi's Ethernet cable. If this recurs,
  the firmware-timeout angle is the next concrete thing to chase
  (e.g. checking for a `brcmfmac`/kernel firmware update, or whether
  the Ethernet and WiFi chips share a power rail or interrupt line on
  the Pi 5 HAT stack) rather than further OpenWRT config changes.
- **This is a known upstream issue, not specific to this setup.** The
  `-110`/`ETIMEDOUT` firmware-timeout failure mode on Broadcom/Cypress
  WiFi chips (BCM43455/CYW43455 — the same chip family across Pi 3B+,
  Pi 4, and the Pi 5's onboard WiFi) running in **AP mode** is
  widely reported and unresolved upstream:
  - An OpenWrt GitHub issue for the Pi 5's BCM43455 describes an "HT
    Avail timeout before firmware download after repeated wifi
    reload" that leaves the chip unrecoverable until a **cold PSU
    power cycle** — not just a reboot — closely matching needing a
    physical cable reseat to recover here.
  - Multiple Raspberry Pi forum threads (Pi 3B+, Pi 4) report the
    same `-110` firmware-timeout pattern specifically when running as
    an AP, with no consistently reliable fix found by the community —
    troubleshooting commonly points at power supply stability as a
    contributing factor, which lines up with the GPIO-header-power
    speculation above.
  - Given this, further OpenWRT-side config changes are unlikely to
    fix it — it appears to be a hardware/firmware limitation of this
    chip family in AP mode generally, reinforcing the existing
    "WiFi is convenience-only" stance rather than something to keep
    chasing a fix for.

### Modem not detected after reboot — intermittent, root cause still unclear (2026-08-28)

- Symptom: after a reboot, `mmcli -L` returned "No modems were found"
  even though the modem was genuinely present and correctly bound at
  the kernel level (`cdc_mbim` bound, `/dev/cdc-wdm0` existed,
  confirmed via `dmesg`). ModemManager itself just never noticed it.
- Tried, none of which worked: `/etc/init.d/modemmanager restart`;
  unbinding/rebinding just the `cdc_mbim` interface function
  (`echo "4-1:1.8" > .../cdc_mbim/{unbind,bind}`); a full USB
  device-level unbind/rebind (`echo '4-1' >
  .../drivers/usb/{unbind,bind}`), which should look like a real
  physical unplug/replug to the kernel.
- Root cause theory: this ModemManager build's own log (from an
  earlier session) said `[base-manager] unsupported automatic device
  scan` — meaning it doesn't do automatic udev-based discovery at all
  (typical for OpenWRT MM builds without libudev) and instead needs an
  external trigger. Checked `/etc/hotplug.d/usb/00_wwan.sh`, but that
  script only handles the older `proto=wwan` mechanism, not
  `proto=modemmanager` — so nothing on this system actually re-reports
  USB events to ModemManager for our config. Never confirmed with
  certainty why it sometimes works after boot and sometimes doesn't.
- **What actually fixed it, both times it happened**: just rebooting
  again. Not reliable/understood — a subsequent reboot sometimes
  detects the modem fine, sometimes doesn't. **Unresolved**: no known
  deterministic trigger or clean fix found. If this recurs, the
  next thing to try (never actually got to test it) is `mmcli
  --report-kernel-event`, which is the documented way to manually
  report a device to a udev-less ModemManager build.

### Traveling/roaming: modem showed connected but passed zero data — resolved, cause still fuzzy (2026-08-28 to 2026-08-29)

- Context: took the Pi + Calyx HAT along while traveling abroad (an
  EU/EFTA country, on a roaming data package). Both a phone and the
  Pi's modem use SIMs on the same Sunrise/Galaxus account.
- Symptom: modem showed `state: connected`, `registration: roaming`
  (on `Magenta-T- (Galaxus)`, operator id `23203` — Magenta/T-Mobile
  Austria), `packet service state: attached`, a real assigned IP and
  default route (confirmed via `ip addr`/`ip route get`) — yet **all
  traffic failed 100%**, both ICMP and raw TCP (`nc`, `wget`), to
  multiple destination IPs.
- Ruled out, in order, each with clean confirming evidence: netifd
  config drift (IP/route were correct), firewall/NAT (unchanged,
  correct), stale bearer (forced `mmcli --simple-disconnect` +
  reconnect, and separately `ifdown`/`ifup mobile` — both produced a
  "fresh" connected state but identical symptom), one-active-session
  account limit (tested by putting the phone in airplane mode — Pi
  still got zero data), modem-level signal (fine, 64% at the point it
  was working, though it did also show a genuine `0%`/no-signal spell
  at one point earlier, worth noting these are separate issues that
  overlapped in the same travel session).
- **Signal quality intermittently dropped to a real 0%** at one point
  (matching the physical Teltonika HAT's `NET_IND` LED not lighting at
  all) — that specific episode was a genuine no-signal condition, only
  resolved by moving/waiting, not a software issue. Don't confuse this
  with the separate "connected but no data" issue above — both
  happened across this travel session and are not the same root cause.
- Tried swapping in a second physical SIM (also Sunrise/Galaxus
  branded, different ICCID/IMSI) with its own PIN configured in
  `network.mobile.pincode` (not documented here — set your own). This
  SIM got an explicit, informative failure instead of a silent one:
  ```
  registration: idle
  network rejection error: network-failure
  network rejection operator id: 23201
  network rejection operator name: A1 (Galaxus)
  ```
  i.e. the network (A1 Telekom Austria this time) outright rejected
  registration, rather than accepting it and silently dropping data.
- Suspected but **not confirmed** explanation: some budget/MVNO plans
  (Galaxus is a Sunrise MVNO brand) restrict SIMs to phone-only use and
  may enforce this via device-type/IMEI checks specifically on roaming
  partner networks (not enforced at home, which is why this never
  showed up during the original Switzerland bring-up). Plausible given
  the symptoms, but never verified with Sunrise/Galaxus support.
- **Resolution**: switched back to the original SIM, kept retrying
  (reboots, modem enable/disable, waiting) over an extended period —
  eventually it just started working, both `ping 8.8.8.8` from the Pi
  and a full laptop-over-WiFi-through-Pi test succeeded. **No specific
  action was identified as "the fix"** — it seems to have been a
  transient roaming-network-side issue (possibly on the roaming
  partner's end) that resolved on its own after enough time/retries.
  If this recurs while traveling: don't assume it's fixable quickly:
  budget for it possibly just taking a while, and rule out a genuine
  signal/location problem first (check the `NET_IND` LED and
  `mmcli -m 0` signal quality) before chasing the network-rejection
  angle.

## Remaining Tasks

### Immediate (next steps)

1. ✅ Configure Pi's WiFi for internet access — done via `wwan` STA on
   `Zyxel_57AA_5G`
2. ✅ Test internet connectivity on Pi — confirmed (ping + DNS)
3. ✅ Run `apk update` — confirmed, 11,120 packages available
4. ✅ Install Calyx modem drivers — done (`kmod-usb-net-qmi-wwan uqmi
   comgt luci-proto-qmi modemmanager`)
5. ✅ Missing hardware arrived (16mm GPIO header + standoffs + PSU)
6. ✅ Mount Calyx HAT on top of Pi 5 — done (16mm header + M2.5 standoffs)
7. ✅ Connect antennas + insert SIM — done (4× antennas, Sunrise SIM
   moved over from the Zyxel router)
8. ✅ Configure QMI cellular interface — done via ModemManager
   (`mobile` interface, APN `internet`), verified working end-to-end
   from a LAN client (see Phase 5 above). **Follow-up still open**:
   the modem is now binding via `cdc_mbim` rather than the manually
   forced `qmi_wwan`, so the original persistence concern may be moot
   — still needs a real reboot test to confirm (see "Modem now
   binding via cdc_mbim" above).
9. ✅ WiFi hotspot for cable-free management — done, but concurrent
   AP+STA on the onboard radio doesn't work on this driver; running
   AP-only (`pi5-modem` SSID) with the `Pixel_7718` STA link disabled
   is the stable configuration (see "WiFi hotspot / cable-free
   management" above).
10. ✅ Watchdog for the `mobile` interface's default route silently
    dropping from the kernel table — cron job added via LuCI (System →
    Scheduled Tasks), see "`mobile` interface's default route silently
    vanished" above.
11. Install SQM QoS (CAKE) — critical for bufferbloat prevention
12. Install AdGuard Home or Pi-hole (DNS ad blocking)
13. Install Tailscale (remote access)
14. Test full throughput + RDP + video calls, validate against use case
    requirements

### Optional (future)

- Install proper case (KKSB Tall Aluminum or Geekworm P579-V2)
- Add heatsink to Calyx EBD050 module
- Configure firewall rules for port forwarding
- Set up backups/config snapshots
- **TODO**: think about splitting AP and STA (client uplink) across
  2.4GHz and 5GHz to make both reliable at once — the `CYW43455` radio
  is dual-band capable but the flapping bug (see "WiFi hotspot /
  cable-free management" above) showed concurrent AP+STA on the *same*
  radio/channel is unstable. Worth investigating whether the driver
  can run one virtual interface per band concurrently (AP on one band,
  STA on the other) without the same feedback-loop problem, or whether
  that still shares the same underlying radio hardware and hits the
  same limitation regardless of band.

## Technical Notes for Continuation

### Network configuration (OpenWRT)

- LAN IP: `10.0.0.1/24` (`br-lan`, contains `eth0`) — changed from the
  default `192.168.1.1`. **Netmask must be set explicitly**
  (`network.lan.netmask='255.255.255.0'`) — this build defaults to
  `/32` if omitted, which silently breaks LAN DHCP (see "SSH/LAN
  unreachable" above).
- WiFi uplink (`wwan`, STA mode on `phy0-sta0`) joins the home WiFi for
  internet access — assigned to the WAN firewall zone, so SSH/LuCI are
  correctly blocked there by default. Use Ethernet (`10.0.0.1`) for
  management access, not WiFi.
- Ethernet WAN: `eth0` (to be configured as DHCP client after Calyx
  installed) — currently still LAN-side (bridged into `br-lan`), not
  yet repurposed as WAN.
- Hostname: `pi5-modem` (changed from default `OpenWrt`). Set via
  `uci set system.@system[0].hostname='pi5-modem'; uci commit system`,
  but `/etc/init.d/system reload` only updates the live shell
  prompt/`hostname` — it does **not** make the new name resolvable
  from LAN clients. Name resolution comes from the router's own
  `dnsmasq` (LAN DNS server at `10.0.0.1`, `.lan` search domain, so
  bare `pi5-modem` resolves as `pi5-modem.lan`), which caches the
  hostname at its own startup. Needed an explicit
  `/etc/init.d/dnsmasq restart` on the Pi, plus a DHCP lease renewal
  on the client side (`nmcli connection down/up "<ethernet
  connection>"`) to drop its stale cached mapping. Restarting
  `dnsmasq` did not disrupt the already-up `wwan` uplink (confirmed via
  `ifstatus wwan`). Cosmetic leftover: `wwan`'s own DHCP client still
  advertises the old hostname (`OpenWrt`) to the upstream Zyxel
  router's client list until its next lease renewal — harmless.

### EEPROM boot order

`BOOT_ORDER=0xf416` — meaning: NVMe (6) → SD (1) → USB (4) → Loop (f)

### NVMe power fix applied

Added to `/boot/firmware/cmdline.txt`:

```
nvme_core.default_ps_max_latency_us=0 pcie_aspm=off pcie_port_pm=off
```

### Calyx modem details

| Spec | Value |
|---|---|
| Model | Teltonika EBD050 (full 5G) |
| Chipset | Quectel RG520NEB |
| Bands | Covers Swiss Sunrise n78 (3400–3800 MHz), n38 (2570–2620 MHz) |
| Protocol | QMI (requires `uqmi` + `kmod-usb-net-qmi-wwan`) |
| Antennas | 4× SMA ports (2×2 MIMO minimum, 4×4 MIMO optimal) |
| APN | `internet` (Sunrise default) |

### Package manager

OpenWRT 25.12.5 uses `apk` instead of `opkg`:

```
apk add <package>     # install
apk remove <package>  # uninstall
apk update            # refresh repo
apk search <package>  # find packages
```

## Expected Performance Targets

Based on Calyx EBD050 specs + Sunrise 5G SA network:

| Metric | Target |
|---|---|
| Download speed | 200–600 Mbps (realistic indoor) |
| Upload speed | 100–300 Mbps |
| Latency | 15–30 ms (5G SA) |
| Bufferbloat | Fixed via SQM QoS (CAKE) |
| Concurrent users | 2–3 devices (user + roommate) |

## Reference Links

| Resource | URL |
|---|---|
| OpenWRT downloads | https://downloads.openwrt.org/releases/25.12.5/targets/bcm27xx/bcm2712/ |
| Teltonika antenna (Digitec) | https://www.digitec.ch/de/s1/product/teltonika-5g-mobile-sma-antenna-5g-netzwerkantenne-25155794 |
| Official Pi 5 Active Cooler | https://www.digitec.ch/en/s1/product/raspberry-pi-official-fan-heat-sink-for-5-38955610 |
| Sunrise 5G coverage | check sunrise.ch for local SA coverage |
| Teltonika Calyx QSG (wiki) | https://wiki.teltonika-networks.com/view/QSG_Calyx — covers multiple Calyx variants (EBD021/EBD050/EBD070) without clearly separating model-specific steps; treat AT-command/USB-mode instructions found there as unverified for EBD050 specifically |
| DIY 5G router writeup (Hackernoon) | https://hackernoon.com/the-diy-5g-router-hack-that-turns-a-raspberry-pi-into-a-pocket-sized-powerhouse — blocked WebFetch with HTTP 403 during this session, never actually reviewed |
| APN lookup reference | https://www.imei.info/faq-apn/ — general carrier APN reference; Sunrise's own default (`internet`) is what we used |
| OpenWrt issue: BCM43455 HT Avail timeout on Pi 5 | https://github.com/openwrt/openwrt/issues/23069 — closest match to the `brcmfmac ret=-110`/AP-disappearing issue found 2026-09-08; root-caused to the Pi 5's `wl-on-reg` regulator not fully power-cycling the WiFi chip, only a PSU cold boot recovers it |
| raspberrypi/linux issue: BCM43455 crash in concurrent STA+AP mode | https://github.com/raspberrypi/linux/issues/7092 |
| Pi Forums: RP5 wifi problems | https://forums.raspberrypi.com/viewtopic.php?t=376855 |
| Pi Forums: brcmf_set_channel chanspec fail, reason -52 | https://forums.raspberrypi.com/viewtopic.php?t=367466 |
| Pi Forums: brcmfmac stuck on DFS-UNSET regulatory domain | https://forums.raspberrypi.com/viewtopic.php?t=392203 — related firmware-level bug blocking all beacon transmission |

## Session End Point

Last state (2026-08-26): **Core project goal still holds, plus
cable-free management now works too.** The Pi routes real LAN internet
traffic through the Calyx EBD050's 5G cellular connection (Sunrise,
APN `internet`, via ModemManager), and LAN clients can now reach it
over WiFi (`pi5-modem` SSID, AP-only) instead of needing Ethernet.
Verified end-to-end from a laptop on `pi5-modem` WiFi with no Ethernet
plugged in: `ping 8.8.8.8` — 7/7 packets, 0% loss, 28–128ms.

Along the way (2026-08-25 session): fixed a missing LAN netmask that
broke SSH ("SSH/LAN unreachable" above), recovered from an NVMe
boot-time controller drop that corrupted the root filesystem ("NVMe
boot-time controller drop" above), switched the onboard WiFi `wwan`
uplink from the Zyxel router (now offline — its SIM moved to the Calyx
HAT) to a `Pixel_7718` phone hotspot (fixing a `sae-mixed` encryption
mismatch along the way), set the hostname to `pi5-modem`, and
force-bound the Calyx modem's USB driver via a manual `qmi_wwan
new_id`.

This session (2026-08-26) added: signal-strength diagnostics via
`mmcli` (found weak-but-working LTE/5G signal, ~-100 to -115 dBm
RSRP — see "Signal strength checking" above), discovered the modem is
now binding via `cdc_mbim` instead of the manually-forced `qmi_wwan`
(possibly making the reboot-persistence concern moot, still unverified
— see "Modem now binding via cdc_mbim" above), found that concurrent
AP+STA on the onboard `CYW43455` radio is fundamentally unstable
(continuous interface flapping — see "WiFi hotspot / cable-free
management" above) so switched to AP-only for `pi5-modem`, and fixed a
case where the `mobile` interface's default route silently vanished
from the kernel routing table after unrelated WiFi reloads (see
"`mobile` interface's default route silently vanished" above) — fixed
with `ifdown mobile; ifup mobile`, but not yet hardened against
recurrence.

Pi 5 running OpenWRT 25.12.5 from NVMe, on the official 27W PSU.
Management access is via Ethernet (`ssh root@pi5-modem` or
`ssh root@10.0.0.1`) **or** WiFi (`pi5-modem` SSID, WPA2, bound to
`lan` so SSH/LuCI work over it too) — the `Pixel_7718` STA uplink is
now disabled since it's no longer needed for WAN.

**Update (2026-08-28 to 2026-08-29, traveling abroad):** took the Pi on
a trip (EU/EFTA roaming). Hit two separate, unresolved-mechanism
issues: (1) the modem intermittently isn't detected by ModemManager
after a reboot (fixed each time only by rebooting again — see "Modem
not detected after reboot" above, no real root cause found), and (2)
the modem showed fully connected/registered/roaming with a real IP but
passed **zero data** for an extended period, which eventually resolved
on its own after repeated retries with no single identified fix (see
"Traveling/roaming: modem showed connected but passed zero data"
above). Both are flagged as open risks for future travel with this
setup, not closed problems.

**Open follow-ups for next session:**
1. **Untested: does the Calyx modem survive a reboot?** It's currently
   binding via `cdc_mbim` automatically (not the manual `qmi_wwan
   new_id` bind from the original bring-up) — unclear if that's
   reliable across a real reboot. Now additionally complicated by the
   intermittent "ModemManager doesn't detect it after reboot" issue
   found while traveling — still no deterministic fix, just "reboot
   again and hope."
2. ✅ Watchdog for the `mobile` default-route-drop issue — cron job
   (ping check + auto `ifdown`/`ifup mobile` on failure) added via
   LuCI System → Scheduled Tasks. Confirmed working for real once
   (forced a route drop, watchdog recovered it within the 5-minute
   window, unprompted).
3. Decide whether the onboard WiFi radio should stay AP-only
   permanently (current stable state) — it can no longer also serve as
   a WiFi *uplink* (STA) at the same time without the flapping bug
   recurring.
4. Remaining feature work: SQM QoS (CAKE) for bufferbloat, AdGuard
   Home/Pi-hole, Tailscale, then full throughput/RDP/video-call
   validation against the original use-case requirements.
5. Decide whether to move the Sunrise SIM back to the Zyxel router or
   commit to the Pi as the permanent gateway (currently the Zyxel has
   no internet since the SIM moved).
