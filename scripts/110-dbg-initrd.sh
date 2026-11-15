#!/bin/bash
# 构建「USB 串口 shell」调试 initramfs：
#  - Alpine minirootfs（busybox 完整）
#  - /init 里建 ACM gadget → ttyGS0 上是 root shell，Windows 上用 COM 口直接进
#  - 同时把 dmesg 输出到串口，方便看卡在哪
set -euo pipefail

W=/root/dbg-initrd
OUT=/root/op7p/out
ALPINE_VER="${ALPINE_VER:-3.22}"
MIRROR="https://mirrors.tuna.tsinghua.edu.cn/alpine"

mkdir -p "$W"
cd "$W"

if [ ! -f alpine-minirootfs.tar.gz ]; then
    for v in 3.22 3.21 3.20; do
        url="$MIRROR/v$v/releases/aarch64/alpine-minirootfs-$v.0-aarch64.tar.gz"
        echo "尝试 $url"
        if curl -fsSL --max-time 300 -o alpine-minirootfs.tar.gz "$url"; then ALPINE_VER=$v; break; fi
    done
fi
[ -s alpine-minirootfs.tar.gz ] || { echo "下载失败"; exit 1; }

rm -rf root; mkdir root
tar xzf alpine-minirootfs.tar.gz -C root

# /init：串口 shell + 可选自动挂 root 并 switch_root
cat > root/init <<'EOF'
#!/bin/sh
export PATH=/sbin:/bin:/usr/sbin:/usr/bin
log() { echo "[dbg] $*"; }

mount -t proc     none /proc   2>/dev/null
mount -t sysfs    none /sys    2>/dev/null
mount -t devtmpfs none /dev    2>/dev/null
mkdir -p /sys/kernel/config /dev/pts /newroot
mount -t configfs none /sys/kernel/config 2>/dev/null

# --- USB ACM gadget：ttyGS0 ---
G=/sys/kernel/config/usb_gadget/dbg
if [ -d /sys/kernel/config/usb_gadget ]; then
    mkdir -p "$G" && cd "$G" || true
    echo 0x1d6b > idVendor 2>/dev/null || true
    echo 0x0104 > idProduct 2>/dev/null || true
    mkdir -p strings/0x409 configs/c.1/strings/0x409 2>/dev/null
    echo "OnePlus 7 Pro debug" > strings/0x409/product 2>/dev/null || true
    echo "debug" > configs/c.1/strings/0x409/configuration 2>/dev/null || true
    mkdir -p functions/acm.usb0 2>/dev/null || true
    ln -sf functions/acm.usb0 configs/c.1/ 2>/dev/null || true
    UDC=$(ls /sys/class/udc 2>/dev/null | head -1)
    [ -n "$UDC" ] && echo "$UDC" > UDC 2>/dev/null || true
    cd /
fi

# 等 ttyGS0 出现
i=0; while [ ! -c /dev/ttyGS0 ] && [ $i -lt 30 ]; do sleep 0.5; i=$((i+1)); done

# 串口上跑 shell，并把 dmesg 打过去
if [ -c /dev/ttyGS0 ]; then
    { echo; echo "=== OnePlus 7 Pro debug shell (ttyGS0) ==="; echo; dmesg; } > /dev/ttyGS0 2>&1 &
    ( while :; do
        setsid sh -i </dev/ttyGS0 >/dev/ttyGS0 2>&1
        sleep 1
      done ) &
fi

# console 上也给个 shell（防串口不通）
( sleep 2; while :; do setsid sh -i </dev/tty0 >/dev/tty0 2>&1; sleep 2; done ) &

# 保持 PID1 存活
while :; do sleep 5; done
EOF
chmod 755 root/init

# 打包
rm -f "$W/initramfs.cpio.gz"
( cd root && find . -print0 | cpio --null -o -H newc 2>/dev/null | gzip -9 -n > "$W/initramfs.cpio.gz" )
ls -lh "$W/initramfs.cpio.gz"

# 打 boot.img（内核 + DTB + 这个 initramfs；不带 root=）
SRC=/root/nura-kernel/linux
W2=/root/nura-kernel
cat "$SRC/arch/arm64/boot/Image.gz" "$SRC/arch/arm64/boot/dts/qcom/sm8150-oneplus-guacamole.dtb" > "$W2/kernel-dtb.gz"
MKB=$(ls /root/op7p/work/mkbootimg/mkbootimg 2>/dev/null || command -v mkbootimg)
CMDLINE="console=tty0 console=ttyGS0,115200 fbcon=font:TER16x32 loglevel=7 ignore_loglevel oops=panic panic=0"
"$MKB" --pagesize 4096 --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 \
       --second_offset 0x00f00000 --tags_offset 0x00000100 \
       --kernel "$W2/kernel-dtb.gz" --ramdisk "$W/initramfs.cpio.gz" --cmdline "$CMDLINE" \
       -o "$OUT/nura-boot-dbg.img"
ls -lh "$OUT/nura-boot-dbg.img"
echo "cmdline: $CMDLINE"
