#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
mountpoint -q /sys/kernel/debug || mount -t debugfs none /sys/kernel/debug
echo "=== S4 是否注册"
grep -iE "s4|smps4|1p8" /sys/kernel/debug/regulator/regulator_summary 2>/dev/null | head -10
echo "=== pwrseq 相关日志"
dmesg | grep -iE "pwrseq|wcn|regulator.*(fail|error)" | tail -15
echo "=== wifi 节点 supply 解析"
W=/proc/device-tree/soc@0/wifi@18800000
for p in vdd-1.8-xo-supply vdd-1.3-rfa-supply vdd-3.3-ch0-supply vdd-3.3-ch1-supply vdd-0.8-cx-mx-supply; do printf "%-22s " "$p"; [ -e "$W/$p" ] && echo ok || echo MISSING; done
echo "=== pwrseq 节点 regulators 子节点"
ls /proc/device-tree/pwrseq/regulators 2>/dev/null
' 2>&1 | grep -v Warning | head -50
