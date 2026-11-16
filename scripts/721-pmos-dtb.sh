#!/bin/bash
set -u
B=/root/.local/var/pmbootstrap/chroot_rootfs_oneplus-guacamole/boot
dtc -I dtb -O dts "$B/sm8150-oneplus-guacamole.dtb" -o /tmp/pmos-guac.dts 2>/dev/null
echo "=== wifi 节点"
grep -n -A30 'wifi@18800000' /tmp/pmos-guac.dts | head -45
echo
echo "=== pwrseq / wcn3998-pmu 节点"
grep -n -B2 -A25 'wcn3998-pmu' /tmp/pmos-guac.dts | head -50
echo
echo "=== bt 节点"
grep -n -A12 'bluetooth\|wcn3998-bt' /tmp/pmos-guac.dts | head -25
