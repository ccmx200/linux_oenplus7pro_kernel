#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== GPU devfreq"
cat /sys/class/devfreq/2c00000.gpu/cur_freq 2>/dev/null
cat /sys/class/devfreq/2c00000.gpu/available_frequencies 2>/dev/null
echo "=== GPU 节点 supply（DTB）"
for f in /proc/device-tree/soc@0/gpu@2c00000/*-supply; do echo "$(basename $f)"; done 2>/dev/null
echo "=== GPU 使用率接口"
ls /sys/class/drm/card0/device/ | grep -iE "gpu|freq|busy" | head
' 2>&1 | grep -v Warning | head -20
echo
echo "=== 内核里 gpu 节点的 supply 名"
grep -n -A20 'gpu: gpu@2c00000' /root/kbuild/linux/arch/arm64/boot/dts/qcom/sm8150.dtsi | grep -E "supply|power-domain|opp" | head -8
