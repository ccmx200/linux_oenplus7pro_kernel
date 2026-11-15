#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== pwrseq 模块/驱动"
lsmod | grep -i pwrseq || echo "pwrseq 模块未加载"
ls /sys/bus/platform/drivers/ | grep -i pwrseq || echo "无 pwrseq 驱动"
echo "=== 尝试加载"
modprobe pwrseq-qcom-wcn 2>&1 | head -3
sleep 2
ls /sys/bus/platform/drivers/ | grep -i pwrseq
dmesg | grep -i pwrseq | tail -5
echo "=== 重新绑定 wifi"
D=/sys/bus/platform/drivers/ath10k_snoc
[ -d $D ] && { echo 18800000.wifi > $D/unbind 2>/dev/null; sleep 1; dmesg -C; echo 18800000.wifi > $D/bind; echo "bind rc=$?"; }
sleep 12
dmesg | grep -iE "ath10k|pwrseq|qmi|wcn" | tail -20
echo "=== qrtr"
qrtr-lookup 2>/dev/null | tail -6
' 2>&1 | grep -v Warning | head -60
