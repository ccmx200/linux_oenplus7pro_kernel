#!/bin/bash
# 一键：OEM 固件 + 自制 board-2 + skip/no-msa DTB → 重启 → 测试扫描
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
SRC=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out/sm8150-guac-skip-nomsa.dtb
FW=/lib/firmware/ath10k/WCN3990/hw1.0

echo "=== 等设备"
for i in $(seq 1 10); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo wait$i; sleep 10
done
[ -f "$SRC" ] || { echo "缺 DTB"; exit 1; }

echo "=== 部署 DTB / 固件 / board-2"
sshpass -p 1234 scp $OPTS "$SRC" root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/modemfw/wlanmdsp.mbn root@172.16.42.1:/tmp/wlanmdsp-oem.mbn 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/board-2-ours.bin root@172.16.42.1:/tmp/board-2-ours.bin 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "
cp -f /tmp/wlanmdsp-oem.mbn $FW/wlanmdsp.mbn
cp -f /tmp/board-2-ours.bin $FW/board-2.bin
ls -lh $FW/wlanmdsp.mbn $FW/board-2.bin
sync; reboot" 2>&1 | grep -v Warning
echo "rebooted"

sleep 100
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- wlan0"; ip -br link | grep -i wlan || echo none
echo "--- ath10k"; dmesg | grep -iE "ath10k|wmi|qmi|board" | tail -12
echo "--- scan"
nmcli radio wifi on 2>&1 | head -2
timeout 25 nmcli -f SSID,SIGNAL dev wifi list 2>&1 | head -12
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo "down $i"; sleep 15
done
echo DOWN
