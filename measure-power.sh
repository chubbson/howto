#!/bin/bash
# Measure idle power consumption and log with timestamp + PSR setting
# Run on battery, screen static, nothing active — for PSR comparison

LOGFILE="$HOME/power-measurements.log"
SAMPLES=12
INTERVAL=5

# Check if on battery
status=$(cat /sys/class/power_supply/BAT0/status)
if [[ "$status" != "Discharging" ]]; then
    echo "ERROR: Laptop is not on battery (status: $status). Unplug AC and retry."
    exit 1
fi

# Read current PSR setting
psr_param=$(cat /proc/cmdline | grep -oP 'i915\.enable_psr=\K[0-9]' || echo "default")
case "$psr_param" in
    0) psr_label="PSR disabled" ;;
    1) psr_label="PSR1 only" ;;
    2) psr_label="PSR2 (selective fetch)" ;;
    *) psr_label="PSR default (probably PSR2)" ;;
esac

echo "Measuring for $((SAMPLES * INTERVAL))s — keep screen static, don't touch the machine..."
echo "PSR setting: $psr_label"
echo ""

# Collect samples
total=0
count=0
for i in $(seq $SAMPLES); do
    val=$(cat /sys/class/power_supply/BAT0/power_now)
    total=$((total + val))
    count=$((count + 1))
    printf "  sample %2d/%d: %.2f W\n" "$i" "$SAMPLES" "$(awk "BEGIN {printf \"%.2f\", $val / 1000000}")"
    sleep $INTERVAL
done

avg=$(awk "BEGIN {printf \"%.2f\", $total / $count / 1000000}")
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Append to log
echo "$timestamp | $psr_label | avg: ${avg} W" >> "$LOGFILE"

echo ""
echo "Result: avg ${avg} W"
echo "Logged to: $LOGFILE"
