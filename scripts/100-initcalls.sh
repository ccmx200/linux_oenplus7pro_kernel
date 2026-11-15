#!/bin/bash
set -u
N=/root/nura-kernel/linux
echo "=== 谁打印 'Setting ...uV'"
grep -rn 'Setting %d-%duV\|Setting %d-%d' "$N/drivers" 2>/dev/null | head -5
echo
echo "=== System.map 里可疑 init 函数"
grep -E ' [tT] (__initcall|.*_init[0-9]?)$| [tT] .*(cpufreq|ufs|rpmh|icc|devfreq|thermal).*init' "$N/System.map" 2>/dev/null | grep -iE 'cpufreq|ufs|rpmh|icc|devfreq' | head -20
echo
echo "=== 用 nm 找 module_platform_driver 生成的 init"
grep -E ' (cpufreq|ufs|rpmh|icc|devfreq|thermal)' "$N/System.map" | grep -E '_init$|_driver$' | head -25
