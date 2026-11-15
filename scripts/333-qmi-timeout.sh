#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== pwrseq 设备绑定"
ls -l /sys/bus/platform/drivers/pwrseq-qcom_wcn/ 2>/dev/null | head -5
echo "=== 等 60s 看 QMI 超时"
sleep 60
dmesg | tail -25
echo "=== regulator 状态"
cat /sys/kernel/debug/regulator/regulator_summary 2>/dev/null | grep -E "vreg_l1a|vreg_l7a|vreg_l2c|vreg_l11c" | head -8
' 2>&1 | grep -v Warning | head -60
