#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo 0xffffffff > /sys/module/ath10k_core/parameters/debug_mask 2>/dev/null && echo "debug on"
D=/sys/bus/platform/drivers/ath10k_snoc
echo 18800000.wifi > $D/unbind 2>/dev/null; sleep 1
dmesg -C
echo 18800000.wifi > $D/bind; echo bind=$?
sleep 20
echo "=== dmesg"
dmesg | tail -40
echo "=== qrtr"
qrtr-lookup 2>/dev/null | tail -6
' 2>&1 | grep -v Warning | head -60
