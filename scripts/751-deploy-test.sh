#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
K=/root/kbuild/linux/drivers/net/wireless/ath/ath10k
for i in $(seq 1 8); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && break
  echo wait$i; sleep 12
done
DEST=/lib/modules/7.3.0-sm8150-g8611da353242-dirty/kernel/drivers/net/wireless/ath/ath10k
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "mkdir -p $DEST" 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS "$K/ath10k_core.ko" "$K/ath10k_snoc.ko" root@172.16.42.1:$DEST/ 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
DEST=/lib/modules/7.3.0-sm8150-g8611da353242-dirty/kernel/drivers/net/wireless/ath/ath10k
ls -lh $DEST/ath10k_core.ko $DEST/ath10k_snoc.ko
depmod -a
echo "=== 卸载旧模块（若已加载）"
rmmod ath10k_snoc 2>/dev/null; rmmod ath10k_core 2>/dev/null
dmesg -C
echo "=== 加载新模块"
modprobe ath10k_snoc
sleep 18
echo "--- 日志"
dmesg | grep -iE "ath10k|wlan_process|msa|board|dummy" | head -30
echo "--- wlan0"
ip -br link | grep -i wlan || echo none
echo "--- 扫描"
iw dev wlan0 scan 2>/dev/null | grep -m6 "SSID\|signal" || nmcli -f SSID,SIGNAL dev wifi list 2>/dev/null | head -10
' 2>&1 | grep -v Warning | head -50
