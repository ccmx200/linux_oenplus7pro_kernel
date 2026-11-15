#!/bin/bash
# 照抄 raphael：把 WCN3990 固件装到设备并重载 ath10k_snoc
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no"
R=/root/fw
rm -rf "$R"; mkdir -p "$R"
dpkg-deb -x /root/kernel-deb/firmware-xiaomi-raphael.deb "$R"
command -v zstd >/dev/null || apt-get install -y -qq zstd >/dev/null

# 解压所有 .zst 固件
find "$R" -name '*.zst' -print0 | while IFS= read -r -d '' f; do
    zstd -d -f -q "$f" -o "${f%.zst}"
done
echo "=== 解压后的固件"
find "$R/usr/lib/firmware" -path '*WCN3990*' -o -name 'wlanmdsp.mbn' | head -10

echo "=== 推到设备"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'mkdir -p /lib/firmware/ath10k/WCN3990/hw1.0 /lib/firmware/qcom/sm8150/Xiaomi/raphael' 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS "$R"/usr/lib/firmware/ath10k/WCN3990/hw1.0/* root@172.16.42.1:/lib/firmware/ath10k/WCN3990/hw1.0/ 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS "$R"/usr/lib/firmware/qcom/sm8150/Xiaomi/raphael/wlanmdsp.mbn root@172.16.42.1:/lib/firmware/qcom/sm8150/Xiaomi/raphael/ 2>&1 | grep -v Warning

echo "=== 重载驱动"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
ls -lh /lib/firmware/ath10k/WCN3990/hw1.0/ | head
D=/sys/bus/platform/drivers/ath10k_snoc
if [ -d $D ]; then
  echo 18800000.wifi > $D/unbind 2>/dev/null || true
  sleep 1
  echo 18800000.wifi > $D/bind 2>/dev/null || echo "bind failed"
fi
sleep 8
dmesg | grep -iE "ath10k" | tail -20
echo ---
ip -br link | head -10
' 2>&1 | grep -v Warning | head -45
