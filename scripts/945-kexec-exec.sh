#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=5"
echo "=== 触发 kexec"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 'sync; (sleep 1; kexec -e) >/dev/null 2>&1 & echo triggered' 2>&1 | grep -v Warning | head -3
echo "=== 轮询 SSH（每 10s）"
for i in $(seq 1 9); do
  sleep 10
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP; uptime; dmesg | grep -icE "msm|mdss|dsi|panel"' 2>/dev/null)
  if [ -n "$out" ]; then echo "attempt $i:"; echo "$out"; exit 0; fi
  echo "attempt $i: no ssh"
done
echo "HANG_OR_REBOOT"
