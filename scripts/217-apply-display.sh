#!/bin/bash
set -u
KEYOPT="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no"
echo "=== 备份并替换 DTB"
sshpass -p 1234 ssh $KEYOPT root@172.16.42.1 'cp -f /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb.bak && echo backed-up' 2>&1 | grep -v Warning
sshpass -p 1234 scp $KEYOPT /root/dev-guac-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $KEYOPT root@172.16.42.1 'sync; ls -lh /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb; ls -lh /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb.bak' 2>&1 | grep -v Warning
echo "=== 重启"
sshpass -p 1234 ssh $KEYOPT root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
sleep 45
echo "=== 重启后检查"
sshpass -p 1234 ssh -o ConnectTimeout=10 $KEYOPT root@172.16.42.1 'ls /sys/class/drm/; dmesg | grep -iE "msm|dpu|dsi|panel" | tail -15' 2>&1 | grep -v Warning | head -25
