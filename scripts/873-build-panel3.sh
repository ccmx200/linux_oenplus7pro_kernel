#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts
echo "=== 关键标签是否存在"
grep -c 'panel_avdd_1p8:' "$C/sm8150-oneplus-guacamole.dts"
grep -c 'panel_te_default:' "$C/sm8150-oneplus-guacamole.dts"
grep -c 'vreg_l14a_1p8:' "$C/sm8150-oneplus-common.dtsi"

cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | grep -E "DTC|Error|error" | head -10
ls -lh "$D/sm8150-oneplus-guacamole.dtb" 2>/dev/null || exit 1
cp -f "$D/sm8150-oneplus-guacamole.dtb" /root/panel3.dtb
dtc -I dtb -O dts /root/panel3.dtb -o /tmp/panel3.dts 2>/dev/null
echo "=== DTB 里 panel 节点"
python3 - <<'PY'
s=open('/tmp/panel3.dts').read()
i=s.find('oneplus-dsc')
print(s[max(0,i-500):i+400] if i>0 else 'panel missing')
PY
