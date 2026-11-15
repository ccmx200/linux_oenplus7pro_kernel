#!/bin/bash
set -u
K=/root/kbuild/linux/drivers/net/wireless/ath/ath10k
echo "=== search_bd 源码"
start=$(grep -n 'static int ath10k_core_search_bd' "$K/core.c" | head -1 | cut -d: -f1)
[ -n "$start" ] && sed -n "${start},$((start+45))p" "$K/core.c"
echo
echo "=== 重新解析 board-2.bin（按 IE: id,len,data）"
python3 - <<'PY'
import struct
p="/root/fw/usr/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin"
d=open(p,'rb').read()
magic=b"QCA-ATH10K-BOARD\x00"
off=len(magic); off=(off+3)//4*4
for n in range(1,6):
    if off+8>len(d): break
    iid, ilen = struct.unpack_from('<II', d, off); off+=8
    data=d[off:off+ilen]; off+=ilen
    print(f"[{n}] id={iid:#x} len={ilen}")
    print("   head:", data[:48])
    # 找可打印字符串
    import re
    m=re.match(rb'([ -~]{8,})', data)
    if m: print("   name:", m.group(1)[:70])
PY
