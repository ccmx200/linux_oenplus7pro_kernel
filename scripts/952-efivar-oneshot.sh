#!/bin/bash
set -u
OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no -o ConnectTimeout=5"
sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
mountpoint -q /sys/firmware/efi/efivars || mount -t efivarfs none /sys/firmware/efi/efivars 2>/dev/null
GUID=4a67b082-0a4c-41cf-b6c7-440b29bb8c4f
F=/sys/firmware/efi/efivars/LoaderEntryOneShot-$GUID
echo "=== efivars"
ls /sys/firmware/efi/efivars | head -5
ls -l "$F" 2>/dev/null
python3 - <<PY
import struct
path = "/sys/firmware/efi/efivars/LoaderEntryOneShot-4a67b082-0a4c-41cf-b6c7-440b29bb8c4f"
data = struct.pack("<I", 0x7) + "panel.conf".encode("utf-16-le") + b"\x00\x00"
try:
    with open(path, "wb") as f:
        f.write(data)
    print("oneshot written:", len(data), "bytes")
except Exception as e:
    print("write failed:", e)
PY
echo "=== 校验"
xxd -l 64 "$F" 2>/dev/null
echo "=== 重启"
sync; reboot' 2>&1 | grep -v Warning | head -25
echo "=== 等待面板 DTB 启动"
sleep 65
for i in $(seq 1 10); do
  out=$(sshpass -p 1234 ssh $OPTS root@172.16.42.1 '
echo UP; uptime
tr -d "\0" < /proc/device-tree/soc@0/dsi@ae94000/status 2>/dev/null || echo no-dsi-node
dmesg | grep -iE "mdss|dsi|panel|drm" | tail -12' 2>/dev/null)
  if [ -n "$out" ]; then echo "boot $i:"; echo "$out"; exit 0; fi
  echo "boot $i: no ssh"; sleep 12
done
echo "HANG_OR_NO_SSH"
