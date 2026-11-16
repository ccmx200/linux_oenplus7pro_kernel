#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 当前 wifi"
ip -br link | grep -i wlan || echo none
echo "=== kexec 加载（详细）"
kexec -l /boot/vmlinuz --initrd=/boot/initrd.img --dtb=/boot/dtbs/qcom/guac-panel.dtb --reuse-cmdline; echo "rc=$?"
echo "loaded=$(cat /sys/kernel/kexec_loaded)"
echo "=== 尝试 file_load"
kexec -l -s /boot/vmlinuz --initrd=/boot/initrd.img --dtb=/boot/dtbs/qcom/guac-panel.dtb --reuse-cmdline; echo "rc_s=$?"
echo "loaded=$(cat /sys/kernel/kexec_loaded)"
' 2>&1 | grep -v Warning | head -25
