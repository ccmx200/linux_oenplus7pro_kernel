#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== PCI 设备"
ls /sys/bus/pci/devices 2>/dev/null | head; lspci 2>/dev/null | head
echo "=== DT 里 pcie 节点"
for p in /proc/device-tree/soc@0/pci@1c00000 /proc/device-tree/soc@0/pcie@1c00000; do [ -d "$p" ] && { echo "$p -> $(tr -d "\0" < $p/status 2>/dev/null)"; }; done
ls /proc/device-tree/soc@0 | grep -i pci
echo "=== 有没有 MHI / ath11k 模块"
ls /lib/modules/$(uname -r)/kernel/drivers/bus/mhi 2>/dev/null | head -3
ls /lib/modules/$(uname -r)/kernel/drivers/net/wireless/ath/ath11k 2>/dev/null | head -5
echo "=== 固件目录"
ls /lib/firmware/ath11k 2>/dev/null; ls /lib/firmware/qcom/qca6390 2>/dev/null
' 2>&1 | grep -v Warning | head -40
