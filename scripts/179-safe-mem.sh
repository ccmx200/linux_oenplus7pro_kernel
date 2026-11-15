#!/bin/bash
# 保守 /memory（仅低 3GB 内区间），默认回到正常系统入口
set -euo pipefail
IMG="/mnt/c/迅雷下载/rootfs.img"
LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${LOOP:-}" ] && { LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/rp1
mountpoint -q /mnt/rp1 || mount ${LOOP}p1 /mnt/rp1

DTB=/mnt/rp1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
dtc -I dtb -O dts "$DTB" -o /tmp/g.dts 2>/dev/null
python3 - <<'PY'
import re
p="/tmp/g.dts"
s=open(p).read()
# 删掉高地址 memory 节点
s=re.sub(r"\n\tmemory@100000000 \{[^}]*\};\n", "\n", s)
# 重设低区间
s=re.sub(r"memory@80000000 \{[^}]*\};",
"""memory@80000000 {
		device_type = "memory";
		reg = <0x00 0x80000000 0x00 0x3cc00000>;
	};""", s)
s=re.sub(r"memory@c0000000 \{[^}]*\};",
"""memory@c0000000 {
		device_type = "memory";
		reg = <0x00 0xc0000000 0x00 0x80000000>;
	};""", s)
open(p,'w').write(s)
print("memory set to 2.97G (safe)")
PY
dtc -I dts -O dtb /tmp/g.dts -o "$DTB" 2>/dev/null
dtc -I dtb -O dts "$DTB" 2>/dev/null | grep -A3 'memory@' | head -14

# 默认回到正常系统
cat > /mnt/rp1/loader/loader.conf <<'EOF'
default linux.conf
timeout 5
EOF
cat > /mnt/rp1/loader/entries/linux.conf <<'EOF'
title Ubuntu 26.04.1 LTS (OnePlus 7 Pro)
linux /vmlinuz
initrd /initrd.img
devicetree /dtbs/qcom/sm8150-oneplus-guacamole.dtb
options root=UUID=ee8d3593-59b1-480e-a3b6-4fefb17ee7d8 rw loglevel=7 ignore_loglevel console=tty0
EOF
cat /mnt/rp1/loader/entries/linux.conf
sync
umount /mnt/rp1
losetup -d "$LOOP"
echo OK
