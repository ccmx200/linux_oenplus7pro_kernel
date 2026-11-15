#!/bin/bash
set -u
U=/root/uboot
echo "=== button-qcom-pmic 驱动声明"
sed -n '/U_BOOT_DRIVER/,$p' "$U/drivers/button/button-qcom-pmic.c"
echo
echo "=== button-gpio 驱动声明（对照）"
sed -n '/U_BOOT_DRIVER/,$p' "$U/drivers/button/button-gpio.c" | head -20
echo
echo "=== process_button_cmds 定义"
grep -rn 'void process_button_cmds' "$U" --include=*.c | head
grep -rn -A25 'void process_button_cmds' "$U/common/main.c" | head -35
