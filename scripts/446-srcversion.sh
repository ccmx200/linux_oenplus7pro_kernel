#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
F=/lib/modules/$(uname -r)/kernel/drivers/power/sequencing/pwrseq-qcom-wcn.ko
echo "--- file srcversion"; modinfo -F srcversion "$F"
echo "--- loaded srcversion"; cat /sys/module/pwrseq_qcom_wcn/srcversion 2>/dev/null
echo "--- initramfs 里的模块 hash"
rm -rf /tmp/irx && mkdir -p /tmp/irx
cd /tmp/irx && unmkinitramfs /boot/initrd.img /tmp/irx 2>/dev/null
find /tmp/irx -name "pwrseq-qcom-wcn.ko" -exec sha256sum {} \; 2>/dev/null | head -3
echo "--- pwrseq dmesg"
dmesg | grep -iE "pwrseq|wcn" | tail -8
' 2>&1 | grep -v Warning | head -25
