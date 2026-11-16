#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== qrtr 里的 WLAN 服务"
qrtr-lookup 2>/dev/null | grep -iE "ath|wlan" || echo "no WLFW"
echo "=== wifi-kick 服务"
systemctl is-enabled wifi-kick.service 2>/dev/null; systemctl status wifi-kick.service --no-pager 2>/dev/null | head -6
echo "=== modem wlan_process 崩溃"
dmesg | grep -icE "grace timer"
echo "=== 手动 kick（若服务在）"
if qrtr-lookup 2>/dev/null | grep -qiE "ath|wlan"; then
  D=/sys/bus/platform/drivers/ath10k_snoc
  echo 18800000.wifi > $D/unbind 2>/dev/null; sleep 1
  echo 18800000.wifi > $D/bind
  sleep 12
  dmesg | grep -iE "ath10k" | tail -10
  ip -br link | grep -i wlan || echo still-none
else
  echo "WLFW 不在，跳过"
fi
' 2>&1 | grep -v Warning | head -50
