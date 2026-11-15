#!/bin/bash
# 在 WSL 里跑构建：把工程同步到 ext4（/root/op7p），再调用 build.sh
# 用法: 10-build.sh <stage...>      stage = kernel | rootfs | bootimg | all
set -euo pipefail

SRC=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro
DST=/root/op7p

mkdir -p "$DST"
rsync -a --delete \
    --exclude 'work/' --exclude 'out/' --exclude 'wsl/' \
    "$SRC/" "$DST/"
chmod +x "$DST/build.sh"

cd "$DST"
echo "=== [$(date +%H:%M:%S)] 开始: $* ==="
for stage in "$@"; do
    echo "=== [$(date +%H:%M:%S)] stage: $stage ==="
    ./build.sh "$stage"
    echo "=== [$(date +%H:%M:%S)] stage 完成: $stage ==="
done
echo "=== [$(date +%H:%M:%S)] 全部完成 ==="
ls -lh "$DST/out" 2>/dev/null || true
