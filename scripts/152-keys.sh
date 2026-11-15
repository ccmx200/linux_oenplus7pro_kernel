#!/bin/bash
set -u
echo "=== Nura 6.4 内核树 oneplus dts 里的按键"
grep -rn 'KEY_VOLUME\|key-vol\|gpio-keys\|pm8150_gpios' /root/nura-kernel/linux/arch/arm64/boot/dts/qcom/sm8150-oneplus-*.dts* 2>/dev/null | head -25
echo
echo "=== workspace guac dts 里的 pm8150_gpios 引用"
grep -n 'pm8150_gpios\|KEY_VOLUME\|gpio-keys' /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/*.dts* | head -20
echo
echo "=== U-Boot sm8150.dtsi 里 pm8150_gpios 的 gpio 数量/标签"
grep -n -A6 'pm8150_gpios' /root/uboot/dts/upstream/src/arm64/qcom/pm8150.dtsi | head -20
echo
echo "=== U-Boot qcom-phone.env 里的 button 配置"
grep -n 'button' /root/uboot/board/qualcomm/qcom-phone.env
