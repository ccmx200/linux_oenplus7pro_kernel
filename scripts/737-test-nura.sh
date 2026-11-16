#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 部署最简 wifi DTB"
sshpass -p 1234 scp $OPTS /root/wv-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
sleep 100
for i in $(seq 1 6); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo down$i; sleep 15
done
echo "=== 手动加载 ath10k（Nura 式 dummy regulator）"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
dmesg -C
modprobe ath10k_snoc 2>&1
sleep 15
echo "--- 日志"
dmesg | grep -iE "ath10k|wlan_process|board|msa|dummy|regulator" | head -25
echo "--- wlan0"
ip -br link | grep -i wlan || echo none
echo "--- 扫描"
iw dev wlan0 scan 2>/dev/null | grep -m5 SSID || nmcli -f SSID dev wifi list 2>/dev/null | head -8
' 2>&1 | grep -v Warning | head -45
