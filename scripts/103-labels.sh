#!/bin/bash
set -u
D=/root/nura-kernel/linux/arch/arm64/boot/dts/qcom
echo "=== guac dts 现有内容"
cat "$D/sm8150-oneplus-guacamole.dts"
echo
echo "=== common dtsi 里引用的 remoteproc/gpu/wifi/ipa"
grep -nE '&(remoteproc|adsp|mpss|slpi|cdsp|venus|gpu|wifi|ipa)' "$D/sm8150-oneplus-common.dtsi" | head -20
echo
echo "=== sm8150.dtsi 里的相关 label"
grep -nE '^\s*[a-z_]*(remoteproc|adsp|mpss|slpi|cdsp|venus|gpu|wifi|ipa)[a-z_]*:' "$D/sm8150.dtsi" | head -25
