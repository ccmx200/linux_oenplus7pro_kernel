#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS /root/hotdog-fw/board-2.bin /root/hotdog-fw/firmware-5.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/ 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/hotdog-fw/wlanmdsp.mbn root@172.16.42.1:/lib/firmware/qcom/sm8150/oneplus7/wlanmdsp.mbn 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
A=/lib/firmware/ath10k/WCN3990/hw1.0
rm -f $A/board.bin
ls -lh $A/board-2.bin $A/firmware-5.bin /lib/firmware/qcom/sm8150/oneplus7/wlanmdsp.mbn
rmmod ath10k_snoc 2>/dev/null; rmmod ath10k_core 2>/dev/null
sleep 1
dmesg -C
modprobe ath10k_snoc
sleep 18
echo "--- 日志"
dmesg | grep -iE "ath10k|wlan_process|msa" | head -22
echo "--- wlan0"
ip -br link | grep -i wlan || echo none
echo "--- 扫描"
iw dev wlan0 scan 2>/dev/null | grep -m6 "SSID" || nmcli -f SSID dev wifi list 2>/dev/null | head -10
' 2>&1 | grep -v Warning | head -40
