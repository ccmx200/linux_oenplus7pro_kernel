#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 移除黑名单，恢复开机自动加载"
rm -f /etc/modprobe.d/blacklist-ath10k.conf
echo "=== 保留工作固件清单"
A=/lib/firmware/ath10k/WCN3990/hw1.0
Q=/lib/firmware/qcom/sm8150/oneplus7
ls -lh $A/board-2.bin $A/firmware-5.bin $Q/wlanmdsp.mbn $Q/modem.mdt 2>/dev/null
sync; reboot
' 2>&1 | grep -v Warning | head -12
echo "=== 等待重启并验证自动扫描"
sleep 110
for i in $(seq 1 8); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP; ip -br link | grep -i wlan; nmcli -f SSID,SIGNAL dev wifi list 2>/dev/null | head -6; dmesg | grep -iE "wlan_process|firmware crashed" | tail -3' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo down$i; sleep 15
done
echo DOWN
