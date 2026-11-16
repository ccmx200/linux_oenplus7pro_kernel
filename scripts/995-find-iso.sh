#!/bin/bash
set -u
for u in "http://mirrors.aliyun.com/ubuntu-releases/24.04/" "http://mirrors.aliyun.com/ubuntu-releases/22.04/" "https://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/24.04/"; do
  echo "== $u"
  curl -sL --max-time 25 "$u" 2>/dev/null | grep -oE 'ubuntu-[0-9.]+-live-server-amd64\.iso' | sort -u | head -3
done
