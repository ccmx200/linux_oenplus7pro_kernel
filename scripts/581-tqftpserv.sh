#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== tqftpserv / rmtfs"
for t in tqftpserv rmtfs qrtr-ns; do printf "%-12s %s\n" "$t" "$(command -v $t || echo missing)"; done
ps -ef | grep -E "tqftpserv|rmtfs|qrtr" | grep -v grep
echo "=== systemd 单元"
systemctl list-units --all 2>/dev/null | grep -iE "tqftp|rmtfs|qrtr|rmt" | head -8
echo "=== modem 节点 firmware-name"
find /proc/device-tree -name "firmware-name" -path "*remoteproc*" 2>/dev/null | head -5
tr -d "\0" < /proc/device-tree/soc@0/remoteproc@4080000/firmware-name 2>/dev/null; echo
echo "=== 固件目录"
ls /lib/firmware/qcom/sm8150/oneplus7/ | grep -iE "modem|wlan|bdwlan" | head -10
' 2>&1 | grep -v Warning | head -45
