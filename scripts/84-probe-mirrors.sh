#!/bin/bash
set -u
urls="
https://git.yylx.win/github.com/postmarketOS/pmaports
https://git.yylx.win/github.com/postmarketOS/pmaports.git
https://git.yylx.win/https://github.com/postmarketOS/pmaports.git
https://github.com/postmarketOS/pmaports.git
"
for u in $urls; do
    printf '%-70s ' "$u"
    timeout 25 git ls-remote "$u" HEAD 2>&1 | head -1
done
