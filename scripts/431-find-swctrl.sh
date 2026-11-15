#!/bin/bash
set -u
D=/root/dtbo
echo "=== bt_wcn3990 节点完整内容（entry 0）"
grep -n -A25 'bt_wcn3990 {' "$D/00_id0_rev0_325150.dts" | head -35
echo
echo "=== 所有出现的 sw-ctrl / swctrl 引脚"
grep -rn 'sw-ctrl-gpio\|sw_ctrl' "$D"/*.dts 2>/dev/null | head -10
