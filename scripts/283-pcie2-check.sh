#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 部署 pcie2（带 gpio/供电）"
sshpass -p 1234 scp $OPTS /root/pcie2-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
sleep 90
for i in 1 2 3 4 5; do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP; echo --lspci; lspci 2>/dev/null | head -5; echo --dmesg; dmesg | grep -iE "pcie|pci " | tail -12' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "try $i down"; sleep 15
done
echo DOWN
