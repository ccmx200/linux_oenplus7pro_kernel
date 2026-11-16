#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 设备状态"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'uptime; ls -lh /boot/vmlinuz /boot/initrd.img /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb; uname -r' 2>&1 | grep -v Warning
echo "=== 取回原内核"
sshpass -p 1234 scp $OPTS root@172.16.42.1:/boot/vmlinuz /root/vmlinuz-ondevice 2>&1 | grep -v Warning
ls -lh /root/vmlinuz-ondevice
file /root/vmlinuz-ondevice
xxd -l 64 /root/vmlinuz-ondevice
echo "=== 与新 Image 对比"
file /root/kbuild/linux/arch/arm64/boot/Image
xxd -l 64 /root/kbuild/linux/arch/arm64/boot/Image
