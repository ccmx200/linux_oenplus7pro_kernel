#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
D=/lib/firmware/ath10k/WCN3990/hw1.0
command -v zstd >/dev/null || apt-get install -y -qq zstd >/dev/null 2>&1
for f in $D/*.zst; do zstd -d -f -q "$f" -o "${f%.zst}"; done
ls -lh $D
echo "=== 重载驱动"
echo 0xffffffff > /sys/module/ath10k_core/parameters/debug_mask 2>/dev/null
modprobe -r ath10k_snoc 2>/dev/null; sleep 2; dmesg -C; modprobe ath10k_snoc
sleep 25
echo "=== dmesg"
dmesg | tail -40
echo "=== qrtr"; qrtr-lookup 2>/dev/null | tail -8
echo "=== wlan"; ip -br link | grep -i wlan || echo none
' 2>&1 | grep -v Warning | head -70
