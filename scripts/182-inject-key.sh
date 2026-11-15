#!/bin/bash
# 往镜像里注入 SSH 公钥（root/user），并确保 sshd 允许公钥+密码
set -euo pipefail
IMG="/mnt/c/迅雷下载/rootfs.img"
WINKEY="/mnt/c/Users/cuicanmx/op7p_id_ed25519"
KEYDIR=/root/.ssh-op7p
mkdir -p "$KEYDIR"
[ -f "$KEYDIR/id_ed25519" ] || ssh-keygen -t ed25519 -N '' -C op7p -f "$KEYDIR/id_ed25519" >/dev/null
cp -f "$KEYDIR/id_ed25519" "$WINKEY"
chmod 644 "$WINKEY" 2>/dev/null || true
PUB=$(cat "$KEYDIR/id_ed25519.pub")
echo "pubkey: $PUB"

LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${LOOP:-}" ] && { LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/rp2
mountpoint -q /mnt/rp2 || mount ${LOOP}p2 /mnt/rp2

install_key() {
    local home="$1" owner="$2"
    mkdir -p "/mnt/rp2$home/.ssh"
    echo "$PUB" > "/mnt/rp2$home/.ssh/authorized_keys"
    chmod 700 "/mnt/rp2$home/.ssh"
    chmod 600 "/mnt/rp2$home/.ssh/authorized_keys"
    echo "installed for $owner ($home)"
}
install_key /root root
install_key /home/user user

echo "=== sshd 允许 pubkey/password"
C=/mnt/rp2/etc/ssh/sshd_config
sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' "$C"
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' "$C"
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$C"
grep -E '^(PubkeyAuthentication|PasswordAuthentication|PermitRootLogin)' "$C"

echo "=== 清 faillock"
rm -f /mnt/rp2/var/run/faillock/* 2>/dev/null || true
rm -f /mnt/rp2/etc/security/faillock.conf 2>/dev/null || true
echo "=== 解掉可能的账户锁定"
python3 - <<'PY'
p="/mnt/rp2/etc/shadow"
lines=open(p).read().splitlines()
out=[]
for ln in lines:
    f=ln.split(":")
    if f[0] in ("root","user") and f[1].startswith("!"):
        f[1]=f[1].lstrip("!")
        print("unlock", f[0])
    out.append(":".join(f))
open(p,"w").write("\n".join(out)+"\n")
PY
sync
umount /mnt/rp2
losetup -d "$LOOP"
ls -l "$WINKEY"
echo OK
