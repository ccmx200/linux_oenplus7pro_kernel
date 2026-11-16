#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 设备显示状态"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "--- framebuffer"
ls /sys/class/graphics/ 2>/dev/null
for fb in /sys/class/graphics/fb*; do echo "$fb: $(cat $fb/name 2>/dev/null) $(cat $fb/virtual_size 2>/dev/null)"; done
echo "--- simple-framebuffer dmesg"
dmesg | grep -iE "simple-framebuffer|simplefb|drm|msm|dsi|panel" | head -15
echo "--- /proc/fb"
cat /proc/fb 2>/dev/null
echo "--- backlight"
ls /sys/class/backlight/ 2>/dev/null
' 2>&1 | grep -v Warning | head -35
echo
echo "=== 我们 DTS 里的显示相关节点"
grep -n "framebuffer\|simple-framebuffer\|display-subsystem\|status.*disabled" /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/sm8150-oneplus-common.dtsi | head -20
