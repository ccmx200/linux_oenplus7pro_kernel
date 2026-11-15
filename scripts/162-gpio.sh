#!/bin/bash
set -u
U=/root/uboot
echo "=== qcom_pmic_gpio.c 驱动/兼容"
grep -n 'compatible\|U_BOOT_DRIVER\|of_match' "$U/drivers/gpio/qcom_pmic_gpio.c" | head -20
echo
echo "=== qcom_spmi_gpio.c 驱动/兼容"
grep -n 'compatible\|U_BOOT_DRIVER' "$U/drivers/gpio/qcom_spmi_gpio.c" | head -20
echo
echo "=== config 里 gpio 相关"
grep -E '^CONFIG_(GPIO|DM_GPIO|QCOM_PMIC_GPIO|SPMI_GPIO|BUTTON_KEYBOARD|BUTTON_GPIO)' "$U/.output/.config" | head -20
echo
echo "=== 用的是哪个 gpio 驱动文件（Makefile）"
cat "$U/drivers/gpio/Makefile" | grep -i qcom
