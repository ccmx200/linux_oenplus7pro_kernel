#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 安装 mesa/vulkan 工具"
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mesa-vulkan-drivers vulkan-tools mesa-utils 2>&1 | tail -2
echo "=== surfaceless EGL 测试（glxinfo 可能无 X）"
glxinfo -B 2>/dev/null | head -8 || echo "no X"
echo "=== GPU 拓扑"
vulkaninfo --summary 2>/dev/null | grep -iE "deviceName|driverName|apiVersion|GPU" | head -10
' 2>&1 | grep -v Warning | head -30
