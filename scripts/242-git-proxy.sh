#!/bin/bash
set -u
echo "=== 代理连通性（Windows 侧 31181，mirrored 模式下 WSL 可直连 127.0.0.1）"
timeout 5 bash -c 'exec 3<>/dev/tcp/127.0.0.1/31181' 2>/dev/null && echo "proxy 31181 OK" || echo "proxy 31181 不可达"

git config --global http.proxy http://127.0.0.1:31181
git config --global https.proxy http://127.0.0.1:31181
git config --global http.sslVerify false
git config --global https.sslVerify false
echo "=== git 代理配置"
git config --global --get http.proxy
git config --global --get http.sslVerify

echo "=== 用代理访问仓库（不带 token）"
cd /root/kernel-repo
git remote set-url origin https://github.com/ccmx200/linux_oenplus7pro_kernel.git
timeout 60 git ls-remote origin 2>&1 | head -5
