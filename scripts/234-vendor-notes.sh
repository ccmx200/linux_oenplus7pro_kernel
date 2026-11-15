#!/bin/bash
# 把 vendor dts 落到工作区并提取 panel 供电映射，供下一步移植
set -u
SHA=180d787684d5965be5145bcfbf666ed427b4ea18
BASE=https://git.yylx.win/raw.githubusercontent.com/OnePlusOSS/android_kernel_oneplus_sm8150/$SHA/arch/arm64/boot/dts
W=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/vendor
mkdir -p "$W"
for f in qcom/sm8150-mtp.dtsi qcom/sm8150-pmic-overlay.dtsi 18821/sm8150-mtp.dtsi; do
    out="$W/$(echo "$f" | tr '/' '_')"
    code=$(curl -sL -o "$out" -w '%{http_code}' --max-time 120 "$BASE/$f")
    echo "$code -> $(basename "$out") $(wc -c < "$out")b"
done

NOTES="$W/PANEL_NOTES.md"
{
  echo "# Vendor 显示配置提取"
  echo
  echo "## dsi_panel_pwr_supply (pmic-overlay)"
  grep -n -A20 'dsi_panel_pwr_supply' "$W/qcom_sm8150-pmic-overlay.dtsi" | head -40
  echo
  echo "## 18821 panel supply 引用"
  grep -n -B2 -A6 'panel-supply-entries' "$W/18821_sm8150-mtp.dtsi" | head -60
  echo
  echo "## panel 节点/兼容名"
  grep -n 'qcom,dsi-panel-\|dsi_panel_\|ams639\|ea8076' "$W/18821_sm8150-mtp.dtsi" | head -20
  echo
  echo "## WiFi 节点"
  grep -n -A10 'wifi@18800000\|qca,wcn3990' "$W/qcom_sm8150-mtp.dtsi" | head -30
} > "$NOTES"
wc -l "$NOTES"
head -40 "$NOTES"
