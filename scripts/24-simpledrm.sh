#!/bin/bash
set -u
K=/root/op7p/work/linux
echo "=== find simpledrm source"
find "$K/drivers" -name 'simpledrm*' 2>/dev/null
echo
echo "=== of/platform.c 565-600"
sed -n '565,600p' "$K/drivers/of/platform.c"
echo
echo "=== was simpledrm built? (vmlinux symbols)"
grep -c "simpledrm" "$K/.config" || true
grep -n "simpledrm" "$K/.config" || true
echo
echo "=== dri card in Image?"
command -v grep >/dev/null && grep -a -c "simpledrm" "$K/arch/arm64/boot/Image" || true
