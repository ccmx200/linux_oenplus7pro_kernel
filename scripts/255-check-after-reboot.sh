#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
for i in $(seq 1 8); do
    out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP; ls /sys/class/drm/; echo ---DTB---; ls -lh /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb; echo ---DMESG---; dmesg | grep -iE "msm|dpu|dsi|ams639|labibb|panel" | tail -20' 2>/dev/null)
    if [ -n "$out" ]; then echo "$out"; exit 0; fi
    echo "try $i: down"; sleep 10
done
echo DOWN
