#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 设为默认 DTB + loader"
cp -f /boot/dtbs/qcom/guac-panel.dtb /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb
rm -f /boot/loader/entries/panel+0-1.conf
printf "default linux.conf\ntimeout 3\n" > /boot/loader/loader.conf
cat /boot/loader/loader.conf
echo "=== 面板模块开机自动加载"
mkdir -p /etc/modules-load.d
echo panel-samsung-oneplus-dsc > /etc/modules-load.d/panel.conf
cat /etc/modules-load.d/panel.conf
echo "=== 背光/亮度"
ls /sys/class/backlight/
cat /sys/class/backlight/ae94000.dsi.0/brightness 2>/dev/null
cat /sys/class/backlight/ae94000.dsi.0/max_brightness 2>/dev/null
echo "=== wifi"
ip -br link | grep -i wlan || echo no-wlan
nmcli -f SSID dev wifi list 2>/dev/null | head -4
sync; reboot' 2>&1 | grep -v Warning | head -30
echo "=== 等待重启验证"
sleep 110
for i in $(seq 1 8); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP; uptime
ls /sys/class/drm | head -6
ls /sys/class/backlight/
ip -br link | grep -i wlan || echo no-wlan
dmesg | grep -cE "msm_dpu|msmdrmfb"
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo down$i; sleep 15
done
echo DOWN
