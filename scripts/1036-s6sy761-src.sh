#!/bin/bash
set -u
F=/root/kbuild/linux/drivers/input/touchscreen/s6sy761.c
echo "=== regulator / axis / 属性"
grep -n -e 'regulator' -e 'supply' -e 'axis' -e 'of_property' -e 'ABS_X' -e 'ABS_Y' "$F" | head -30
