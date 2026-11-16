#!/bin/bash
set -uo pipefail
cd /root/qca-tools/tools/scripts/ath10k
cat > /root/guac-board2-real.json <<'EOF'
[
  {"names": ["bus=snoc,qmi-board-id=ff,qmi-chip-id=30224",
             "bus=snoc,qmi-board-id=ff",
             "bus=snoc,qmi-board-id=0,qmi-chip-id=30224",
             "bus=snoc,qmi-board-id=0"],
   "data": "/root/guacfw/bdwlan.bin"}
]
EOF
python3 ath10k-bdencoder -c /root/guac-board2-real.json -o /root/board-2-guac-real.bin
ls -lh /root/board-2-guac-real.bin
python3 ath10k-bdencoder -i /root/board-2-guac-real.bin 2>&1 | head -10
