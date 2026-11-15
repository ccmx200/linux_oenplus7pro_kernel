#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== 内核配置里的 icnss / ath11k"
grep -E '^CONFIG_(QCOM_ICNSS|ATH11K|ATH11K_PCI|ATH11K_AHB|ATH11K_DEBUG|QRTR|MHI)' "$K/.config" | sort
echo
echo "=== 源码里有没有 icnss / ath11k"
ls "$K/drivers/net/wireless/ath/" 2>/dev/null
ls -d "$K/drivers/net/wireless/ath/ath11k" "$K/drivers/soc/qcom/icnss"* 2>/dev/null
echo
echo "=== 设备当前节点 compatible"
sshpass -p 1234 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no root@172.16.42.1 'tr -d "\0" < /proc/device-tree/soc@0/wifi@18800000/compatible; echo; ls /lib/firmware/ath11k 2>/dev/null; ls /lib/firmware/qcom/qca6390 2>/dev/null' 2>&1 | grep -v Warning
