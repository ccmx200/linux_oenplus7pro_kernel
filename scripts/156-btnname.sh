#!/bin/bash
set -u
U=/root/uboot
echo "=== button 名称/命令匹配"
grep -rn 'uc_plat->name\|plat->name\|input_add_driver\|button_cmd' \
    "$U/drivers/button/button-qcom-pmic.c" "$U/drivers/button/button-uclass.c" \
    "$U/drivers/button/button-gpio.c" "$U/common/main.c" "$U/boot/bootmenu.c" 2>/dev/null | head -25
echo
echo "=== PMIC 相关 config"
grep -E '^CONFIG_(PMIC_QCOM|SPMI|PMIC|BUTTON_QCOM_PMIC|DM_PMIC)=' "$U/.output/.config"
echo
echo "=== qcom-pmic 驱动 probe 名字设置段"
sed -n '120,200p' "$U/drivers/button/button-qcom-pmic.c"
