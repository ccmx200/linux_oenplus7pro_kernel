#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sleep 100
for i in 1 2 3 4 5; do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- pci devices"; ls /sys/bus/pci/devices
echo "--- link speed/width"
cat /sys/bus/pci/devices/0000:00:00.0/current_link_speed 2>/dev/null
cat /sys/bus/pci/devices/0000:00:00.0/current_link_width 2>/dev/null
echo "--- dmesg link"
dmesg | grep -iE "pcie|link|ltssm" | tail -12
' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "try $i down"; sleep 15
done
echo DOWN
