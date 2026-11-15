#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "--- uname"; uname -r
echo "--- date"; date
echo "--- module hash"; sha256sum /lib/modules/$(uname -r)/kernel/drivers/power/sequencing/pwrseq-qcom-wcn.ko
echo "--- initramfs module hash"
mkdir -p /tmp/ir && cd /tmp/ir && lsinitramfs /boot/initrd.img | grep pwrseq
rm -rf /tmp/ir2 && mkdir -p /tmp/ir2 && cd /tmp/ir2
lsinitramfs /boot/initrd.img > /tmp/irlist.txt
P=$(grep pwrseq /tmp/irlist.txt | head -1)
echo "path in initramfs: $P"
' 2>&1 | grep -v Warning | head -20
