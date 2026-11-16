#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
for i in $(seq 1 12); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo wait$i; sleep 12
done
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== modem"
cat /sys/class/remoteproc/remoteproc0/state 2>/dev/null
echo "=== aoss-qmp / qdss"
dmesg | grep -iE "aoss|qmp" | tail -5
ls /sys/kernel/debug/clk 2>/dev/null >/dev/null && grep -iE "qdss|rf_clk" /sys/kernel/debug/clk/clk_summary 2>/dev/null | head -8 || echo "(clk debugfs 不可用)"
echo "=== wifi 节点 clocks"
tr -d "\0" < /proc/device-tree/soc@0/wifi@18800000/clock-names 2>/dev/null; echo
echo "=== 加载测试"
dmesg -C
modprobe ath10k_snoc 2>&1
sleep 15
dmesg | grep -iE "ath10k|wlan_process|msa|clk" | head -18
ip -br link | grep -i wlan || echo no-wlan
' 2>&1 | grep -v Warning | head -45
