#!/bin/bash
set -u
D=/root/pcie-guac-patched.dtb
echo "=== 校验 DTB"
dtc -I dtb -O dts "$D" 2>/dev/null > /tmp/verify.dts
grep -A3 'display-subsystem@ae00000 {' /tmp/verify.dts | grep status | head -2
grep -A4 'pcie@1c00000 {' /tmp/verify.dts | grep status | head -2
grep -c 'qcom,no-readback' /tmp/verify.dts

echo "=== 部署"
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 scp $OPTS "$D" root@172.16.42.1:/boot/dtbs/qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; reboot' 2>&1 | grep -v Warning
echo rebooted
