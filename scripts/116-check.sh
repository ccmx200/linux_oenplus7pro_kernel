#!/bin/bash
set -u
K=/root/nura-kernel/linux
echo "=== module_param rndis 位置"
grep -rn "module_param.*rndis\|static bool rndis\|static int rndis" "$K/drivers/usb/gadget" 2>/dev/null | head -10
echo
echo "=== u_ether.c 里 rndis 相关"
grep -n "rndis" "$K/drivers/usb/gadget/function/u_ether.c" | head -10
