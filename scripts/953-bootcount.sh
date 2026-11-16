#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=5"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
cd /boot/loader/entries
mv -f panel.conf "panel+1.conf" 2>/dev/null
ls -l
cp -f /boot/loader/loader.conf /boot/loader/loader.conf.bak
printf "default panel+1.conf\ntimeout 3\n" > /boot/loader/loader.conf
cat /boot/loader/loader.conf
sync; reboot' 2>&1 | grep -v Warning | head -20
echo "=== 等待面板启动（挂起则需手动断电重启，第二次会自动回退）"
sleep 65
for i in $(seq 1 10); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP; uptime
tr -d "\0" < /proc/device-tree/soc@0/dsi@ae94000/status 2>/dev/null || echo no-dsi-node
ls /boot/loader/entries/
dmesg | grep -iE "mdss|dsi|panel|drm" | tail -15' 2>/dev/null)
  if [ -n "$out" ]; then echo "boot $i:"; echo "$out"; exit 0; fi
  echo "boot $i: no ssh"; sleep 12
done
echo "HANG_OR_NO_SSH"
