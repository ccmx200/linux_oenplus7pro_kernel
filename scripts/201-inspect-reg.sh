#!/bin/bash
set -u
IMG=/root/imgbuild/rootfs.img
L=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "$L" ] && { L=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/p1
mountpoint -q /mnt/p1 || mount "${L}p1" /mnt/p1
D=/mnt/p1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
ls -lh "$D"
dtc -I dtb -O dts "$D" -o /tmp/z.dts 2>/dev/null
echo "=== 关键行"
grep -n 'rpmh-regulators\|regulators@\|regulator@\|pm8009\|pm8150-rpmh\|pm8150l-rpmh\|rpmh-reg' /tmp/z.dts | head -30
echo "=== 片段"
sed -n "$(grep -n 'rpmh-regulators' /tmp/z.dts | head -1 | cut -d: -f1),+25p" /tmp/z.dts 2>/dev/null
umount /mnt/p1
