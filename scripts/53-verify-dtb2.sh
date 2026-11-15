#!/bin/bash
set -u
D=/root/op7p/work/linux/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb
dtc -I dtb -O dts "$D" -o /tmp/g2.dts 2>/dev/null || { echo "dtc failed"; exit 1; }
echo "no-readback count: $(grep -c 'no-readback' /tmp/g2.dts)"
grep -n -B3 'no-readback' /tmp/g2.dts
echo "pm8009 count: $(grep -c 'pm8009' /tmp/g2.dts)"
echo "pm8150b count: $(grep -c 'pm8150b-rpmh' /tmp/g2.dts)"
