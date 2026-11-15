#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "--- update-initramfs 存在?"
which update-initramfs mkinitramfs
echo "--- 运行"
update-initramfs -u 2>&1 | tail -10
echo "--- 结果 hash"
rm -rf /tmp/irx && mkdir -p /tmp/irx
cd /tmp/irx && unmkinitramfs /boot/initrd.img /tmp/irx 2>/dev/null
find /tmp/irx -name "pwrseq-qcom-wcn.ko" -exec sha256sum {} \; 2>/dev/null | head -3
' 2>&1 | grep -v Warning | head -30
