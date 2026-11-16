#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
DTB=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out/sm8150-guac-skip-nomsa.dtb
echo "=== 部署 board-2（bdencoder 生成）+ skip/no-msa DTB"
sshpass -p 1234 scp $OPTS /root/board-2-guac.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS "$DTB" root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
A=/lib/firmware/ath10k/WCN3990/hw1.0
rm -f $A/board.bin
ls -lh $A/board-2.bin $A/wlanmdsp.mbn
sync; reboot' 2>&1 | grep -v Warning
echo "=== 等待启动"
sleep 105
for i in $(seq 1 6); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo down$i; sleep 15
done
echo "=== 手动启动 WiFi 并观察"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
dmesg -C
modprobe ath10k_snoc 2>&1
sleep 12
echo "--- dmesg"
dmesg | grep -iE "ath10k|msa|board|wmi|qmi" | tail -20
echo "--- wlan0"
ip -br link | grep -i wlan || echo none
' 2>&1 | grep -v Warning | head -40
