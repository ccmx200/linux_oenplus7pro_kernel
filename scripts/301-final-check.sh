#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 驱动绑定"
ls -l /sys/bus/platform/drivers/ath10k_snoc/ | grep 1880 || echo "未绑定"
echo "=== wifi 相关 dmesg"
dmesg | grep -iE "wifi|wcn|ath10k|pwrseq" | tail -15
echo "=== 供电是否还是 dummy"
dmesg | grep -c "dummy regulator"
echo "=== qrtr"
qrtr-lookup 2>/dev/null | tail -5
' 2>&1 | grep -v Warning | head -40
