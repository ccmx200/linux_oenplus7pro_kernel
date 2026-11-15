#!/bin/bash
# 产物验证 + 导出（sparse/压缩 + sha256）
set -eu
O=/root/op7p/out
K=/root/op7p/work/linux

echo "=== boot.img 解包验证"
UB=/root/op7p/work/mkbootimg/unpack_bootimg
make -C /root/op7p/work/mkbootimg unpack_bootimg >/dev/null 2>&1 || true
if [ -x "$UB" ]; then
    "$UB" --boot_img "$O/boot.img" --out /tmp/unpacked 2>&1 | head -20 || true
    ls -l /tmp/unpacked 2>/dev/null || true
else
    echo "(unpack_bootimg 不可用，直接看 header 字符串)"
    strings -a "$O/boot.img" | head -5 || true
fi

echo
echo "=== rootfs 关键内容"
R=/tmp/rootfs-check
mkdir -p "$R"
mount -o loop,ro "$O/rootfs.img" "$R"
for f in usr/local/sbin/gadget-usb0.sh usr/local/sbin/grow-rootfs.sh \
         etc/systemd/system/usb-gadget.service etc/systemd/system/grow-rootfs.service \
         etc/systemd/network/10-usb0.network etc/ssh/sshd_config etc/hostname; do
    if [ -e "$R/$f" ]; then echo "OK   $f"; else echo "MISS $f"; fi
done
echo "--- enabled units"
ls "$R/etc/systemd/system/multi-user.target.wants/" 2>/dev/null | tr '\n' ' '; echo
echo "--- ssh PermitRootLogin / PasswordAuthentication"
grep -E '^PermitRootLogin|^PasswordAuthentication' "$R/etc/ssh/sshd_config" || true
echo "--- passwd root/user"
grep -E '^(root|user):' "$R/etc/passwd" || true
echo "--- size"
du -sh "$R" 2>/dev/null | tail -1
umount "$R"

echo
echo "=== 生成 sparse / 压缩镜像"
cd "$O"
if command -v img2simg >/dev/null 2>&1; then
    img2simg rootfs.img rootfs.simg && echo "sparse OK: $(ls -lh rootfs.simg | awk '{print $5}')"
else
    echo "img2simg 缺失（可选）"
fi
echo "gzip rootfs.img ..."
gzip -9 -c rootfs.img > rootfs.img.gz
ls -lh boot.img rootfs.img rootfs.img.gz rootfs.simg 2>/dev/null
echo
echo "=== sha256"
sha256sum boot.img rootfs.img* 2>/dev/null | tee SHA256SUMS
