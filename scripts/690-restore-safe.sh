#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 等 SSH"
for i in $(seq 1 12); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo wait$i; sleep 10
done

echo "=== 部署固件（不含裸 board.bin）"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'D=/lib/firmware/qcom/sm8150/oneplus7; rm -rf $D; mkdir -p $D; A=/lib/firmware/ath10k/WCN3990/hw1.0; mkdir -p $A; rm -f $A/board.bin' 2>&1 | grep -v Warning
sshpass -p 1234 scp -r $OPTS /root/guacfw/. root@172.16.42.1:/lib/firmware/qcom/sm8150/oneplus7/ 2>&1 | grep -v Warning | tail -1
sshpass -p 1234 scp $OPTS /root/ath10kfw/board-2.bin root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/wr-patched.dtb root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning

echo "=== 配置手动启动 wifi"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
A=/lib/firmware/ath10k/WCN3990/hw1.0
D=/lib/firmware/qcom/sm8150/oneplus7
cp -f $D/wlanmdsp.mbn $A/wlanmdsp.mbn
rm -f $A/board.bin
cat > /etc/modprobe.d/blacklist-ath10k.conf <<EOF
blacklist ath10k_snoc
blacklist ath10k_core
blacklist ath10k
EOF
cat > /usr/local/sbin/wifi-on.sh <<EOF
#!/bin/sh
# 手动启动 WiFi（避免开机自动加载导致 modem 崩溃）
set -e
modprobe ath10k_snoc
sleep 2
ip link set wlan0 up 2>/dev/null || true
nmcli radio wifi on 2>/dev/null || true
sleep 1
ip -br link | grep wlan || true
EOF
chmod +x /usr/local/sbin/wifi-on.sh
ls -l /etc/modprobe.d/blacklist-ath10k.conf /usr/local/sbin/wifi-on.sh
ls -lh $A/board-2.bin $A/wlanmdsp.mbn
ls $A/board.bin 2>/dev/null && echo "警告: board.bin 仍存在" || echo "board.bin 已移除"
sync; reboot
' 2>&1 | grep -v Warning
echo rebooted
