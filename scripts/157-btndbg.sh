#!/bin/bash
set -u
U=/root/uboot
echo "=== main.c process_button_cmds"
sed -n '/process_button_cmds/,/^}/p' "$U/common/main.c" | head -40
echo
echo "=== button-uclass.c 名称匹配/获取"
grep -n 'button_get_by_label\|label' "$U/drivers/button/button-uclass.c" | head -20
sed -n '/int button_get_by_label/,/^}/p' "$U/drivers/button/button-uclass.c" | head -40
echo
echo "=== 构建出的 DTB 里 pon/resin 状态"
D=$U/.output/dts/upstream/src/arm64/qcom/sm8150-oneplus-guacamole.dtb
dtc -I dtb -O dts "$D" -o /tmp/guac-ub.dts 2>/dev/null
grep -n -B3 -A12 'pon@800' /tmp/guac-ub.dts | head -50
echo
echo "=== env 配置"
grep -E '^CONFIG_(ENV_|ENV_DEFAULT_ENV_TEXT_FILE|BUTTON_CMD|BOOTDELAY)' "$U/.output/.config" | head -15
