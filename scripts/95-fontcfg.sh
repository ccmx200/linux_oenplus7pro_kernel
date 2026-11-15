#!/bin/bash
set -u
K=/root/nura-kernel/linux
echo "=== font 相关"
grep -E 'CONFIG_FONT' "$K/.config" || echo "(none)"
echo "=== console"
grep -E '^CONFIG_FRAMEBUFFER_CONSOLE|^CONFIG_DRM_SIMPLEDRM|^CONFIG_FB=' "$K/.config"
echo "=== usb gadget 相关"
grep -E '^CONFIG_USB_G_ETHER|^CONFIG_USB_ETH|^CONFIG_USB_CONFIGFS_(ACM|RNDIS|NCM)|^CONFIG_USB_GADGET' "$K/.config"
echo "=== 是否有 g_ether 内置"
grep -E 'CONFIG_USB_ETH' "$K/.config"
