#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 推送 panel DTB"
sshpass -p 1234 scp $OPTS /root/new-guac-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; ls -lh /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb; reboot' 2>&1 | grep -v Warning
echo "=== 等待重启"
sleep 50
for i in 1 2 3 4 5 6; do
    out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'ls /sys/class/drm/; echo ---; dmesg | grep -iE "msm|dpu|dsi|ams639|labibb" | tail -12' 2>/dev/null)
    if [ -n "$out" ]; then echo "$out"; exit 0; fi
    echo "try $i down"; sleep 12
done
echo DOWN
