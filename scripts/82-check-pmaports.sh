#!/bin/bash
set -u
D=/root/.local/var/pmbootstrap/cache_git/pmaports
if [ -d "$D/.git" ]; then
    echo "clone: OK"
    git -C "$D" log -1 --format='%h %s' 2>&1 | head -2
    echo "size: $(du -sh "$D" | cut -f1)  git: $(du -sh "$D/.git" | cut -f1)"
    ls "$D" | head -8
    echo "--- device pkg"
    ls "$D/device/testing/device-oneplus-guacamole" 2>/dev/null || echo "missing device pkg"
else
    echo "clone: NOT READY"
    du -sh "$D" 2>/dev/null || echo "no dir"
fi
echo "--- processes"
ps aux | grep -E 'git |pmbootstrap' | grep -v grep | head -5 || true
echo "--- nura build log tail"
tail -8 /root/.local/var/pmbootstrap/log.txt 2>/dev/null || true
