#!/bin/bash
set -uo pipefail
BDF=/root/guacfw/bdwlan.bin
OUT=/root/board-2-fixed.bin
python3 - "$BDF" "$OUT" <<'PY'
import sys, struct
bdf_path, out = sys.argv[1], sys.argv[2]
bdf = open(bdf_path,'rb').read()
official = open('/root/ath10kfw/board-2.bin','rb').read()

def ie(i, data):
    raw = struct.pack('<II', i, len(data)) + data
    return raw + b'\x00' * ((4 - len(raw) % 4) % 4)

def entry(name, data):
    inner = ie(0, name.encode() + b'\x00') + ie(1, data)
    return ie(0, inner)

names = [
    "bus=snoc,qmi-board-id=0,qmi-chip-id=0",
    "bus=snoc,qmi-board-id=0",
    "bus=snoc,qmi-board-id=ff,qmi-chip-id=0",
    "bus=snoc,qmi-board-id=ff,qmi-chip-id=30224",
    "bus=snoc,qmi-board-id=0,qmi-chip-id=30224",
]
blob = official
for n in names:
    blob += entry(n, bdf)
open(out,'wb').write(blob)
print("official", len(official), "+ entries", len(names), "->", len(blob))
# 自检：解析我们追加的部分
d = blob[len(official):]
off = 0
while off + 8 <= len(d):
    iid, ilen = struct.unpack_from('<II', d, off); off += 8
    data = d[off:off+ilen]; off += ilen
    nid, nlen = struct.unpack_from('<II', data, 0)
    print(" entry:", data[8:8+nlen].rstrip(b'\x00').decode(), "ilen", ilen)
PY
ls -lh "$OUT"
