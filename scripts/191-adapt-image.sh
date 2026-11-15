#!/bin/bash
# 7 Pro 适配：guac DTB（6G 内存）+ devicetree 条目 + SSH 公钥/密码
set -euo pipefail
IMG="${1:-/root/imgbuild/rootfs.img}"
[ -f "$IMG" ] || { echo "找不到 $IMG"; exit 1; }

LOOP=$(losetup -j "$IMG" | cut -d: -f1 | head -1)
[ -z "${LOOP:-}" ] && { LOOP=$(losetup -fP --sector-size 4096 "$IMG" --show); sleep 1; }
mkdir -p /mnt/np1 /mnt/np2
mountpoint -q /mnt/np1 || mount "${LOOP}p1" /mnt/np1
mountpoint -q /mnt/np2 || mount "${LOOP}p2" /mnt/np2

DTB=/mnt/np1/dtbs/qcom/sm8150-oneplus-guacamole.dtb
if [ ! -f "$DTB" ]; then echo "缺少 guac dtb"; umount /mnt/np1 /mnt/np2; losetup -d "$LOOP"; exit 1; fi

echo "=== 检查 /memory"
dtc -I dtb -O dts "$DTB" -o /tmp/a.dts 2>/dev/null
if grep -q 'reg = <0x00 0x80000000 0x00 0x3cc00000>' /tmp/a.dts; then
    echo "已是 6GB 映射，跳过"
else
    python3 - <<'PY'
import re
p="/tmp/a.dts"; s=open(p).read()
s=re.sub(r"\n\tmemory@[0-9a-f]+ \{.*?\n\t\};\n", "\n", s, flags=re.S)
new = """
	memory@80000000 {
		device_type = "memory";
		reg = <0x00 0x80000000 0x00 0x3cc00000>;
	};

	memory@c0000000 {
		device_type = "memory";
		reg = <0x00 0xc0000000 0x00 0x80000000>;
	};

	memory@100000000 {
		device_type = "memory";
		reg = <0x01 0x00000000 0x00 0xc0000000>;
	};
"""
t=s.rstrip(); assert t.endswith("};")
i=t.rfind("\n};"); t=t[:i]+new+t[i:]+"\n"
open(p,"w").write(t); print("memory rebuilt")
PY
    dtc -I dts -O dtb /tmp/a.dts -o "$DTB" 2>/dev/null
    echo "已写入 6GB 内存映射"
fi

echo "=== loader 条目"
cat > /mnt/np1/loader/entries/linux.conf <<'EOF'
title Ubuntu (OnePlus 7 Pro, 6G)
linux /vmlinuz
initrd /initrd.img
devicetree /dtbs/qcom/sm8150-oneplus-guacamole.dtb
options root=UUID=ee8d3593-59b1-480e-a3b6-4fefb17ee7d8 rw loglevel=7 ignore_loglevel console=tty0
EOF
cat /mnt/np1/loader/entries/linux.conf
printf 'default linux.conf\ntimeout 5\n' > /mnt/np1/loader/loader.conf

echo "=== SSH 公钥"
PUB=$(cat /root/.ssh-op7p/id_ed25519.pub)
for h in /root /home/user; do
    mkdir -p "/mnt/np2$h/.ssh"
    echo "$PUB" > "/mnt/np2$h/.ssh/authorized_keys"
    chmod 700 "/mnt/np2$h/.ssh"; chmod 600 "/mnt/np2$h/.ssh/authorized_keys"
done
echo "=== 密码 1234"
HASH=$(openssl passwd -6 -salt op7p 1234)
python3 - "$HASH" <<'PY'
import sys
h=sys.argv[1]; p="/mnt/np2/etc/shadow"
lines=open(p).read().splitlines(); out=[]
for ln in lines:
    f=ln.split(":")
    if f[0] in ("root","user") and len(f)>2:
        f[1]=h; ln=":".join(f); print("set", f[0])
    out.append(ln)
open(p,"w").write("\n".join(out)+"\n")
PY
C=/mnt/np2/etc/ssh/sshd_config
if [ -f "$C" ]; then
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/;s/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/;s/^#\?PermitRootLogin.*/PermitRootLogin yes/' "$C"
fi
sync
umount /mnt/np1 /mnt/np2
losetup -d "$LOOP"
echo "适配完成: $IMG"
