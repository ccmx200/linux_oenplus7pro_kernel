#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== AP 的 HT/VHT 能力"
iw dev wlan0 scan 2>/dev/null | awk "/SSID: cuicanmx_5G/,/DS Parameter set/" | grep -iE "VHT|HT |MCS|Channel width|NSS|Streams|80MHz|160" | head -25
echo
echo "=== 连续采样链路速率"
for i in 1 2 3 4 5; do iw dev wlan0 link 2>/dev/null | grep -E "rx bitrate|signal:"; sleep 2; done
' 2>&1 | grep -v Warning | head -45
