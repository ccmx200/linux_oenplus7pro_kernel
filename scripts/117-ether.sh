#!/bin/bash
set -u
K=/root/nura-kernel/linux
f=$K/drivers/usb/gadget/legacy/ether.c
echo "=== ether.c 关键片段"
grep -n "RNDIS\|rndis\|has_rndis\|use_rndis" "$f" | head -30
echo
echo "=== eth_bind / config 注册段落"
sed -n '250,340p' "$f"
