#!/bin/bash
set -u
K=/root/kbuild/linux
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"

echo "=== 驱动里固件名/QMI 关键点"
grep -rn 'wlanmdsp\|fw_name\|request_firmware\|qmi' "$K/drivers/net/wireless/ath/ath10k/qmi.c" 2>/dev/null | head -12
grep -rn 'qcom,msa\|firmware-name\|wlanmdsp' "$K/drivers/net/wireless/ath/ath10k/snoc.c" 2>/dev/null | head -8

echo
echo "=== 设备端状态"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "--- remoteproc"; ls /sys/class/remoteproc/ 2>/dev/null; for r in /sys/class/remoteproc/*; do echo "$r: $(cat $r/state 2>/dev/null) $(cat $r/firmware 2>/dev/null)"; done
echo "--- rmtfs 服务"; systemctl is-active rmtfs qrtr-ns 2>/dev/null; ls /dev/qrtr* 2>/dev/null
echo "--- ath10k dmesg"; dmesg | grep -iE "ath10k|wcn|qmi|rmtfs" | tail -25
echo "--- 驱动绑定"; ls -l /sys/bus/platform/drivers/ath10k_snoc/ 2>/dev/null | head
echo "--- 固件目录"; ls /lib/firmware/ath10k/WCN3990/hw1.0/ 2>/dev/null
' 2>&1 | grep -v Warning | head -60
