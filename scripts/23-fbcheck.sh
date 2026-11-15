#!/bin/bash
set -u
K=/root/op7p/work/linux
echo "=== simpledrm driver: chosen handling?"
grep -n "chosen\|simple-framebuffer\|platform_driver\|of_match" "$K/drivers/gpu/drm/tiny/simpledrm.c" | head -15
echo
echo "=== sysfb"
grep -rn "simple-framebuffer" "$K/drivers/firmware/sysfb.c" "$K/drivers/of/platform.c" 2>/dev/null | head
echo
echo "=== FB_SIMPLE still exists?"
ls "$K/drivers/video/fbdev/simplefb.c" 2>/dev/null && grep -n "chosen\|of_chosen\|platform_driver" "$K/drivers/video/fbdev/simplefb.c" | head
grep -n "config FB_SIMPLE" -A6 "$K/drivers/video/fbdev/Kconfig" 2>/dev/null | head -10
echo
echo "=== of_platform_populate skip chosen?"
grep -n "chosen" "$K/drivers/of/platform.c" | head
echo
echo "=== arch simplefb setup hook"
grep -rn "simple-framebuffer" "$K/arch/arm64/kernel/" 2>/dev/null | head -5
