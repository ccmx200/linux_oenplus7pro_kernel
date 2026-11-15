#!/bin/bash
set -u
U=/root/uboot
echo "=== post_probe / clear 函数"
grep -n 'video_post_probe\|video_clear\|video_sync(' "$U/drivers/video/video-uclass.c" | head -25
echo
echo "=== video_post_probe 尾部"
sed -n "$(grep -n 'static int video_post_probe' "$U/drivers/video/video-uclass.c" | head -1 | cut -d: -f1),+120p" "$U/drivers/video/video-uclass.c" | tail -50
echo
echo "=== include/video.h 里的 video_clear 声明"
grep -n 'video_clear\|video_sync' "$U/include/video.h" | head
