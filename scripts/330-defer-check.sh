#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== deferred 设备"
cat /sys/kernel/debug/devices_deferred 2>/dev/null | grep -i wifi || echo "(无 wifi defer 记录)"
echo "=== wifi 节点里的 pwrseq 属性"
ls /proc/device-tree/soc@0/wifi@18800000/ | tr "\0" "\n" | grep -i pwrseq || echo "节点里没有 pwrseq 属性!"
echo "=== pwrseq 节点"
ls /proc/device-tree/pwrseq/ 2>/dev/null
echo "=== pwrseq 驱动模块信息"
modinfo pwrseq-qcom-wcn 2>/dev/null | head -6
echo "=== ath10k probe 日志(全量含 defer)"
dmesg | grep -iE "18800000|wifi|wcn|pwrseq|defer" | tail -20
' 2>&1 | grep -v Warning | head -60
