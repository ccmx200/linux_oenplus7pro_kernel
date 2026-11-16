#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== uptime/model"
uptime
tr -d "\0" < /proc/device-tree/model; echo
echo "=== dsi/panel 节点状态"
tr -d "\0" < /proc/device-tree/soc@0/dsi@ae94000/status 2>/dev/null; echo
ls /proc/device-tree/soc@0/dsi@ae94000/ 2>/dev/null | head
ls /proc/device-tree/soc@0/dsi@ae94000/panel@0 2>/dev/null && echo PANEL_NODE_OK || echo NO_PANEL_NODE
echo "=== dmesg 尾部"
dmesg | tail -25
' 2>&1 | grep -v Warning | head -50
