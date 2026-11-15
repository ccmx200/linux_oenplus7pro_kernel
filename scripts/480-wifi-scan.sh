#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 无线工具"
for t in iw iwconfig nmcli wpa_supplicant; do printf "%-16s %s\n" "$t" "$(command -v $t || echo missing)"; done
echo "=== 拉起 wlan0"
ip link set wlan0 up 2>&1
sleep 2
ip -br link | grep -i wlan
echo "=== 扫描（iw）"
if command -v iw >/dev/null; then
  timeout 20 iw dev wlan0 scan 2>&1 | grep -E "SSID|signal" | head -20
else
  echo "no iw"
fi
echo "=== dmesg tail"
dmesg | grep -iE "ath10k|wlan" | tail -12
' 2>&1 | grep -v Warning | head -50
