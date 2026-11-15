#!/bin/bash
set -u
IMG="/mnt/d/Flyme9_ArtChen_9008FlashPackage/Flyme9_ArtChen_9008FlashPackage/images/modem.img"
M=/mnt/modemimg
mkdir -p "$M"
mountpoint -q "$M" || mount -o ro,loop "$IMG" "$M" || { echo "mount fail"; exit 1; }
echo "=== 固件文件数"; ls "$M/image" | wc -l
echo "=== modem 相关"; ls "$M/image" | grep -E '^modem\.|^mba\.' | head -8
rm -rf /root/modemfw; mkdir -p /root/modemfw
cp -a "$M/image/." /root/modemfw/
umount "$M"
du -sh /root/modemfw

OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 设备空间"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'df -h / | tail -1' 2>&1 | grep -v Warning
echo "=== 推送固件"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'D=/lib/firmware/qcom/sm8150/oneplus7; [ -L $D ] && rm -f $D; mkdir -p $D; echo ok' 2>&1 | grep -v Warning
sshpass -p 1234 scp -r $OPTS /root/modemfw/. root@172.16.42.1:/lib/firmware/qcom/sm8150/oneplus7/ 2>&1 | grep -v Warning | tail -2
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'ls /lib/firmware/qcom/sm8150/oneplus7/modem.mdt && du -sh /lib/firmware/qcom/sm8150/oneplus7' 2>&1 | grep -v Warning
