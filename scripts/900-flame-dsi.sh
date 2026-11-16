#!/bin/bash
set -u
D=/root/kbuild/linux/arch/arm64/boot/dts/qcom
for f in sm8150-google-flame.dts sm8150-microsoft-surface-duo.dts sm8150-sony-xperia-kumano-griffin.dts; do
  echo "########## $f"
  grep -n -A12 -e '&mdss' -e '&mdss_dsi0' -e '&mdss_dsi0_phy' -e '&mdss_mdp' "$D/$f" 2>/dev/null | head -40
done
