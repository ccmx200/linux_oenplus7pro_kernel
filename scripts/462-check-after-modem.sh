#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
sleep 110
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- remoteproc"; for r in /sys/class/remoteproc/*; do echo "$(basename $r) $(cat $r/state) $(cat $r/firmware 2>/dev/null)"; done
echo "--- mpss dmesg"; dmesg | grep -iE "mpss|q6v5|remoteproc|modem" | tail -10
echo "--- qrtr"; qrtr-lookup 2>/dev/null | tail -10
echo "--- wlan"; ip -br link | grep -i wlan || echo none
echo "--- ath10k"; dmesg | grep -iE "ath10k|wlfw|qmi" | tail -10
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo "down $i"; sleep 15
done
echo DOWN
