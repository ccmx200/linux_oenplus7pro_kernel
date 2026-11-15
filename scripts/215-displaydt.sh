#!/bin/bash
set -u
S() { sshpass -p 1234 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      -o PreferredAuthentications=password -o PubkeyAuthentication=no root@172.16.42.1 "$@"; }
echo "=== 平台设备/driver"
S 'ls /sys/bus/platform/devices | grep -iE "mdss|dpu|dsi|disp" ; echo ---; ls /sys/bus/platform/drivers/msm-mdss /sys/bus/platform/drivers/msm_dpu 2>/dev/null; echo ---'
echo "=== DT 里 display 状态"
S 'for n in /proc/device-tree/soc@0/display-subsystem@ae00000 /proc/device-tree/soc@0/display-subsystem@ae00000/dsi@ae94000; do echo "$n:"; cat "$n/status" 2>/dev/null; echo; done; ls /proc/device-tree/soc@0/display-subsystem@ae00000/ 2>/dev/null'
echo "=== 是否有 panel 节点"
S 'find /proc/device-tree -maxdepth 6 -name "*panel*" 2>/dev/null | head'
