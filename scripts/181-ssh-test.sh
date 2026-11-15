#!/bin/bash
set -u
command -v sshpass >/dev/null || apt-get install -y -qq sshpass >/dev/null 2>&1
echo "=== ping"
ping -c 2 -W 2 172.16.42.1 2>&1 | tail -2
echo "=== ssh banner"
timeout 8 bash -c 'exec 3<>/dev/tcp/172.16.42.1/22; head -1 <&3' 2>/dev/null || echo "(22 端口不可达)"
for u in root user; do
  echo "=== ssh $u"
  sshpass -p 1234 timeout 20 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
      -o PreferredAuthentications=password -o PubkeyAuthentication=no "$u@172.16.42.1" \
      'id; uname -a; cat /etc/shadow | grep -E "^(root|user):"' 2>&1 | head -8
done
