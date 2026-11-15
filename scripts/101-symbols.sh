#!/bin/bash
set -u
M=/root/nura-kernel/linux/System.map
echo "=== cpufreq 相关 init"
grep -E 'cpufreq' "$M" | grep -E '_init$|_driver_init$|_platdev_init$' | head -20
echo
echo "=== interconnect / icc init"
grep -E ' (icc|qnoc|sm8150).*init' "$M" | head -15
echo
echo "=== 可能的 module_platform_driver init 名字（末尾 _init 且含 driver）"
grep -E ' t .*driver_init$' "$M" | head -30
