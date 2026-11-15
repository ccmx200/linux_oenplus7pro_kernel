#!/bin/bash
set -uo pipefail
C=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts
K=/root/kbuild/linux
python3 - "$C/sm8150-oneplus-guacamole.dts" <<'PY'
import sys, re
p=sys.argv[1]; s=open(p).read()
# 清理遗留的孤立 ";" / "};"
s = re.sub(r"\n;\n\};\n\n(&tlmm \{\n\twlan_en_default:)", r"\n\1", s)
s = re.sub(r"\n\{\n\twlan_en_default:", "\n&tlmm {\n\twlan_en_default:", s)
open(p,"w").write(s)
print("cleaned")
PY
tail -14 "$C/sm8150-oneplus-guacamole.dts"
cp -f "$C/sm8150-oneplus-guacamole.dts" "$K/arch/arm64/boot/dts/qcom/"
cd "$K"
rm -f arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- qcom/sm8150-oneplus-guacamole.dtb 2>&1 | tail -5
ls -lh arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb 2>/dev/null || echo BUILD_FAIL
