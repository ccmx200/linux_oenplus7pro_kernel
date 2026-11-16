#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 等设备（fastboot 由外部清理）"
for i in $(seq 1 15); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo wait$i; sleep 10
done
echo "=== 换回稳定 DTB（no-msa）"
sshpass -p 1234 scp $OPTS /root/wq-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
echo "=== 确认黑名单 + 移除裸 board.bin"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
A=/lib/firmware/ath10k/WCN3990/hw1.0
rm -f $A/board.bin
cat /etc/modprobe.d/blacklist-ath10k.conf
ls -lh $A/board-2.bin $A/wlanmdsp.mbn
sync; reboot' 2>&1 | grep -v Warning
echo rebooted
