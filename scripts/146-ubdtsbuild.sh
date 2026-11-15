#!/bin/bash
set -u
U=/root/uboot
echo "=== include lmb"
ls "$U/include/" | grep -i lmb
grep -rn 'lmb_reserve' "$U/include/" | head -8
echo
echo "=== dts/upstream 顶层"
ls "$U/dts/upstream/" | head
echo
echo "=== qcom dts 目录 Makefile?"
ls "$U/dts/upstream/src/arm64/qcom/" | grep -i makefile || echo "(无 Makefile)"
echo
echo "=== U-Boot 怎么构建 dtb（查 Makefile 规则）"
grep -rn 'DEFAULT_DEVICE_TREE' "$U/scripts/Makefile.lib" | head -5
grep -rn 'dtb-y' "$U/scripts/Makefile.lib" | head -5
