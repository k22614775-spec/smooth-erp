#!/bin/bash
# smooth-erp 簡易提交腳本
# 用法：bash commit.sh "修改說明"
set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
MSG="${1:-update}"

cd "$REPO"

# 修復 git index（每次都重建，避免 bad signature 問題）
GIT_INDEX_FILE="$REPO/.git/tmp/fresh_idx" git read-tree HEAD
cp "$REPO/.git/tmp/fresh_idx" "$REPO/.git/index"

# 確保 APP_VERSION 是佔位符（GitHub Actions 部署時才注入真實 SHA）
python3 -c "
import re, sys
src = open('index.html','r',encoding='utf-8').read()
out = re.sub(r\"var APP_VERSION = '[0-9a-f]+'\", \"var APP_VERSION = '0000000'\", src, count=1)
out = re.sub(r'>v[0-9a-f]*<', '>v0000000<', out, count=1)
open('index.html','w',encoding='utf-8').write(out)
print('APP_VERSION 已設為佔位符')
"

git add index.html
git commit -m "$MSG"
echo ""
echo "✅ commit 完成，執行以下指令推送："
echo "   git push origin main"
