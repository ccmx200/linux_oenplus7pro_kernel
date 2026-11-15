#!/bin/bash
# 解析 Android dtbo.img，导出每个 DTB 并搜索 wlan/icnss/pinctrl 信息
set -uo pipefail
IMG="/mnt/d/Flyme9_ArtChen_9008FlashPackage/Flyme9_ArtChen_9008FlashPackage/images/dtbo.img"
[ -f "$IMG" ] || { echo "找不到 $IMG"; exit 1; }
ls -lh "$IMG"
OUT=/root/dtbo
rm -rf "$OUT"; mkdir -p "$OUT"

python3 - "$IMG" "$OUT" <<'PY'
import struct, sys, os
img, out = sys.argv[1], sys.argv[2]
d = open(img, 'rb').read()
magic, total, hdr, ent_sz, ent_cnt, ent_off, page, ver = struct.unpack('>8I', d[:32])
print(f"magic={magic:#x} total={total} hdr={hdr} ent_sz={ent_sz} count={ent_cnt} off={ent_off}")
assert magic == 0xd7b7ab1e
for i in range(ent_cnt):
    o = ent_off + i*ent_sz
    sz, off, tid, rev, c0, c1, c2, c3 = struct.unpack('>8I', d[o:o+32])
    blob = d[off:off+sz]
    p = os.path.join(out, f"{i:02d}_id{tid}_rev{rev}_{sz}.dtb")
    open(p, 'wb').write(blob)
    print(f"[{i}] id={tid} rev={rev} size={sz} -> {os.path.basename(p)}")
PY

echo "=== 反编译并搜索关键字"
cd "$OUT"
for f in *.dtb; do
  dtc -I dtb -O dts "$f" -o "${f%.dtb}.dts" 2>/dev/null || echo "dtc fail: $f"
done
grep -l 'icnss\|wcn3990\|wcn3998' *.dts 2>/dev/null | head
echo "--- wlan 相关行"
grep -n 'wlan-en\|wlan_en\|sw_ctrl\|qcom,icnss\|wcn3998\|wcn3990' *.dts 2>/dev/null | head -25
