#!/bin/bash
# 离线修改 rootfs.img：重置密码、开 SSH 密码登录、启动加详细日志
set -euo pipefail
IMG="/mnt/c/迅雷下载/rootfs.img"
LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
if [ -z "${LOOP:-}" ]; then
    LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show)
    sleep 1
fi
echo "loop=$LOOP"
mkdir -p /mnt/rp1 /mnt/rp2
mountpoint -q /mnt/rp1 || mount ${LOOP}p1 /mnt/rp1
mountpoint -q /mnt/rp2 || mount ${LOOP}p2 /mnt/rp2

echo "=== 1) 重置密码为 1234"
HASH=$(openssl passwd -6 -salt op7p 1234)
python3 - "$HASH" <<'PY'
import sys, re
h = sys.argv[1]
p = "/mnt/rp2/etc/shadow"
lines = open(p).read().splitlines()
out = []
for ln in lines:
    f = ln.split(":")
    if f[0] in ("root", "user") and len(f) > 2:
        f[1] = h
        ln = ":".join(f)
        print("reset", f[0])
    out.append(ln)
open(p, "w").write("\n".join(out) + "\n")
PY
chmod 640 /mnt/rp2/etc/shadow

echo "=== 2) SSH 允许密码登录"
CONF=/mnt/rp2/etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$CONF"
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$CONF"
grep -E '^(PasswordAuthentication|PermitRootLogin)' "$CONF"
# 去掉 cloud-init 之类可能覆盖的 drop-in
ls /mnt/rp2/etc/ssh/sshd_config.d/ 2>/dev/null || true

echo "=== 3) 启动条目改详细日志"
E=/mnt/rp1/loader/entries/linux.conf
sed -i 's/^options .*/options root=UUID=ee8d3593-59b1-480e-a3b6-4fefb17ee7d8 rw loglevel=7 ignore_loglevel console=tty0/' "$E"
cat "$E"

echo "=== 4) 看有没有 guac dtb 可用"
ls /mnt/rp1/dtbs/qcom/ | grep -i 'sm8150.*oneplus\|guacamole' || echo "(ESP 里没有 guac dtb)"
ls /mnt/rp1 | head
echo "=== 完成，卸载"
sync
umount /mnt/rp1 /mnt/rp2
losetup -d "$LOOP"
echo OK
