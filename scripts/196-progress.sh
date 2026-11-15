#!/bin/bash
set -u
echo "=== 构建进程"
ps -eo pid,etime,cmd | grep -E 'mmdebstrap|chroot|apt|dpkg|build\.sh|01-|02-' | grep -v grep | head -12
echo
echo "=== 镜像与挂载"
ls -lh /root/imgbuild/rootfs.img 2>/dev/null
mount | grep -E 'imgbuild|rootdir' | head -5
ls -ld /root/imgbuild/rootdir 2>/dev/null
echo
echo "=== rootdir 里已装了什么"
chroot /root/imgbuild/rootdir /bin/sh -c 'echo hostname=$(cat /etc/hostname 2>/dev/null); ls /boot 2>/dev/null | head; dpkg -l | wc -l' 2>&1 | head -10
