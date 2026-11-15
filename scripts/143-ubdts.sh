#!/bin/bash
set -u
D=/root/uboot/dts/upstream/src/arm64/qcom/sm8150-xiaomi-raphael.dts
echo "=== 关键节点"
grep -n 'memory@\|reserved-memory\|simple-framebuffer\|framebuffer@\|board-id\|msm-id\|width = \|height = \|stride\|format =' "$D" | head -40
echo
echo "=== chosen / framebuffer 段"
sed -n '/chosen {/,/};/p' "$D" | head -40
echo
echo "=== reserved-memory 段（若有）"
sed -n '/reserved-memory {/,/^	};/p' "$D" | head -60
