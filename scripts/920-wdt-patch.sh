#!/bin/bash
set -uo pipefail
K=/root/kbuild/linux
cd "$K"
cp -f arch/arm64/kernel/head.S /root/head.S.bak
python3 - <<'PY'
p='/root/kbuild/linux/arch/arm64/kernel/head.S'
s=open(p).read()
if 'WDT0_EN' in s:
    print('already patched'); raise SystemExit
old = """	bl	__cpu_setup			// initialise processor
"""
new = """	bl	__cpu_setup			// initialise processor
	/*
	 * 关掉继承的 APSS 看门狗，避免 mdss 等早期 bring-up 卡住时整机被复位。
	 * APSS WDT 基址 0x17c10000，WDT0_EN 在 +0x08。
	 */
	movz	x9, #0x17c1, lsl #16
	str	wzr, [x9, #0x08]
	dsb	sy

"""
assert old in s
s = s.replace(old, new, 1)
open(p,'w').write(s)
print('patched head.S')
PY
grep -n -A6 'WDT0_EN' arch/arm64/kernel/head.S | head -12
echo "=== 编译 Image"
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image -j8 2>&1 | tail -6
ls -lh arch/arm64/boot/Image
