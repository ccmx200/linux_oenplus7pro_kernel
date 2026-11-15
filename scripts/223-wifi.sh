#!/bin/bash
set -u
echo "=== raphael firmware deb 里的 WCN3990 文件"
dpkg-deb -c /root/kernel-deb/firmware-xiaomi-raphael.deb 2>/dev/null | grep -iE 'wlan|bdwlan|wcn|wifi|mba|amss' | head -20
echo
echo "=== raphael dts 里 wifi 节点（kernel-deb 用的是 GengWei linux 树）"
grep -n -A12 '&wifi' /root/kbuild/linux/arch/arm64/boot/dts/qcom/sm8150-xiaomi-raphael.dts 2>/dev/null | head -25
echo
echo "=== 设备端 wifi 状态"
sshpass -p 1234 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o PreferredAuthentications=password -o PubkeyAuthentication=no root@172.16.42.1 \
  'dmesg | grep -iE "wcn|ath10k|wifi|wlan|cnss" | head -20; echo ---; ls /sys/class/ieee80211 2>/dev/null; ls /proc/device-tree/soc@0/ | grep -i wifi' 2>&1 | grep -v Warning | head -30
