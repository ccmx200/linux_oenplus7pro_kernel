#!/bin/bash
# 让 systemd-boot 用 Linux guac DTB，并补 /memory；顺带开大字体
set -euo pipefail
IMG="/mnt/c/迅雷下载/rootfs.img"
LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${LOOP:-}" ] && { LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/rp1 /mnt/rp2
mountpoint -q /mnt/rp1 || mount ${LOOP}p1 /mnt/rp1
mountpoint -q /mnt/rp2 || mount ${LOOP}p2 /mnt/rp2

DTB=/mnt/rp1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
echo "=== 原 memory 节点"
dtc -I dtb -O dts "$DTB" -o /tmp/g.dts 2>/dev/null
grep -n -A4 'memory@80000000' /tmp/g.dts

python3 - <<'PY'
p="/tmp/g.dts"
s=open(p).read()
old="""	memory@80000000 {
		device_type = "memory";
		reg = <0x00 0x80000000 0x00 0x00>;
	};"""
new="""	memory@80000000 {
		device_type = "memory";
		reg = <0x00 0x80000000 0x00 0x3cc00000>;
	};

	memory@c0000000 {
		device_type = "memory";
		reg = <0x00 0xc0000000 0x00 0x80000000>;
	};

	memory@100000000 {
		device_type = "memory";
		reg = <0x01 0x00000000 0x00 0xc0000000>;
	};"""
assert old in s, "memory node pattern not found"
open(p,'w').write(s.replace(old,new,1))
print("memory patched")
PY

dtc -I dts -O dtb /tmp/g.dts -o "$DTB" 2>/dev/null
echo "=== 新 memory"
dtc -I dtb -O dts "$DTB" 2>/dev/null | grep -A3 'memory@' | head -20

echo "=== loader 条目加 devicetree + 大字体"
E=/mnt/rp1/loader/entries/linux.conf
cat > "$E" <<'EOF'
title Ubuntu 26.04.1 LTS (OnePlus 7 Pro)
linux /vmlinuz
initrd /initrd.img
devicetree /dtbs/qcom/sm8150-oneplus-guacamole.dtb
options root=UUID=ee8d3593-59b1-480e-a3b6-4fefb17ee7d8 rw loglevel=7 ignore_loglevel console=tty0 fbcon=font:TER16x32
EOF
cat "$E"

echo "=== 内核是否支持 TER16x32 字体"
grep -E 'CONFIG_FONTS=|CONFIG_FONT_TER16x32=' /tmp/kcfg 2>/dev/null || echo "(无 kcfg)"

sync
umount /mnt/rp1 /mnt/rp2
losetup -d "$LOOP"
echo OK
