#!/bin/bash
set -u
f=/tmp/guac.dts
echo "=== ufshc block (1955-2000)"
sed -n '1955,2005p' "$f"
echo
echo "=== status lines near ufs"
sed -n '1955,2005p' "$f" | grep -n 'status\|supply' || echo "(none)"
