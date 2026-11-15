#!/bin/bash
set -u
K=/root/kbuild/linux
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
KV=7.3.0-sm8150-g8611da353242-dirty
DEST=/lib/modules/$KV/kernel/drivers/power/sequencing

echo "=== 等设备起来"
for i in $(seq 1 10); do
  sleep 10
  if sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP' 2>/dev/null | grep -q UP; then
    echo "device up"
    break
  fi
  echo "wait $i"
done

echo "=== 部署 patched pwrseq"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "mkdir -p $DEST" 2>&1 | grep -v Warning
sshpass -p 1234 scp $OPTS "$K/drivers/power/sequencing/pwrseq-qcom-wcn.ko" root@172.16.42.1:$DEST/ 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 "ls -l $DEST/pwrseq-qcom-wcn.ko; depmod -a; modinfo pwrseq-qcom-wcn | head -2; sync; reboot" 2>&1 | grep -v Warning
echo "rebooted"

sleep 90
for i in $(seq 1 6); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- gpio50"; grep -E "gpio50|gpio-50" /sys/kernel/debug/gpio 2>/dev/null | head -2
echo "--- qrtr"; qrtr-lookup 2>/dev/null | tail -8
echo "--- wlan"; ip -br link | grep -i wlan || echo none
echo "--- dmesg"; dmesg | grep -iE "ath10k|qmi|wcn|firmware" | tail -12
' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "check $i down"; sleep 15
done
echo DOWN
