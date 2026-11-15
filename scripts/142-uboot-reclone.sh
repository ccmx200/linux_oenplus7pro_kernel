#!/bin/bash
set -u
rm -rf /root/uboot
git clone --depth=1 --single-branch --branch mailing \
    https://git.yylx.win/github.com/GengWei1997/u-boot /root/uboot 2>&1 | tail -5
cd /root/uboot || exit 1
echo "branch=$(git branch --show-current) head=$(git log -1 --format='%h %ad %s' --date=short)"
echo "--- sm8150 dts"
ls dts/upstream/src/arm64/qcom/ | grep -i 'sm8150' 
echo "--- raphael"
find . -name '*raphael*' -not -path './.git/*' | head
