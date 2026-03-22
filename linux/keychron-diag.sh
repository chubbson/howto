#!/bin/bash
# Run this when the Keychron is in the BROKEN state (wrong characters) before doing manual fix.

KEYCHRON_HID_ID="3434:0630"

DESCRIPTOR=$(find /sys/devices/virtual/misc/uhid -name "report_descriptor" \
    -path "*0005:${KEYCHRON_HID_ID}*" 2>/dev/null | head -1)

if [[ -z "$DESCRIPTOR" ]]; then
    echo "Keychron HID device not found in sysfs."
    exit 1
fi

HASH=$(md5sum "$DESCRIPTOR" | cut -d' ' -f1)
SIZE=$(wc -c < "$DESCRIPTOR")
KNOWN_GOOD="ac9e509eaa0841c31c56a6aa501fd82d"

echo "Descriptor: $DESCRIPTOR"
echo "Size:       $SIZE bytes"
echo "Hash:       $HASH"
echo "Known-good: $KNOWN_GOOD"

if [[ "$HASH" == "$KNOWN_GOOD" ]]; then
    echo "Result:     SAME as known-good → hash check cannot detect broken state"
else
    echo "Result:     DIFFERENT → hash check could work, update KNOWN_GOOD_HASH in fix script"
fi
