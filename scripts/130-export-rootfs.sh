#!/bin/bash
# 导出 raw rootfs，并生成用于 EDL 写 userdata 的 rawprogram xml
set -euo pipefail
W=/root/.local/var/pmbootstrap
OUT=/mnt/c/Users/cuicanmx/Documents/deepseek-harness/default-workspace/oneplus7pro/nura-out
ROOT=$W/chroot_native/home/pmos/rootfs/oneplus-guacamole.img
mkdir -p "$OUT"

SIZE=$(stat -c%s "$ROOT")
SEC=$(( (SIZE + 4095) / 4096 ))
echo "image bytes=$SIZE sectors=$SEC"

cp -f "$ROOT" "$OUT/nura-rootfs.img"
ls -lh "$OUT/nura-rootfs.img"

cat > "$OUT/rawprogram-userdata.xml" <<EOF
<?xml version="1.0" ?>
<data>
  <program SECTOR_SIZE_IN_BYTES="4096" file_sector_offset="0" filename="nura-rootfs.img" label="userdata" num_partition_sectors="$SEC" physical_partition_number="4" readbackverify="false" size_in_KB="$((SIZE/1024))" sparse="false" start_byte_hex="0x0" start_sector="1945992"/>
</data>
EOF
cat "$OUT/rawprogram-userdata.xml"
