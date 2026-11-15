#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== pwrseq 驱动要求的 supply / 属性"
grep -n 'regulator_bulk_data\|\.supply\|of_property_read\|devm_pwrseq' "$K/drivers/power/sequencing/pwrseq-qcom-wcn.c" | head -20
echo
echo "=== binding 文档"
ls "$K/Documentation/devicetree/bindings/power/sequencing/" 2>/dev/null
F=$(ls "$K/Documentation/devicetree/bindings/power/sequencing/"*wcn* 2>/dev/null | head -1)
[ -n "$F" ] && sed -n '1,60p' "$F"
