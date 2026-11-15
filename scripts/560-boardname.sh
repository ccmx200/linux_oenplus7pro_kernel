#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 换回 Android 版 wlanmdsp"
sshpass -p 1234 scp $OPTS /root/modemfw/wlanmdsp.mbn root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/wlanmdsp.mbn 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
sleep 95
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo 0xffffffff > /sys/module/ath10k_core/parameters/debug_mask 2>/dev/null
D=/sys/bus/platform/drivers/ath10k_snoc
echo 18800000.wifi > $D/unbind 2>/dev/null; sleep 1
dmesg -C
echo 18800000.wifi > $D/bind
sleep 20
echo "--- board name / qmi"
dmesg | grep -iE "board name|qmi chip|qmi-board|board_file|variant" | head -12
echo "--- wlan"; ip -br link | grep -i wlan || echo none
echo "--- tail"; dmesg | grep -iE "ath10k" | tail -8
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo "down $i"; sleep 15
done
echo DOWN
