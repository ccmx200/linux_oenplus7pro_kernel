#!/bin/bash
set -u
python3 - <<'PY'
import re
x=open('/root/opsout/settings.xml',encoding='utf-8-sig').read()
progs=re.findall(r'<program[^>]*>', x)
rows=[]
for p in progs:
    def g(k):
        m=re.search(k+r'="([^"]*)"', p); return m.group(1) if m else ''
    rows.append((int(g('physical_partition_number') or 0), g('label'), g('size_in_KB'), g('start_sector')))
rows=[r for r in rows if r[1]]
from collections import defaultdict
d=defaultdict(list)
for lun,label,size,start in rows: d[lun].append((label,size,start))
for lun in sorted(d):
    print(f"\n===== LUN{lun} =====")
    for label,size,start in d[lun]:
        try: s=f"{float(size)/1024:.1f} MB"
        except: s=size
        print(f"  {label:22s} {s:>12}  start_sector={start}")
PY
