#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
SRC=/root/fw/usr/lib/firmware/ath10k/WCN3990/hw1.0/wlanmdsp.mbn
ls -lh "$SRC"
sshpass -p 1234 scp $OPTS "$SRC" root@172.16.42.1:/tmp/wlanmdsp-raphael.mbn 2>&1 | grep -v Warning
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
cp -f /tmp/wlanmdsp-raphael.mbn /lib/firmware/ath10k/WCN3990/hw1.0/wlanmdsp.mbn
cp -f /tmp/wlanmdsp-raphael.mbn /lib/firmware/qcom/sm8150/oneplus7/wlanmdsp.mbn
ls -lh /lib/firmware/ath10k/WCN3990/hw1.0/wlanmdsp.mbn
sync; reboot
' 2>&1 | grep -v Warning
echo "reverted & rebooting"
