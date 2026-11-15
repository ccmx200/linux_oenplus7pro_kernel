#!/bin/bash
set -u
SHA=180d787684d5965be5145bcfbf666ed427b4ea18
BASE=https://git.yylx.win/raw.githubusercontent.com/OnePlusOSS/android_kernel_oneplus_sm8150/$SHA
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
for f in drivers/soc/qcom/icnss.c drivers/soc/qcom/icnss2/main.c; do
  out="$W/$(echo "$f" | tr '/' '_')"
  code=$(curl -sL -o "$out" -w '%{http_code}' --max-time 120 "$BASE/$f")
  echo "$code $f $(wc -c < "$out" 2>/dev/null)b"
done
echo
echo "=== icnss 里的 gpio / regulator / 上电"
grep -n 'gpio\|regulator\|wlan_en\|wlan-en\|power_on' "$W/drivers_soc_qcom_icnss.c" 2>/dev/null | head -25
