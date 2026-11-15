#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 100
for i in 1 2 3 4 5; do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- lspci"; lspci 2>/dev/null | head -6
echo "--- pcie dmesg"; dmesg | grep -iE "pcie|pci " | tail -18
echo "--- deferred"; cat /sys/kernel/debug/devices_deferred 2>/dev/null | head -5
' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "try $i down"; sleep 15
done
echo DOWN
