#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=6"
for i in $(seq 1 10); do
  if ping -c1 -W2 172.16.42.1 >/dev/null 2>&1; then echo "ping ok ($i)"; fi
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP; uptime; ip -br link | grep -i wlan || echo no-wlan' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "retry $i"; sleep 15
done
echo "STILL_DOWN"
