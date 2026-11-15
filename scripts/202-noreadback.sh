#!/bin/bash
# 在 DTB 里：pm8150/pm8150l 的每个 regulator 子节点加 qcom,no-readback；删除 pm8009 regulators
set -euo pipefail
IMG="${1:-/root/imgbuild/rootfs.img}"
L=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${L:-}" ] && { L=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/p1
mountpoint -q /mnt/p1 || mount "${L}p1" /mnt/p1
DTB=/mnt/p1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
dtc -I dtb -O dts "$DTB" -o /tmp/r.dts 2>/dev/null

python3 - <<'PY'
import re, sys

p = "/tmp/r.dts"
s = open(p).read()

def block_span(s, header):
    i = s.find(header)
    if i < 0:
        return None
    j = s.find("{", i)
    depth = 0
    k = j
    while k < len(s):
        if s[k] == "{":
            depth += 1
        elif s[k] == "}":
            depth -= 1
            if depth == 0:
                return (i, k + 1)
        k += 1
    return None

def patch_block(s, header):
    span = block_span(s, header)
    if not span:
        print("missing", header, file=sys.stderr)
        return s, 0
    a, b = span
    blk = s[a:b]
    # 在块内每个直接子节点（缩进 4 个 tab）花括号后插属性
    cnt = 0
    def repl(m):
        nonlocal cnt
        if "qcom,no-readback" in m.group(0):
            return m.group(0)
        cnt += 1
        return m.group(1) + "\n\t\t\t\t\tqcom,no-readback;" + m.group(2)
    blk2 = re.sub(r"(\n\t\t\t\t[a-z0-9]+ \{)()", lambda m: m.group(1), blk)  # no-op
    # 更直接：逐行处理
    lines = blk.split("\n")
    cur = []
    for ln in lines:
        cur.append(ln)
        if re.match(r"^\t\t\t\t[a-z0-9-]+ \{$", ln):
            cur.append("\t\t\t\t\tqcom,no-readback;")
            cnt += 1
    blk2 = "\n".join(cur)
    return s[:a] + blk2 + s[b:], cnt

total = 0
for h in ("pm8150-rpmh-regulators {", "pm8150l-rpmh-regulators {"):
    s, c = patch_block(s, h)
    total += c

# 删除 pm8009
span = block_span(s, "pm8009-rpmh-regulators {")
if span:
    a, b = span
    # 连同前面的空行一起删
    start = s.rfind("\n", 0, a)
    s = s[:start] + s[b:]
    print("pm8009 removed")

print("no-readback added:", total)
open(p, "w").write(s)
PY

dtc -I dts -O dtb /tmp/r.dts -o "$DTB" 2>/dev/null
echo "DTB 内 qcom,no-readback 数量: $(dtc -I dtb -O dts "$DTB" 2>/dev/null | grep -c 'qcom,no-readback' || true)"
dtc -I dtb -O dts "$DTB" 2>/dev/null | grep -c 'pm8009-rpmh-regulators' || true
sync
umount /mnt/p1
losetup -d "$L" 2>/dev/null || true
echo done
