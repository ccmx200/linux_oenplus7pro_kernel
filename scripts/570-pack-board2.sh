#!/bin/bash
set -uo pipefail
BDF=/root/modemfw/bdwlan.bin
OUT=/root/board-2-ours.bin
ls -lh "$BDF"

python3 - "$BDF" "$OUT" <<'PY'
import sys, struct
bdf_path, out_path = sys.argv[1], sys.argv[2]
bdf = open(bdf_path,'rb').read()
print("bdf size", len(bdf), "magic", bdf[:4].hex())

names = []
board_ids = ["55","67","ff","0","1","2","3","64","65"]
chip_ids  = ["30224","432","320","4001","0"]
for b in board_ids:
    names.append(f"bus=snoc,qmi-board-id={b}")
    for c in chip_ids:
        names.append(f"bus=snoc,qmi-board-id={b},qmi-chip-id={c}")

def ie(i, data):
    return struct.pack('<II', i, len(data)) + data

def pad4(b):
    return b + b'\x00' * ((4 - len(b) % 4) % 4)

magic = b"QCA-ATH10K-BOARD\x00"
blob = magic
blob = pad4(blob)
for n in names:
    name_ie = ie(0, n.encode() + b'\x00')
    data_ie = ie(1, bdf)
    inner = name_ie + data_ie
    blob += ie(0, inner)
open(out_path,'wb').write(blob)
print("entries:", len(names), "size:", len(blob))
print("sample:", names[0])
PY
ls -lh "$OUT"
