#!/bin/bash
set -u
U=/root/uboot
echo "=== LMB API"
grep -n 'lmb_reserve' "$U/include/lmb.h" | head -10
echo
echo "=== simplefb.c"
sed -n '1,60p' "$U/drivers/video/simplefb.c"
echo
echo "=== raphael dts 头部 model/compatible"
sed -n '30,50p' "$U/dts/upstream/src/arm64/qcom/sm8150-xiaomi-raphael.dts"
echo
echo "=== Makefile 里 sm8150 行"
grep -n 'sm8150' "$U/dts/upstream/src/arm64/qcom/Makefile" | head
