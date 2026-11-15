#!/bin/bash
# 给 guac DTB 的 pm8150/pm8150l regulators 加 qcom,no-readback，删除 pm8009 regulators
set -euo pipefail
IMG="${1:-/root/imgbuild/rootfs.img}"
L=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${L:-}" ] && { L=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/p1
mountpoint -q /mnt/p1 || mount "${L}p1" /mnt/p1
DTB=/mnt/p1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
dtc -I dtb -O dts "$DTB" -o /tmp/r.dts 2>/dev/null

python3 - <<'PY'
import re
p="/tmp/r.dts"
s=open(p).read()

# 1) 删除 pm8009 相关的 regulator 容器（若存在）
s = re.sub(r"\n\t\t\tpm8009-regulators \{[^}]*?\n\t\t\t\};\n", "\n", s, flags=re.S)

# 2) 给所有 rpmh regulator 子节点加 qcom,no-readback
def addprop(m):
    head, body = m.group(1), m.group(2)
    if "qcom,no-readback" in body:
        return m.group(0)
    return head + "\n\t\t\t\tqcom,no-readback;" + body
s = re.sub(r"(\n\t\t\t\tregulator@[0-9a-f]+ \{)(.*?\n\t\t\t\t\};)", addprop, s, flags=re.S)
open(p,"w").write(s)
print("no-readback count:", s.count("qcom,no-readback"))
PY

dtc -I dts -O dtb /tmp/r.dts -o "$DTB" 2>/dev/null
dtc -I dtb -O dts "$DTB" 2>/dev/null | grep -c 'qcom,no-readback' || true
sync
umount /mnt/p1
losetup -d "$L" 2>/dev/null || true
echo "DTB patched"
