#!/bin/bash
set -u
echo "=== 拉主线最新 dispcc-sm8250.c"
curl -sL --max-time 120 -o /root/dispcc-upstream.c "https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/drivers/clk/qcom/dispcc-sm8250.c"
ls -l /root/dispcc-upstream.c
echo "=== 上游 mdss_gdsc 参数"
grep -n -A10 'static struct gdsc mdss_gdsc' /root/dispcc-upstream.c
echo "=== 本地 mdss_gdsc 参数"
grep -n -A10 'static struct gdsc mdss_gdsc' /root/kbuild/linux/drivers/clk/qcom/dispcc-sm8250.c
echo "=== 上游 vsync clk ops"
grep -n -A3 'disp_cc_mdss_vsync_clk_src = {' /root/dispcc-upstream.c | head
echo "=== 配置"
grep -E '^CONFIG_CLK_QCOM_DISPCC_SM8250|^CONFIG_QCOM_CLK_DISPCC' /root/kbuild/linux/.config
