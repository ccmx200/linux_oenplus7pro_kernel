#!/bin/bash
set -u
echo "=== WSL 接口"
ip -4 -o addr show | sed 's/  */ /g' | cut -d' ' -f2,4
echo "=== ping"
ping -c 2 -W 2 172.16.42.1 2>&1 | tail -2
echo "=== sshpass 密码登录"
sshpass -p 1234 timeout 20 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -o PreferredAuthentications=password -o PubkeyAuthentication=no user@172.16.42.1 \
    'uname -r; cat /proc/fb; echo ---; ip -4 addr show usb0 | grep inet; echo ---; ls -ld /home/user /home/user/.ssh 2>/dev/null' 2>&1 | tail -12
