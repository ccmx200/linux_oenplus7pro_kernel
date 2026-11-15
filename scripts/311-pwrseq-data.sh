#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== wcn3998 数据块"
grep -n -B5 -A25 'wcn3998' "$K/drivers/power/sequencing/pwrseq-qcom-wcn.c" | head -50
echo
echo "=== vregs 定义"
grep -n 'vregs\s*=\|static const char' "$K/drivers/power/sequencing/pwrseq-qcom-wcn.c" | head -20
