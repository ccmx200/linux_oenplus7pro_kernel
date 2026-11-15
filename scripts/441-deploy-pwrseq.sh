#!/bin/bash
set -u
K=/root/kbuild/linux
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
KV=7.3.0-sm8150-g8611da353242-dirty
DEST=/lib/modules/$KV/kernel/drivers/power/sequencing
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "mkdir -p $DEST" 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS "$K/drivers/power/sequencing/pwrseq-qcom-wcn.ko" root@172.16.42.1:$DEST/ 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'ls -l /lib/modules/'$KV'/kernel/drivers/power/sequencing/pwrseq-qcom-wcn.ko; depmod -a; sync; reboot' 2>&1 | grep -v Warning
echo "rebooting with patched pwrseq"
sleep 100
for i in 1 2 3 4 5; do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- gpio50"; cat /sys/kernel/debug/gpio 2>/dev/null | grep -E "gpio50|gpio-50" | head -2
echo "--- qrtr"; qrtr-lookup 2>/dev/null | tail -8
echo "--- wlan"; ip -br link | grep -i wlan || echo none
echo "--- ath10k"; dmesg | grep -iE "ath10k|qmi|wcn" | tail -12
' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "try $i down"; sleep 15
done
echo DOWN
