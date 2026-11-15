#!/bin/bash
set -u
echo "=== 解析 raphael board-2.bin 结构"
python3 - <<'PY'
import struct
p="/root/fw/usr/lib/firmware/ath10k/WCN3990/hw1.0/board-2.bin"
d=open(p,'rb').read()
magic=b"QCA-ATH10K-BOARD\x00"
print("size", len(d), "magic ok", d[:len(magic)]==magic)
off=len(magic)
off=(off+3)//4*4
n=0
while off+8 <= len(d):
    ie_id, ie_len = struct.unpack_from('<II', d, off)
    off += 8
    data = d[off:off+ie_len]
    off += ie_len
    if len(data) < ie_len: break
    n += 1
    name = data.split(b'\x00',1)[0][:60]
    print(f"[{n}] id={ie_id:#x} len={ie_len} name={name!r}")
    if n>25: print("..."); break
PY
echo
echo "=== Android bdwlan.bin 头"
xxd -l 64 /root/modemfw/bdwlan.bin
echo
echo "=== 设备 qmi board/chip id（debug）"
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'dmesg | grep -iE "qmi-board-id|board name|qmi chip_id|board_file" | tail -10' 2>&1 | grep -v Warning
