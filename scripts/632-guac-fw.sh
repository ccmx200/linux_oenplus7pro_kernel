#!/bin/bash
set -u
F=/root/opsout/NON-HLOS.bin
M=/mnt/nonhlos
mkdir -p "$M"; mountpoint -q "$M" || mount -o ro,loop "$F" "$M"
rm -rf /root/guacfw && mkdir -p /root/guacfw
cp -a "$M/image/." /root/guacfw/
umount "$M"
echo "=== 关键文件"
ls -lh /root/guacfw/wlanmdsp.mbn /root/guacfw/bdwlan.bin 2>/dev/null
ls /root/guacfw | grep -iE "modem\.|wlanmdsp|bdwlan\.bin" | head
echo "=== 推送整套固件"
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'D=/lib/firmware/qcom/sm8150/oneplus7; rm -rf $D; mkdir -p $D' 2>&1 | grep -v Warning
sshpass -p 1234 scp -r $OPTS /root/guacfw/. root@172.16.42.1:/lib/firmware/qcom/sm8150/oneplus7/ 2>&1 | grep -v Warning | tail -1
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
D=/lib/firmware/qcom/sm8150/oneplus7
ls -lh $D/wlanmdsp.mbn $D/bdwlan.bin 2>/dev/null
cp -f $D/wlanmdsp.mbn /lib/firmware/ath10k/WCN3990/hw1.0/wlanmdsp.mbn
ls -lh /lib/firmware/ath10k/WCN3990/hw1.0/wlanmdsp.mbn
sync; reboot' 2>&1 | grep -v Warning
echo rebooting
