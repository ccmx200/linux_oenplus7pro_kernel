#!/bin/bash
set -u
D=/root/kbuild/linux/arch/arm64/boot/dts/qcom
echo "=== DTS 里 dsi0/panel 相关位置"
grep -n -e 'mdss_dsi0 {' -e 'vdda-supply' -e 'panel@0' -e 'oneplus-dsc' -e 'vdds-supply' "$D/sm8150-oneplus-guacamole.dts" | tail -20
echo
echo "=== 最终 DTB 里 dsi0 与 panel 的状态"
dtc -I dtb -O dts /root/panel2-final.dtb -o /tmp/chk.dts 2>/dev/null
python3 - <<'PY'
s=open('/tmp/chk.dts').read()
import re
i=s.find('dsi@ae94000')
print(s[i:i+400] if i>0 else 'dsi node not found')
j=s.find('oneplus-dsc')
print('--- panel node ---')
print(s[max(0,j-300):j+500] if j>0 else 'panel not found')
PY
