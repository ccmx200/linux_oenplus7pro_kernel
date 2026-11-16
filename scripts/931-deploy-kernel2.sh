#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
K=/root/kbuild/linux
SRC=$K/arch/arm64/boot/Image
SHA=$(sha256sum "$SRC" | cut -d' ' -f1)
echo "local sha: $SHA"
echo "=== 先铺固件（WiFi）"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'D=/lib/firmware/qcom/sm8150/oneplus7; rm -rf $D; mkdir -p $D; A=/lib/firmware/ath10k/WCN3990/hw1.0; mkdir -p $A; rm -f $A/board.bin' 2>&1 | grep -v Warning
sshpass -p 1234 scp -r $OPTS /root/guacfw/. root@172.16.42.1:/lib/firmware/qcom/sm8150/oneplus7/ 2>&1 | grep -v Warning | tail -1
sshpass -p 1234 scp $OPTS /root/hotdog-fw/wlanmdsp.mbn root@172.16.42.1:/lib/firmware/qcom/sm8150/oneplus7/wlanmdsp.mbn 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/hotdog-fw/board-2.bin /root/hotdog-fw/firmware-5.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/ 2>&1 | grep -v Warning
KV=7.3.0-sm8150-g8611da353242-dirty
DEST=/lib/modules/$KV/kernel/drivers/net/wireless/ath/ath10k
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "mkdir -p $DEST" 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS $K/drivers/net/wireless/ath/ath10k/ath10k_core.ko $K/drivers/net/wireless/ath/ath10k/ath10k_snoc.ko root@172.16.42.1:$DEST/ 2>&1 | grep -v Warning
echo "=== 部署内核（带校验）"
sshpass -p 1234 scp $OPTS "$SRC" root@172.16.42.1:/boot/vmlinuz.new 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "
cd /boot
REMOTE=\$(sha256sum vmlinuz.new | cut -d' ' -f1)
echo remote=\$REMOTE
[ \"\$REMOTE\" = \"$SHA\" ] && { cp -f vmlinuz vmlinuz.bak; mv -f vmlinuz.new vmlinuz; echo KERNEL_OK; } || { echo KERNEL_MISMATCH; rm -f vmlinuz.new; }
depmod -a
rm -f /etc/modprobe.d/blacklist-ath10k.conf
ls -lh /boot/vmlinuz /boot/vmlinuz.bak
sync; reboot" 2>&1 | grep -v Warning
echo "=== 等待启动"
sleep 115
for i in $(seq 1 8); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP; uname -r; ip -br link | grep -i wlan || echo no-wlan; nmcli -f SSID dev wifi list 2>/dev/null | head -4' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo down$i; sleep 15
done
echo DOWN
