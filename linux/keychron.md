# Keychron Q3 Pro — Bluetooth Setup & Issues

Tags: #keyboard #bluetooth #troubleshooting

## Hardware

- **Keyboard:** Keychron Q3 Pro
- **Connection:** Bluetooth, paired on slot 3
- **Host:** ThinkPad P14s Gen 5 (see [[p14s]])

## Known Issues

### Issue 1 — Not available at LUKS unlock

**Status:** By design — not fixable in practice

Bluetooth stack is not available during initramfs. The Q3 Pro is not connected at the LUKS PIN prompt.

**Workaround:** Use the built-in laptop keyboard to enter the LUKS PIN.

---

### Issue 2 — Wrong/repeated characters after boot (~50-66% of boots)

**Status:** Fix implemented 2026-03-22 — [[keychron-bt-fix.sh]] + [[keychron-bt-fix.service]]

**Symptom:** After Bluetooth connects on boot, key presses produce wrong or repeated characters. The incorrect mapping is consistent (same wrong chars every time). Affects roughly half to two-thirds of boots.

**Workaround (manual):** Switch to a different BT slot on the keyboard, wait ~2s, switch back to slot 3. Forces a clean reconnect which restores correct input.

**Root cause:** Stale HID descriptor cache in bluez after reboot. The Keychron uses `hid-generic` and relies entirely on the bluez cache. On a bad boot, bluez reuses a cached descriptor that doesn't match what the keyboard negotiates, causing a shifted/corrupted key map. The MX Master 2S is unaffected — it uses `logitech-hidpp-device` with HID++ 4.5, which negotiates independently of the bluez HID cache.

**Automated fix:** `keychron-bt-fix.sh` polls sysfs after boot, compares the HID report descriptor md5 to a known-good hash, and forces a disconnect/reconnect only if stale. No action taken on clean boots.

**Known-good descriptor:** 242 bytes, md5 `ac9e509eaa0841c31c56a6aa501fd82d`
(captured 2026-03-22 on kernel 6.19.9-arch1-1)

#### How to determine the script variables

```bash
# KEYCHRON_MAC — list all paired BT devices
bluetoothctl devices

# KEYCHRON_HID_ID — find the sysfs HID path after keyboard connects via BT
# format is 0005:<vendor>:<product>.* where 0005 = BT bus (USB = 0003)
ls /sys/bus/hid/devices/ | grep "^0005:"

# KNOWN_GOOD_HASH — capture while keyboard is working correctly
# first find the descriptor path for the Keychron (3434:0630)
# use /sys/devices/virtual/misc/uhid — NOT /sys/bus/hid/devices (symlinks cause infinite traversal)
find /sys/devices/virtual/misc/uhid -name "report_descriptor" -path "*0005:3434:0630*"
# then hash it
md5sum /sys/devices/virtual/misc/uhid/0005:3434:0630.*/report_descriptor
```

#### Install

```bash
sudo cp linux/keychron-bt-fix.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/keychron-bt-fix.sh
sudo cp linux/keychron-bt-fix.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now keychron-bt-fix.service
```

## Useful Commands

```bash
bluetoothctl devices                        # list paired devices
bluetoothctl info <MAC>                     # show device state
journalctl -b | grep -i bluetooth           # BT init log
systemctl status bluetooth.service          # service status
```
