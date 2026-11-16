#!/bin/bash
set -u
D=/root/uboot/arch/arm/dts
echo "=== 目录是否存在于树内"
ls -d "$D" 2>/dev/null || echo "no dts dir"
echo "=== sm8* 文件"
ls "$D" 2>/dev/null | grep -i 'sm8' | head -20
echo "=== 树里所有含 guacamole 的文件（限 arch）"
grep -rln 'guacamole' /root/uboot/arch 2>/dev/null | head -10
echo "=== 项目根目录里 u-boot 相关镜像"
ls -lh /root/*.img /root/uboot/*.img 2>/dev/null | head
echo "=== 是否还有别的 uboot 目录"
ls -d /root/*uboot* /root/*/u-boot* 2>/dev/null | head
