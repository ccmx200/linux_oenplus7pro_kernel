#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== 驱动文件"
ls -l "$K/drivers/input/touchscreen/s6sy761.c" 2>/dev/null || echo "no s6sy761.c"
echo "=== 配置"
grep -E '^CONFIG_TOUCHSCREEN_S6SY761|^CONFIG_TOUCHSCREEN=' "$K/.config"
echo "=== 已编译模块"
ls -lh "$K/drivers/input/touchscreen/s6sy761.ko" 2>/dev/null || echo "no ko"
echo "=== 我们 DTS 里是否有触摸"
grep -n -iE 's6sy761|touchscreen|i2c17|tp_irq' /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/sm8150-oneplus-common.dtsi /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/dts/sm8150-oneplus-guacamole.dts | head
