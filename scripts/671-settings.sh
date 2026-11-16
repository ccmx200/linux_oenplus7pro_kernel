#!/bin/bash
set -u
cd /root/opsout
echo "=== gpt_main0.bin 里 EFI PART 的位置"
grep -aob 'EFI PART' gpt_main0.bin | head -3
xxd -l 64 gpt_main0.bin
echo
echo "=== settings.xml（前 120 行）"
sed -n '1,120p' settings.xml
