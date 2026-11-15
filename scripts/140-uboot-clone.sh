#!/bin/bash
set -euo pipefail
W=/root/uboot
if [ ! -d "$W/.git" ]; then
    git clone --depth=1 --single-branch --branch mailing \
        https://git.yylx.win/github.com/GengWei1997/u-boot "$W"
fi
cd "$W"
echo "=== HEAD $(git log -1 --format='%h %ad %s' --date=short)"
echo "=== raphael dts 内存/显示相关"
D=dts/upstream/src/arm64/qcom
grep -n "memory@\|reserved-memory\|simple-framebuffer\|framebuffer@\|board-id\|msm-id" "$D/sm8150-xiaomi-raphael.dts" | head -30
echo "=== u-boot 里 simplefb 驱动路径"
ls drivers/video/simplefb.c
echo "=== config fragments"
ls configs/tauchgang.config board/qualcomm/qcom-phone.config 2>/dev/null
