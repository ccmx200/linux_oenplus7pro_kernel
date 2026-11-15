#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 90
for i in 1 2 3 4 5; do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo --ath10k
dmesg | grep -iE "ath10k|wcn|qmi" | tail -20
echo --qrtr
qrtr-lookup 2>/dev/null | head -8
echo --net
ip -br link | head -6
echo --ieee
ls /sys/class/ieee80211 2>/dev/null
' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "try $i down"; sleep 15
done
echo DOWN
