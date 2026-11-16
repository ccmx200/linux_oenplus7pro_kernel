#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS /root/kexec-arm64 root@172.16.42.1:/usr/local/sbin/kexec 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/panel3-final.dtb root@172.16.42.1:/boot/dtbs/qcom/guac-panel.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
chmod +x /usr/local/sbin/kexec
echo "=== kexec 版本"
kexec --version 2>&1 | head -2
echo "=== 面板 DTB"
ls -lh /boot/dtbs/qcom/guac-panel.dtb
echo "=== 当前内核/DTB"
ls -lh /boot/vmlinuz /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb
' 2>&1 | grep -v Warning | head -20
