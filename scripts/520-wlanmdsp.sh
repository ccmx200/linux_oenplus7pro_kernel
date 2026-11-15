#!/bin/bash
set -u
echo "=== modemfw 里 wlanmdsp 文件"
ls -lh /root/modemfw | grep -i wlanmdsp
echo "=== 设备上现有 wlanmdsp"
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'ls -lh /lib/firmware/ath10k/WCN3990/hw1.0/ /lib/firmware/qcom/sm8150/oneplus7/wlanmdsp.bin 2>/dev/null | head -10' 2>&1 | grep -v Warning
