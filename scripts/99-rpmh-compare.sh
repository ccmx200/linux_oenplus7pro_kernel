#!/bin/bash
set -u
N=/root/nura-kernel/linux
G=/root/op7p/work/linux
echo "=== 6.4 rpmh-regulator: 是否有 no-readback / readback 逻辑"
grep -n "no-readback\|no_readback\|skip_readback\|get_voltage" "$N/drivers/regulator/qcom-rpmh-regulator.c" | head -20
echo
echo "=== 6.4 里 'Setting' 打印位置"
grep -n "Setting %d-%duV\|Setting %d" "$N/drivers/regulator/qcom-rpmh-regulator.c" | head -5
echo
echo "=== 7.3 (raphael 树) 的 no-readback 实现"
grep -n "no-readback\|no_readback\|skip_readback" "$G/drivers/regulator/qcom-rpmh-regulator.c" | head -20
echo
echo "=== 6.4 rpmh.c 是否有读通道超时保护"
grep -n "rpmh_read\|read_channel\|ETIMEDOUT\|timeout" "$N/drivers/soc/qcom/rpmh.c" | head -15
