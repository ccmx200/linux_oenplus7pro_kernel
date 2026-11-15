#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 重建 initramfs"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
ls -l /lib/modules/$(uname -r)/kernel/drivers/power/sequencing/pwrseq-qcom-wcn.ko
update-initramfs -u -k all 2>&1 | tail -5
lsinitramfs /boot/initrd.img 2>/dev/null | grep -c pwrseq
sync; reboot
' 2>&1 | grep -v Warning | head -20
echo "=== 等待并检查"
sleep 110
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- gpio50"; grep -E "gpio50|gpio-50" /sys/kernel/debug/gpio 2>/dev/null | head -2
echo "--- qrtr"; qrtr-lookup 2>/dev/null | tail -8
echo "--- wlan"; ip -br link | grep -i wlan || echo none
echo "--- dmesg"; dmesg | grep -iE "ath10k|qmi|wcn" | tail -12
' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "check $i down"; sleep 15
done
echo DOWN
