#!/bin/bash
set -u
U=/root/uboot
echo "=== 当前 config 里 button/input 相关"
grep -E '^CONFIG_(BUTTON|INPUT|DM_KEYBOARD|BUTTON_QCOM|BUTTON_GPIO|BUTTON_REMAP)' "$U/.output/.config" | head -20
echo
echo "=== driver 文件"
ls "$U/drivers/button/"
echo
echo "=== Kconfig BUTTON 定义"
grep -n 'config BUTTON' -A8 "$U/drivers/button/Kconfig" | head -50
