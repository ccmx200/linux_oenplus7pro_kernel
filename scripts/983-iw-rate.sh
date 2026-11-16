#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS /root/iw-arm64 root@172.16.42.1:/usr/local/sbin/iw 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
chmod +x /usr/local/sbin/iw
echo "=== libnl"
ldconfig -p 2>/dev/null | grep -c libnl
echo "=== iw link"
iw dev wlan0 link 2>&1 | head -20
echo "=== station dump"
iw dev wlan0 station dump 2>&1 | head -30
echo "=== phy info (能力)"
iw phy phy0 info 2>/dev/null | grep -A6 -E "Band 2|Band 1" | head -30
' 2>&1 | grep -v Warning | head -70
