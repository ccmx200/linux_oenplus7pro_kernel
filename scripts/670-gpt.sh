#!/bin/bash
set -u
cd /root/opsout
echo "=== ops 里的 xml / 配置文件"
ls | grep -iE "xml|rawprogram|patch|gpt" | head -30
echo
echo "=== 解析 GPT（各 LUN）"
python3 - <<'PY'
import struct, glob, os
for f in sorted(glob.glob('/root/opsout/gpt_main*.bin')):
    d = open(f,'rb').read()
    if d[512:520] != b'EFI PART':
        print(f, "非 GPT56 header"); continue
    hdr = d[512:512+92]
    (sig, rev, hsize, crc, _, cur, backup, first, last, _, ptab, nents, esz, pcrc) = struct.unpack_from('<8sIIIIQQQQIIII', hdr, 0)
    print(f"\n--- {os.path.basename(f)}  分区数={nents} 首个可用LBA={first}")
    off = ptab*512
    for i in range(nents):
        e = d[off+i*esz: off+(i+1)*esz]
        if e[:16] == b'\x00'*16: continue
        name = e[56:128].decode('utf-16-le').rstrip('\x00')
        pfirst, plast, attrs = struct.unpack_from('<QQQ', e, 32)
        if not name: continue
        mb = (plast-pfirst+1)*4096/1024/1024
        print(f"  {name:28s} {pfirst:>12} .. {plast:>12}  {mb:10.1f} MB")
PY
