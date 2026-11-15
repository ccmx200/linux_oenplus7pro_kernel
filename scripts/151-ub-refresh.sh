#!/bin/bash
# 给 U-Boot 补「清屏 + 强制刷新」：打印前把 bootloader 残留盖掉
set -euo pipefail
U=/root/uboot
F=$U/drivers/video/video-uclass.c

python3 - "$F" <<'PY'
import sys
p=sys.argv[1]
s=open(p).read()
old="""	return 0;
};

/* Post-relocation, allocate memory for the frame buffer */"""
new="""	/*
	 * Clear the panel once and force a full refresh before the console
	 * starts printing.  Without this the framebuffer handed over by the
	 * bootloader can keep its old contents / stale warning text mixed
	 * into the first console pages.
	 */
	video_clear(dev);
	video_sync(dev, true);

	return 0;
};

/* Post-relocation, allocate memory for the frame buffer */"""
assert old in s, "pattern not found"
s=s.replace(old,new,1)
open(p,'w').write(s)
print("patched")
PY

cd "$U"
make O=.output CROSS_COMPILE=aarch64-linux-gnu- -j"$(nproc)" CONFIG_DEFAULT_DEVICE_TREE=qcom/sm8150-oneplus-guacamole 2>&1 | tail -4

O=$U/.output
OUT=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out
cd "$O"
gzip -9 -c u-boot-nodtb.bin > u-boot-nodtb.bin.gz
cat u-boot-nodtb.bin.gz dts/upstream/src/arm64/qcom/sm8150-oneplus-guacamole.dtb > uboot-dtb
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
"$MKB" --base 0x0 --kernel_offset 0x00008000 --pagesize 4096 \
       --kernel uboot-dtb -o "$OUT/uboot-guacamole.img"
ls -lh "$OUT/uboot-guacamole.img"
