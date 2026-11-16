#!/bin/bash
set -u
F=/root/kbuild/linux/drivers/gpu/drm/panel/panel-samsung-ams639rq08.c
echo "=== 行数"; wc -l "$F"
echo "=== compatible / supply"
grep -n -e compatible -e supply -e regulator "$F" | head -20
echo "=== 模式参数"
grep -n -e hdisplay -e vdisplay -e clock -e dsc "$F" | head -20
echo "=== probe/enable 关键函数名"
grep -n -e static -e prepare -e enable "$F" | head -20
