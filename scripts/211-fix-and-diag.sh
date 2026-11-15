#!/bin/bash
set -u
S() { sshpass -p 1234 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8 root@172.16.42.1 "$@"; }

echo "=== 修 .ssh 权限"
S 'chown -R user:user /home/user/.ssh; chmod 700 /home/user/.ssh; chmod 600 /home/user/.ssh/authorized_keys; ls -ld /home/user/.ssh'

echo
echo "=== drm / fb"
S 'ls /sys/class/drm/; echo ---; cat /proc/fb; echo ---; ls /sys/class/backlight 2>/dev/null; echo ---; dmesg | grep -iE "msm|dpu|mdss|dsi|panel|backlight|drm" | tail -30'
