#!/bin/bash
set -uo pipefail
cd /root/qca-tools/tools/scripts/ath10k
cat > /root/guac-board.json <<'EOF'
[
  {"names": ["bus=snoc,qmi-board-id=0,qmi-chip-id=0",
             "bus=snoc,qmi-board-id=0",
             "bus=snoc,qmi-board-id=ff",
             "bus=snoc,qmi-board-id=ff,qmi-chip-id=0",
             "bus=snoc,qmi-board-id=0,qmi-chip-id=30224",
             "bus=snoc,qmi-board-id=ff,qmi-chip-id=30224"],
   "data": "/root/guacfw/bdwlan.bin"}
]
EOF
python3 ath10k-bdencoder -c /root/guac-board.json -o /root/board-2-guac.bin
ls -lh /root/board-2-guac.bin
echo "=== 自检"
python3 ath10k-bdencoder -i /root/board-2-guac.bin 2>&1 | head -20
