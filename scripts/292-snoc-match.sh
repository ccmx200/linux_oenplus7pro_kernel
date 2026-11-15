#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== ath10k snoc 支持的 compatible"
grep -n -A8 'of_device_id ath10k_snoc_dt_match' "$K/drivers/net/wireless/ath/ath10k/snoc.c" | head -15
echo
echo "=== 我们 DTB 里 wifi 节点现况（设备端）"
sshpass -p 1234 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no root@172.16.42.1 '
W=/proc/device-tree/soc@0/wifi@18800000
tr -d "\0" < $W/compatible; echo
for p in vdd-cx-mx-supply vdd-1.8-xo-supply vdd-1.3-rfa-supply vdd-3.3-ch0-supply qcom,msa-fixed-perm qcom,xo-cal-data; do printf "%-24s " "$p"; [ -e "$W/$p" ] && echo present || echo missing; done
' 2>&1 | grep -v Warning
