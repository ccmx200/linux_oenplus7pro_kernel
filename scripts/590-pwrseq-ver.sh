#!/bin/bash
set -u
K=/root/kbuild/linux
echo "=== 内核版本"
head -5 "$K/Makefile" | grep -E "VERSION|PATCHLEVEL|SUBLEVEL|EXTRAVERSION"
echo "=== 驱动文件日期/大小"
ls -l "$K/drivers/power/sequencing/pwrseq-qcom-wcn.c"
git -C "$K" log -1 --format='%h %ad %s' --date=short -- drivers/power/sequencing/pwrseq-qcom-wcn.c 2>/dev/null
echo "=== 驱动里 pwrseq 单元/API"
grep -n 'pwrseq_unit_data\|pwrseq_device_register\|swctrl\|wlan-enable' "$K/drivers/power/sequencing/pwrseq-qcom-wcn.c" | head -12
echo "=== 拉上游最新版（v6.17/mainline）"
curl -sL --max-time 120 -o /root/pwrseq-new.c "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/drivers/power/sequencing/pwrseq-qcom-wcn.c"
ls -l /root/pwrseq-new.c; head -12 /root/pwrseq-new.c
echo "=== 新版是否支持 swctrl"
grep -n 'swctrl\|wlan-enable' /root/pwrseq-new.c | head -10
