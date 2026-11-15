#!/bin/bash
set -u
f=/tmp/guac.dts
echo "=== ufs refs"
grep -n "ufs" "$f" | head -20
echo
echo "=== ufs@1d84000 block"
grep -n -A14 "ufs@1d84000" "$f" | head -34
echo
echo "=== ufs phy"
grep -n -A10 "ufsphy@1d87000" "$f" | head -14
echo
echo "=== serial/geni"
grep -nE "serial@|geniqup|uart" "$f" | head -15
