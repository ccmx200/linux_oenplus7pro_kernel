#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 显示"
ls /sys/class/drm | head
for c in /sys/class/drm/card0-DSI-1; do echo "status=$(cat $c/status)"; done
echo "=== 背光"
cat /sys/class/backlight/ae94000.dsi.0/brightness
echo "=== 网络"
nmcli -t -f DEVICE,STATE,CONNECTION device status 2>/dev/null | head
ip -br addr show wlan0 2>/dev/null
echo "=== 连通性"
ping -c2 -W3 223.5.5.5 2>&1 | tail -3
echo "=== 屏幕内容（framebuffer 信息）"
fbset 2>/dev/null | head -5 || cat /sys/class/graphics/fb0/virtual_size
' 2>&1 | grep -v Warning | head -40
