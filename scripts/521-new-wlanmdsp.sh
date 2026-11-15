#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 推送本机 wlanmdsp.mbn"
sshpass -p 1234 scp $OPTS /root/modemfw/wlanmdsp.mbn root@172.16.42.1:/tmp/wlanmdsp-new.mbn 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
A=/lib/firmware/ath10k/WCN3990/hw1.0
Q=/lib/firmware/qcom/sm8150/oneplus7
cp -f /tmp/wlanmdsp-new.mbn $A/wlanmdsp.mbn
cp -f /tmp/wlanmdsp-new.mbn $Q/wlanmdsp.mbn
ls -lh $A/wlanmdsp.mbn $Q/wlanmdsp.mbn
sync; reboot
' 2>&1 | grep -v Warning
echo rebooting
sleep 100
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- wlan0"; ip -br link | grep -i wlan || echo none
echo "--- ath10k"; dmesg | grep -iE "ath10k|wmi|qmi" | tail -12
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo "down $i"; sleep 15
done
echo DOWN
