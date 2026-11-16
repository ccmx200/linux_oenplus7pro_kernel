#!/bin/bash
set -u
K=/root/kbuild/linux/arch/arm64/boot/dts/qcom
echo "=== raphael &wifi 节点完整内容"
start=$(grep -n '^&wifi' "$K/sm8150-xiaomi-raphael.dts" | head -1 | cut -d: -f1)
[ -n "$start" ] && sed -n "${start},$((start+40))p" "$K/sm8150-xiaomi-raphael.dts"
echo
echo "=== raphael dts 里 wifi/蓝牙 相关属性"
grep -n 'wifi\|wlan\|bt_\|pwrseq\|calibration' "$K/sm8150-xiaomi-raphael.dts" | head -20
echo
echo "=== raphael board-2.bin 里的条目名（含 variant）"
python3 - <<'PY'
import struct
p="/root/fw/usr/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin"
d=open(p,'rb').read()
magic=b"QCA-ATH10K-BOARD\x00"
off=(len(magic)+3)//4*4
seen=set()
while off+8<=len(d):
    iid,ilen=struct.unpack_from('<II',d,off); off+=8
    data=d[off:off+ilen]; off+=ilen
    # 内层第一个 IE 是名字
    if len(data)>=8:
        nid,nlen=struct.unpack_from('<II',data,0)
        name=data[8:8+nlen].rstrip(b'\x00').decode('latin1')
        if name not in seen:
            seen.add(name); print(name)
PY
