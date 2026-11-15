#!/bin/bash
# 构建 bootcmd=fastboot 的 U-Boot（用于救援：不进系统、停在 fastboot）
set -euo pipefail
U=/root/uboot
ENV=$U/board/qualcomm/qcom-phone.env
cp -f "$ENV" /tmp/qcom-phone.env.bak

python3 - "$ENV" <<'PY'
import sys, re
p=sys.argv[1]
s=open(p).read()
s=re.sub(r'^bootcmd=.*$', 'bootcmd=fastboot 0', s, flags=re.M)
if 'bootcmd=' not in s:
    s += '\nbootcmd=fastboot 0\n'
open(p,'w').write(s)
print([l for l in s.splitlines() if l.startswith('bootcmd')])
PY

cd "$U"
make O=.output CROSS_COMPILE=aarch64-linux-gnu- -j"$(nproc)" CONFIG_DEFAULT_DEVICE_TREE=qcom/sm8150-oneplus-guacamole 2>&1 | tail -3

O=$U/.output
OUT=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out
cd "$O"
gzip -9 -c u-boot-nodtb.bin > u-boot-nodtb.bin.gz
cat u-boot-nodtb.bin.gz dts/upstream/src/arm64/qcom/sm8150-oneplus-guacamole.dtb > uboot-dtb
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
"$MKB" --base 0x0 --kernel_offset 0x00008000 --pagesize 4096 \
       --kernel uboot-dtb -o "$OUT/uboot-fastboot-only.img"
ls -lh "$OUT/uboot-fastboot-only.img"
