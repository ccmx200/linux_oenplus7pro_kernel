#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
D=$K/arch/arm64/boot/dts/qcom
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts
USID=0x4

python3 - "$C/sm8150-oneplus-guacamole.dts" "$USID" <<'PY'
import sys, re
p, usid = sys.argv[1], sys.argv[2]
s = open(p).read()
# 修正 &pm8150l -> &spmi_bus/pmic@4/labibb
s = re.sub(r"&pm8150l \{", "&spmi_bus {\n\tpmic@4 {", s)
s = re.sub(r"&dsi0 \{", "&mdss_dsi0 {", s)
# 把 labibb 块的 usid 换成 0x4
s = re.sub(r"interrupts = <3 ", f"interrupts = <{usid} ", s)
# 补 pmic@4 结尾：在 labibb 块后多一个 };
s = s.replace("\t};\n};\n\n&mdss {", "\t};\n\t};\n};\n\n&mdss {")
open(p,"w").write(s)
print("patched labels")
PY
grep -n 'pmic@4\|labibb\|mdss_dsi0\|interrupts = <' "$C/sm8150-oneplus-guacamole.dts" | head -12

cp -f "$C/sm8150-oneplus-guacamole.dts" "$D/"
cd "$K"
rm -f "$D/sm8150-oneplus-guacamole.dtb"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -12
ls -lh "$D/sm8150-oneplus-guacamole.dtb" 2>/dev/null || echo BUILD_FAIL
