#!/bin/bash
set -u
IMG="/mnt/c/迅雷下载/rootfs.img"
LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${LOOP:-}" ] && { LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/rp2
mountpoint -q /mnt/rp2 || mount ${LOOP}p2 /mnt/rp2
echo "=== 当前 shadow 中 root/user"
grep -E '^(root|user):' /mnt/rp2/etc/shadow
echo
echo "=== 验证 1234 是否匹配"
python3 - <<'PY'
import crypt
h=None
for ln in open("/mnt/rp2/etc/shadow"):
    f=ln.split(":")
    if f[0] in ("root","user"):
        h=f[1]
        print(f[0], "verifies 1234:", crypt.crypt("1234", h) == h)
PY
echo
echo "=== 可能重置密码的脚本"
grep -rl 'chpasswd\|usermod -p\|passwd ' /mnt/rp2/usr/local/bin /mnt/rp2/etc/rc.local /mnt/rp2/etc/profile.d 2>/dev/null | head
ls /mnt/rp2/etc/cloud 2>/dev/null | head -3
echo
echo "=== passwd 里 user 的 shell"
grep -E '^(root|user):' /mnt/rp2/etc/passwd
echo
echo "=== sshd_config 实际生效项"
grep -vE '^\s*#|^\s*$' /mnt/rp2/etc/ssh/sshd_config | head -20
ls /mnt/rp2/etc/ssh/sshd_config.d/ 2>/dev/null
umount /mnt/rp2
losetup -d "$LOOP"
