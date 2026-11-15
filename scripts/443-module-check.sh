#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 当前模块来源"
cat /sys/module/pwrseq_qcom_wcn/srcversion 2>/dev/null; echo
modinfo pwrseq-qcom-wcn 2>/dev/null | grep -E "filename|srcversion"
echo "=== 检查 initramfs 里是否也有该模块"
lsinitramfs /boot/initrd.img 2>/dev/null | grep -i pwrseq | head -5 || echo "(无法列出 initramfs)"
echo "=== 重新加载模块并看 gpio50"
K=7.3.0-sm8150-g8611da353242-dirty
rmmod pwrseq-qcom-wcn 2>&1 | head -2
sleep 1
modprobe pwrseq-qcom-wcn 2>&1 | head -2
sleep 3
grep -E "gpio50|gpio-50" /sys/kernel/debug/gpio 2>/dev/null | head -2
' 2>&1 | grep -v Warning | head -30
