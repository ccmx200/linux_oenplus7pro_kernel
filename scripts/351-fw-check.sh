#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 固件目录"
ls -lh /lib/firmware/ath10k/WCN3990/hw1.0/ 2>/dev/null || echo "无固件目录!"
echo "=== 固件加载相关日志"
dmesg | grep -iE "firmware|direct firmware" | tail -10
echo "=== qmi 服务名（驱动请求）"
strings /lib/modules/$(uname -r)/kernel/drivers/net/wireless/ath/ath10k/ath10k_snoc.ko 2>/dev/null | grep -iE "wlfw|wlanmdsp|qcom/" | head -8
' 2>&1 | grep -v Warning | head -40
