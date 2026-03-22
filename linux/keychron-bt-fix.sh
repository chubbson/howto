#!/bin/bash
# /usr/local/bin/keychron-bt-fix.sh
# Detects stale HID descriptor on Keychron Q3 Pro BT connect and forces reconnect.

KEYCHRON_MAC="6C:93:08:65:21:C9"
KEYCHRON_HID_ID="3434:0630"
KNOWN_GOOD_HASH="ac9e509eaa0841c31c56a6aa501fd82d"
MAX_WAIT=30  # seconds to wait for keyboard to appear

# Wait for the BT HID device to show up in sysfs
for i in $(seq 1 $MAX_WAIT); do
    DESCRIPTOR=$(find /sys/devices/virtual/misc/uhid -name "report_descriptor" \
        -path "*0005:${KEYCHRON_HID_ID}*" 2>/dev/null | head -1)
    [[ -n "$DESCRIPTOR" ]] && break
    sleep 1
done

if [[ -z "$DESCRIPTOR" ]]; then
    echo "Keychron not connected after ${MAX_WAIT}s, skipping."
    exit 0
fi

ACTUAL_HASH=$(md5sum "$DESCRIPTOR" | cut -d' ' -f1)

if [[ "$ACTUAL_HASH" == "$KNOWN_GOOD_HASH" ]]; then
    echo "Keychron HID descriptor OK, no action needed."
    exit 0
fi

echo "Stale HID descriptor detected (got $ACTUAL_HASH), forcing reconnect..."
bluetoothctl disconnect "$KEYCHRON_MAC"
sleep 2
bluetoothctl connect "$KEYCHRON_MAC"
