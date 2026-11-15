#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
FW=/lib/firmware/qcom/sm8150
ls $FW 2>/dev/null
if [ ! -e $FW/oneplus7 ]; then
  mkdir -p $FW
  if [ -d $FW/Xiaomi/raphael ]; then
    ln -sfn $FW/Xiaomi/raphael $FW/oneplus7 && echo "linked oneplus7 -> Xiaomi/raphael"
  else
    echo "raphael 固件目录不存在，列一下:"; ls $FW/*/* 2>/dev/null | head
  fi
fi
ls -l $FW | head -5
sync; reboot
' 2>&1 | grep -v Warning | head -20
sleep 100
for i in 1 2 3 4 5; do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP
echo "--- remoteproc"; for r in /sys/class/remoteproc/*; do echo "$r $(cat $r/state) $(cat $r/firmware 2>/dev/null)"; done
echo "--- qrtr"; qrtr-lookup 2>/dev/null | tail -10
echo "--- wlan"; ip -br link | grep -i wlan || echo none
' 2>/dev/null)
  [ -n "$out" ] && { echo "$out"; exit 0; }
  echo "down $i"; sleep 15
done
echo DOWN
