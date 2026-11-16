#!/bin/bash
set -u
K=/root/kbuild/linux
F=$K/drivers/clk/qcom/dispcc-sm8250.c
echo "=== dispcc 驱动文件"
ls -l "$F" 2>/dev/null
echo
echo "=== mdss vsync clk 的 ops"
grep -n -B3 -A8 'mdss_vsync' "$F" 2>/dev/null | head -40
echo
echo "=== 是否用 shared ops"
grep -n -e 'clk_shared' -e 'shared_ops' "$F" 2>/dev/null | head -10
echo
echo "=== mdss gdsc 定义/等待值"
grep -n -A10 'mdss_gdsc' "$F" 2>/dev/null | head -30
