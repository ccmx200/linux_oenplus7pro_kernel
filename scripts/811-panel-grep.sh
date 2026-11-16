#!/bin/bash
set -u
D=/root/hotdog/aports/device/testing/linux-oneplus-hotdog-mainline616
echo "=== 含面板/regulator 关键字的补丁"
grep -l -iE 'amoled|labibb|lab-ibb|panel-samsung|drm_panel|dsi' "$D"/*.patch 2>/dev/null | head -20
echo
echo "=== 补丁文件名里含 panel/lab/ibb 的"
ls "$D" | grep -iE 'panel|amoled|lab|ibb|dsc' | head -20
echo
echo "=== DTS 里 lab/ibb 相关 grep（来自 dts 补丁）"
grep -rn -iE 'lab|ibb|amoled' "$D"/0022-*.patch "$D"/0012-*.patch 2>/dev/null | head -10
