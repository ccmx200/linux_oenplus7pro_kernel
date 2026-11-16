#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== VHT 能力（RX/TX MCS）"
iw phy phy0 info 2>/dev/null | sed -n "/VHT Capabilities/,/Band/p" | head -30
echo
echo "=== 支持的接口/信道"
iw dev wlan0 info 2>&1 | head -10
echo "=== tx bitrate（station）"
iw dev wlan0 station dump 2>&1 | grep -iE "bitrate|tx.*MCS|expected throughput"
echo "=== 链路质量"
iw dev wlan0 link 2>&1 | head -12
echo "=== 模块参数/校准"
dmesg | grep -iE "ath10k.*(cal|chain|antenna|bdf|board)" | tail -10
' 2>&1 | grep -v Warning | head -60
