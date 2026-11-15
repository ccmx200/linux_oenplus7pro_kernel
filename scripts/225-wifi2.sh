#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
W=/proc/device-tree/soc@0/wifi@18800000
echo "=== DT properties"
for p in compatible firmware-name qcom,msa-fixed-perm qcom,coexist-support status; do
  printf "%-24s " "$p"; tr -d "\0" < $W/$p 2>/dev/null; echo
done
echo
echo "=== 重新绑定并抓完整日志"
D=/sys/bus/platform/drivers/ath10k_snoc
echo 18800000.wifi > $D/unbind 2>/dev/null; sleep 1
dmesg -C
echo 18800000.wifi > $D/bind 2>&1
sleep 10
dmesg | tail -30
echo "=== 接口"
ip -br link
' 2>&1 | grep -v Warning | head -60
