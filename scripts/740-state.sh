#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=8"
for i in $(seq 1 10); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 'echo UP; uptime; ip -br link | grep -i wlan || echo no-wlan; lsmod | grep -c ath10k' 2>/dev/null)
  if [ -n "$out" ]; then echo "$out"; exit 0; fi
  echo "wait$i"; sleep 12
done
echo DOWN
