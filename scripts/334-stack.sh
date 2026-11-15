#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo "=== 找卡在 ath10k/pwrseq 的内核栈"
for p in /proc/[0-9]*/stack; do
  [ -r "$p" ] || continue
  if grep -qE "ath10k|pwrseq|qmi|regulator" "$p" 2>/dev/null; then
    pid=$(echo "$p" | cut -d/ -f3)
    echo "--- pid $pid: $(tr -d "\0" < /proc/$pid/comm 2>/dev/null)"
    cat "$p" 2>/dev/null | head -12
  fi
done
echo "=== D 状态进程"
ps -eo pid,stat,comm | awk "\$2 ~ /D/" | head -10
' 2>&1 | grep -v Warning | head -60
