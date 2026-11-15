#!/bin/bash
set -u
F=/root/kbuild/linux/drivers/power/sequencing/pwrseq-qcom-wcn.c
echo "=== 驱动里出现的关键字统计"
for k in swctrl wlan-enable bt-enable xo-clk; do
  printf "%-14s %s\n" "$k" "$(grep -ci "$k" "$F" 2>/dev/null || echo 0)"
done
echo
echo "=== 所有 gpiod_get 调用"
grep -n 'gpiod_get' "$F"
echo
echo "=== 文件里 \"sw\" 开头的行"
grep -n 'swctrl\|sw_ctrl' "$F" | head
