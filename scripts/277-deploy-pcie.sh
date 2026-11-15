#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
D=/root/pcie-guac-patched.dtb
echo "=== 部署 PCIe DTB"
sshpass -p 1234 scp $OPTS "$D" root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; ls -lh /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb; reboot' 2>&1 | grep -v Warning
echo "=== 等待 90s 后检查"
sleep 90
for i in 1 2 3 4 5 6; do
    out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP; echo "--- lspci"; lspci 2>/dev/null | head; echo "--- pcie dmesg"; dmesg | grep -iE "pcie|pci " | tail -15' 2>/dev/null)
    if [ -n "$out" ]; then echo "$out"; exit 0; fi
    echo "try $i down"; sleep 15
done
echo DOWN
