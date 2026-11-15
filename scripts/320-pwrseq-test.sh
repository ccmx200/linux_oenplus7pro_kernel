#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
echo "=== 推 pwrseq DTB"
sshpass -p 1234 scp $OPTS /root/p3-patched.dtb \
  root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; ls -lh /boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb; reboot' 2>&1 | grep -v Warning
echo "=== 等待 100s"
sleep 100
for i in 1 2 3 4 5 6; do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- dummy count"; dmesg | grep -c "dummy regulator"
echo "--- ath10k"; dmesg | grep -iE "ath10k|pwrseq|wcn" | tail -12
echo "--- qrtr"; qrtr-lookup 2>/dev/null | tail -6
echo "--- wlan"; ip -br link | grep -i wlan || echo no-wlan
' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "try $i down"; sleep 15
done
echo DOWN
