#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== raphael 固件目录"
ls /lib/firmware/qcom/sm8150/Xiaomi/raphael | head -8
echo "=== modem.mdt?"
ls -l /lib/firmware/qcom/sm8150/Xiaomi/raphael/modem.mdt 2>/dev/null || echo "no modem.mdt"
echo "=== mpss dmesg"
dmesg | grep -iE "mpss|remoteproc|q6v5|modem" | tail -10
echo "=== qrtr"
qrtr-lookup 2>/dev/null | tail -8
echo "=== wlan"
ip -br link | grep -i wlan || echo none
' 2>&1 | grep -v Warning | head -40
