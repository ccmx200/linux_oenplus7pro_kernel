#!/bin/bash
set -euo pipefail
K=/root/nura-kernel/linux
f=$K/drivers/usb/gadget/legacy/ether.c
echo "=== eth_bind 里的配置注册"
grep -n "usb_add_config" "$f"
sed -n "$(grep -n 'static int eth_bind' "$f" | head -1 | cut -d: -f1),+80p" "$f" | grep -n "usb_add_config\|eth_config_driver\|rndis_config_driver\|goto\|return" | head -20
