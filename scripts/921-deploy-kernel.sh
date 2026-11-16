#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
for i in $(seq 1 12); do
  sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP && { echo up; break; }
  echo wait$i; sleep 12
done
echo "=== 备份并部署新内核"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
ls -lh /boot/vmlinuz
cp -f /boot/vmlinuz /boot/vmlinuz.bak 2>/dev/null
ls -lh /boot/vmlinuz.bak' 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS /root/kbuild/linux/arch/arm64/boot/Image root@172.16.42.1:/boot/vmlinuz 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'ls -lh /boot/vmlinuz; ls -lh /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb; sync; reboot' 2>&1 | grep -v Warning
echo "=== 等待启动"
sleep 110
for i in $(seq 1 8); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP; uptime; uname -r
ip -br link | grep -i wlan || echo no-wlan
nmcli -f SSID,SIGNAL dev wifi list 2>/dev/null | head -4
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo down$i; sleep 15
done
echo DOWN
