#!/bin/bash
set -euo pipefail
OLD="/mnt/c/迅雷下载/rootfs.img"
NEW="/root/imgbuild/rootfs.img"
OUT=/root/guac-6g.dtb

loop_of() {
    local img="$1" l
    l=$(losetup -j "$img" | cut -d: -f1 | head -1)
    if [ -z "$l" ]; then l=$(losetup -fP --sector-size 4096 "$img" --show); sleep 1; fi
    echo "$l"
}

echo "=== 1) 取 guac dtb"
L1=$(loop_of "$OLD")
mkdir -p /mnt/op1
mountpoint -q /mnt/op1 || mount "${L1}p1" /mnt/op1
cp -f /mnt/op1/dtbs/qcom/sm8150-oneplus-guacamole.dtb "$OUT"
umount /mnt/op1
losetup -d "$L1"

echo "=== 2) 补 6GB memory（插在根节点末尾）"
dtc -I dtb -O dts "$OUT" -o /tmp/gg.dts 2>/dev/null
python3 - <<'PY'
import re
p = "/tmp/gg.dts"
s = open(p).read()
s = re.sub(r"\n\tmemory@[0-9a-f]+ \{.*?\n\t\};\n", "\n", s, flags=re.S)
new = """
	memory@80000000 {
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
	};
"""
t = s.rstrip()
assert t.endswith("};"), "unexpected dts tail"
idx = t.rfind("\n};")
t = t[:idx] + new + t[idx:] + "\n"
open(p, "w").write(t)
print("inserted at end of root node")
PY
dtc -I dts -O dtb /tmp/gg.dts -o "$OUT" 2>/dev/null
dtc -I dtb -O dts "$OUT" 2>/dev/null | grep -A3 'memory@' | head -16

echo "=== 3) 放入新镜像 ESP"
L2=$(loop_of "$NEW")
mkdir -p /mnt/np1
mountpoint -q /mnt/np1 || mount "${L2}p1" /mnt/np1
mkdir -p /mnt/np1/dtbs/qcom
cp -f "$OUT" /mnt/np1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
ls -lh /mnt/np1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
sync
umount /mnt/np1
losetup -d "$L2"

echo "=== 4) 适配"
bash /mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/wsl/191-adapt-image.sh "$NEW"
