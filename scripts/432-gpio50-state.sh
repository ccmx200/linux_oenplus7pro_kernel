#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
echo "=== pinctrl 里 gpio50"
for f in /sys/kernel/debug/pinctrl/*/pinconf-pins; do echo "-- $f"; grep -E "pin 50 " "$f" 2>/dev/null; done
echo "=== pinmux-pins 里 gpio50"
for f in /sys/kernel/debug/pinctrl/*/pinmux-pins; do grep -E "pin 50 " "$f" 2>/dev/null; done
echo "=== gpio 状态"
command -v gpioinfo >/dev/null && gpioinfo 2>/dev/null | grep -E "line +50:" || echo "(no gpioinfo)"
cat /sys/kernel/debug/gpio 2>/dev/null | grep -E "gpio-50|gpio50" | head -3
' 2>&1 | grep -v Warning | head -30
