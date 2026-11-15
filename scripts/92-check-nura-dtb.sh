#!/bin/bash
set -u
D=/root/nura-kernel/linux/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb
dtc -I dtb -O dts "$D" -o /tmp/nura.dts 2>/dev/null
echo "line: $(grep -n 'model =' /tmp/nura.dts | head -1)"
echo "simple-framebuffer: $(grep -c 'simple-framebuffer' /tmp/nura.dts)"
grep -n -A6 'simple-framebuffer' /tmp/nura.dts | head -12
echo "ufshc status: $(grep -A20 'ufshc@' /tmp/nura.dts | grep -m1 status)"
echo "usb dr_mode: $(grep -m1 'dr_mode' /tmp/nura.dts)"
echo "touch: $(grep -m1 's6sy761' /tmp/nura.dts)"
