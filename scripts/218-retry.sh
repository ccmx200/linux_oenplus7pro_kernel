#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=6"
for i in 1 2 3 4 5 6 7 8; do
    sleep 12
    out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP; ls /sys/class/drm/ 2>/dev/null; dmesg | grep -iE "msm|dpu|dsi|panel" | tail -8' 2>/dev/null)
    if [ -n "$out" ]; then
        echo "$out"
        exit 0
    fi
    echo "try $i: ssh down"
done
echo "SSH_STILL_DOWN"
