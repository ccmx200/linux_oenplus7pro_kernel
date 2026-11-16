#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
K=/root/kbuild/linux/drivers/net/wireless/ath/ath10k
for i in $(seq 1 12); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo wait$i; sleep 12
done
echo "=== 固件目录"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'D=/lib/firmware/qcom/sm8150/oneplus7; rm -rf $D; mkdir -p $D; A=/lib/firmware/ath10k/WCN3990/hw1.0; mkdir -p $A; rm -f $A/board.bin; echo ok' 2>&1 | grep -v Warning
sshpass -p 1234 scp -r $OPTS /root/guacfw/. root@172.16.42.1:/lib/firmware/qcom/sm8150/oneplus7/ 2>&1 | grep -v Warning | tail -1
sshpass -p 1234 scp $OPTS /root/hotdog-fw/wlanmdsp.mbn root@172.16.42.1:/lib/firmware/qcom/sm8150/oneplus7/wlanmdsp.mbn 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/hotdog-fw/board-2.bin /root/hotdog-fw/firmware-5.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/ 2>&1 | grep -v Warning
KV=7.3.0-sm8150-g8611da353242-dirty
DEST=/lib/modules/$KV/kernel/drivers/net/wireless/ath/ath10k
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "mkdir -p $DEST" 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS "$K/ath10k_core.ko" "$K/ath10k_snoc.ko" root@172.16.42.1:$DEST/ 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
rm -f /etc/modprobe.d/blacklist-ath10k.conf
depmod -a
A=/lib/firmware/ath10k/WCN3990/hw1.0
Q=/lib/firmware/qcom/sm8150/oneplus7
ls -lh $A/board-2.bin $A/firmware-5.bin $Q/wlanmdsp.mbn $Q/modem.mdt
sync; reboot' 2>&1 | grep -v Warning
echo "=== 重启完成，等待验证"
sleep 115
for i in $(seq 1 8); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP; uptime
ip -br link | grep -i wlan || echo no-wlan
nmcli -f SSID,SIGNAL dev wifi list 2>/dev/null | head -6
dmesg | grep -icE "wlan_process|firmware crashed"
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo down$i; sleep 15
done
echo DOWN
