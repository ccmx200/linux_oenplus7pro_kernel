#!/bin/bash
set -u
K=/root/kbuild/linux/drivers/net/wireless/ath/ath10k
echo "=== board-2 相关解析代码"
grep -rn 'board-2\|board_file\|BOARD_MAGIC\|ath10k_board' "$K"/*.c "$K"/*.h 2>/dev/null | grep -iE 'magic|board-2|fetch_board' | head -15
echo
echo "=== 结构体定义"
grep -rn -A12 'struct ath10k_board_file\|ATH10K_BOARD_MAGIC' "$K"/hw.h "$K"/core.c 2>/dev/null | head -40
