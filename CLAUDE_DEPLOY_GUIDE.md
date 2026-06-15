# Claude 發布流程指南（單頁 HTML 專案）

> 本文件供 Claude 讀取後直接執行發布流程。  
> 適用情境：單一 `index.html` 檔案透過 GitHub Pages 對外提供服務的專案。

---

## 一、專案基本設定（每個新專案填寫一次）

| 項目 | 值 |
|------|-----|
| 本機 Git 根目錄（Windows） | `C:\Users\andy\Desktop\誼冠\CLAUDE4.6\{專案名稱}\` |
| Linux sandbox 路徑 | `/sessions/{session-id}/mnt/CLAUDE4.6/{專案名稱}/` |
| 主要編輯檔案 | `index.html`（位於 Git repo 根目錄） |
| GitHub 遠端 | `https://github.com/k22614775-spec/{repo-name}.git` |
| 部署方式 | GitHub Pages（main 分支，根目錄 `/`） |

> **注意**：Linux sandbox 的 session-id 每次會話不同，Claude 每次開始前需先用 `pwd` 或 `ls /sessions/` 確認實際路徑。

---

## 二、Claude 執行 Commit 的標準流程

### 核心規則（必須遵守）

1. **parent SHA 永遠用 `git rev-parse HEAD` 動態取得，絕不寫死任何 SHA 字串**
2. 每次 commit 後必須同步更新 `APP_VERSION` 與 `ver-badge`
3. 每次 commit 後必須驗證磁碟檔案與 git blob 的 md5 一致
4. commit 完成後顯示 SHA 與 diff 供確認

### commit_patch.py 標準模板

將此檔案放在專案根目錄，Claude 透過 bash 呼叫：

```python
#!/usr/bin/env python3
"""
{專案名稱} index.html commit 工具
供 Claude 在 bash 中以 python3 inline 或直接執行。
"""
import subprocess, re, os, shutil, hashlib

# ── 路徑設定（每個專案修改此區塊）──────────────────────────
REPO = '/sessions/{session-id}/mnt/CLAUDE4.6/{專案名稱}'
DISK = os.path.join(REPO, 'index.html')
# ────────────────────────────────────────────────────────────

def run(cmd, env=None, check=True):
    r = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True,
                       env=env or os.environ)
    if check and r.returncode != 0:
        raise RuntimeError(f'cmd={cmd}\nstderr={r.stderr}')
    return r.stdout.strip()

def commit_index(src_content, message):
    """
    把 src_content 寫入 index.html 並建立 git commit。
    ★ parent 永遠是目前 HEAD，確保 fast-forward，避免 non-fast-forward 錯誤。
    回傳最終 commit SHA（7碼）。
    """
    pid = os.getpid()
    tmp1 = f'/tmp/ci_pass1_{pid}.html'
    with open(tmp1, 'w', encoding='utf-8') as f:
        f.write(src_content)

    # ── Pass 1：取得新 SHA ────────────────────────────────
    blob1  = run(['git', 'hash-object', '-w', tmp1])
    idx    = f'/tmp/ci_idx_{pid}'
    env    = {**os.environ, 'GIT_INDEX_FILE': idx}
    parent = run(['git', 'rev-parse', 'HEAD'])   # ★ 永遠動態讀取

    subprocess.run(['git', 'read-tree', 'HEAD'], cwd=REPO, env=env, check=True)
    subprocess.run(['git', 'update-index', '--add', '--cacheinfo',
                    f'100644,{blob1},index.html'], cwd=REPO, env=env, check=True)
    tree1 = subprocess.run(['git', 'write-tree'], cwd=REPO, env=env,
                           capture_output=True, text=True, check=True).stdout.strip()
    sha1  = subprocess.run(
        ['git', 'commit-tree', tree1, '-p', parent, '-m', message],
        cwd=REPO, capture_output=True, text=True, check=True).stdout.strip()
    sha7  = sha1[:7]

    # ── Pass 2：將 APP_VERSION / ver-badge 更新為正確 SHA ─
    src2 = re.sub(r"var APP_VERSION = '[0-9a-f]+'",
                  f"var APP_VERSION = '{sha7}'", src_content, count=1)
    src2 = re.sub(r">v[0-9a-f]+<", f">v{sha7}<", src2, count=1)

    tmp2 = f'/tmp/ci_pass2_{pid}.html'
    with open(tmp2, 'w', encoding='utf-8') as f:
        f.write(src2)

    blob2 = run(['git', 'hash-object', '-w', tmp2])
    subprocess.run(['git', 'update-index', '--add', '--cacheinfo',
                    f'100644,{blob2},index.html'], cwd=REPO, env=env, check=True)
    tree2 = subprocess.run(['git', 'write-tree'], cwd=REPO, env=env,
                           capture_output=True, text=True, check=True).stdout.strip()
    sha_final = subprocess.run(
        ['git', 'commit-tree', tree2, '-p', parent, '-m', message],
        cwd=REPO, capture_output=True, text=True, check=True).stdout.strip()

    # ── 更新 HEAD（refs/heads/main）────────────────────────
    ref_path = os.path.join(REPO, '.git/refs/heads/main')
    with open(ref_path, 'w') as f:
        f.write(sha_final + '\n')

    # ── 同步磁碟 index.html ─────────────────────────────────
    shutil.copy2(tmp2, DISK)

    # ── 驗證 md5 一致 ───────────────────────────────────────
    d = hashlib.md5(open(DISK, 'rb').read()).hexdigest()
    g = hashlib.md5(subprocess.run(['git', 'show', 'HEAD:index.html'],
                    cwd=REPO, capture_output=True).stdout).hexdigest()
    assert d == g, f'磁碟/git md5 不符！disk={d} git={g}'

    print(f'✅ commit {sha_final[:7]}  {message}')
    return sha_final[:7]

if __name__ == '__main__':
    print('此檔案為 Claude 內部使用模組，直接執行無作用。')
```

---

## 三、Claude 執行 Commit 的 Bash inline 範例

當 Claude 在對話中修改 `index.html` 後，執行以下 Python inline（不需要 commit_patch.py 也能獨立運作）：

```bash
python3 - <<'PYEOF'
import subprocess, re, os, shutil, hashlib

REPO = '/sessions/{session-id}/mnt/CLAUDE4.6/{專案名稱}'
DISK = os.path.join(REPO, 'index.html')

# 1. 讀取現有 index.html
with open(DISK, 'r', encoding='utf-8') as f:
    src = f.read()

# 2. 在這裡對 src 做修改
# src = src.replace('舊字串', '新字串')

# 3. Commit（使用標準 commit_index 邏輯）
import sys
sys.path.insert(0, REPO)
from commit_patch import commit_index
sha7 = commit_index(src, 'fix: 說明修改內容')

# 4. 顯示 diff
subprocess.run(['git', 'show', '--stat', 'HEAD'], cwd=REPO)
PYEOF
```

---

## 四、Commit 後確認項目（Claude 必做）

每次 commit 完成後，Claude 必須輸出以下資訊：

```
✅ commit {sha7}  {commit message}
異動檔案：index.html
diff 摘要：{顯示 git show --stat HEAD 輸出}
```

---

## 四-A、Edit 工具操作後的檔案完整性檢查（⚠️ 必做，缺一不可）

> **背景**：Edit 工具進行大段落替換時，若新內容行數遠多於舊內容，可能導致檔案結尾被截斷，
> 造成 `ReactDOM.createRoot`、`</script>`、`</body>`、`</html>` 等關鍵結尾遺失，
> MES 頁面因 Babel 無法完成編譯而顯示**空白畫面**。

### 每次 Edit 操作後，Claude 必須執行以下 4 項驗證：

```bash
# 1. 確認關鍵結尾存在
grep -c "ReactDOM.createRoot"  index.html   # 必須 = 1
grep -c "window.mountMesApp"   index.html   # 必須 = 1
grep -c "</script>"            index.html   # 必須 >= 1
grep -c "</html>"              index.html   # 必須 = 1

# 2. 確認行數合理（不應比前一版少超過 10 行）
wc -l index.html

# 3. 確認末尾內容正確
tail -5 index.html   # 應顯示 </script> </body> </html>

# 4. 確認 MES tab 區塊渲染路徑完整（不應有截斷的 JSX）
grep -c "mainTab === 'cut'" index.html   # 必須 >= 1
```

### 若發現截斷，修復流程：

```bash
# Step 1：找出截斷點在舊版中的對應行號
git show HEAD~1:index.html | grep -n "截斷行最後幾個字" | tail -3

# Step 2：重組檔案
head -n $((截斷行-1)) index.html > /tmp/part1.html
git show HEAD~1:index.html | tail -n +$OLD_LINE > /tmp/tail.html
cat /tmp/part1.html /tmp/tail.html > index.html

# Step 3：重新驗證並 commit
```

---

## 五、使用者推送到 GitHub（使用者操作）

Claude **不能**直接執行 `git push`（需要 GitHub 認證），由使用者在本機 CMD / Terminal 執行：

```cmd
cd C:\Users\andy\Desktop\誼冠\CLAUDE4.6\{專案名稱}
git push origin main
```

推送成功後，GitHub Pages 約 **1–3 分鐘**後自動更新，可至以下網址確認：

```
https://k22614775-spec.github.io/{repo-name}/
```

頁面右上角的「版次徽章」應顯示最新 commit SHA（如 `v8ed239a`）。

---

## 六、新專案初始化步驟

### 6-1 本機初始化（使用者操作）

```cmd
mkdir C:\Users\andy\Desktop\誼冠\CLAUDE4.6\{新專案名稱}
cd C:\Users\andy\Desktop\誼冠\CLAUDE4.6\{新專案名稱}
git init
git checkout -b main
git config user.email "k22614775@gmail.com"
git config user.name "andy fu"
```

### 6-2 建立初始 index.html

在 `index.html` 中加入版次徽章元素：

```html
<!-- 頂部工具列中 -->
<span id="ver-badge"
  style="margin-left:auto;font-size:11px;background:rgba(255,255,255,.12);
         border:1px solid rgba(255,255,255,.25);border-radius:4px;
         padding:2px 8px;cursor:default;font-family:monospace"
  title="目前部署版次 (git commit)">v0000000</span>

<!-- JS 區塊中 -->
<script>
var APP_VERSION = '0000000';  // __APP_VERSION__
(function(){
  var el = document.getElementById('ver-badge');
  if(el) el.textContent = 'v' + APP_VERSION;
})();
</script>
```

### 6-3 第一次 Commit 與推送

Claude 執行第一次 commit（透過 commit_patch.py），使用者再執行：

```cmd
git remote add origin https://github.com/k22614775-spec/{新repo名稱}.git
git push -u origin main
```

### 6-4 GitHub Pages 設定（使用者操作，一次性）

1. 前往 GitHub repo → **Settings** → **Pages**
2. Source 選 **Deploy from a branch**
3. Branch 選 **main**，Folder 選 **/ (root)**
4. 點 **Save**

---

## 七、常見錯誤與排除

### non-fast-forward 推送失敗

**症狀：**
```
! [rejected] main -> main (non-fast-forward)
error: failed to push some refs
```

**原因：** commit 時使用了寫死的舊 SHA 作為 parent，導致本地分支與 GitHub 分叉。

**修正：** 永遠確保 commit_patch.py 的 `parent = run(['git', 'rev-parse', 'HEAD'])` 是動態取得，不可手動填入任何 SHA。

若已發生分叉，先拉取遠端再 rebase：
```cmd
git fetch origin
git rebase origin/main
git push origin main
```

### 磁碟與 git blob md5 不符

**症狀：** `AssertionError: 磁碟/git md5 不符`

**原因：** `shutil.copy2` 失敗，或路徑設定錯誤。

**修正：** 確認 `DISK` 路徑正確，且 Linux sandbox 對該目錄有寫入權限。

### ver-badge 顯示舊版本號

**原因：** APP_VERSION 未在 Pass 2 更新，或 regex 沒有匹配到。

**修正：** 確認 `index.html` 中有以下兩個 regex 可匹配的字串：
- `var APP_VERSION = '7碼hex'`
- `>v7碼hex<`（ver-badge 的 textContent）

---

## 八、檔案結構參考

```
{專案名稱}/
├── index.html          ← 主要單頁應用（唯一需要 commit 的檔案）
├── commit_patch.py     ← Claude 使用的 commit 工具
├── PUSH_TO_GITHUB.bat  ← 使用者初次設定用（Windows）
├── README.md           ← 專案說明
└── .git/               ← Git repo
```

---

## 九、Claude 收到修改需求時的標準作業流程

```
1. 讀取 index.html（Read 工具或 bash cat）
2. 在記憶體中修改程式碼
3. 語法驗證（確認無 unclosed block、silent catch 等問題）
4. 呼叫 commit_index() 執行 single-pass commit
5. 輸出 commit SHA 與 diff 摘要
6. 提示使用者執行 git push origin main
```

---

## 十、⚠️ 發布前必做檢查清單（Claude 每次 commit 後必須完成）

> 每次修改完成、準備讓使用者 push 之前，Claude 必須依序確認以下所有項目。

### ✅ 步驟 1：確認 git blob 內容正確

```bash
# 1-A 關鍵結尾完整性（避免 MES 空白畫面）
grep -c "ReactDOM.createRoot" index.html   # 必須 = 1
grep -c "window.mountMesApp"  index.html   # 必須 = 1
grep -c "</html>"             index.html   # 必須 = 1
tail -5 index.html                          # 末尾必須是 </script></body></html>

# 1-B APP_VERSION 格式可被 GitHub Actions sed 匹配
grep "APP_VERSION" index.html | head -2
# 應顯示：var APP_VERSION = 'XXXXXXX';（任意 7 碼 hex，包含 0000000）
# ❌ 不可出現非 hex 字元，否則 sed 無法替換
```

### ✅ 步驟 2：確認本地 HEAD 與 origin/main 的差距

```bash
git log --oneline origin/main..HEAD
# 列出「已 commit 但尚未推送」的 commit
# 若有輸出 → 表示有待推送的 commit，需通知使用者 git push
# 若無輸出 → 本地已和 GitHub 同步
```

**⚠️ 常見陷阱：** `origin/main` ref 在 sandbox 裡是本地快取，不會自動更新。
判斷方式：`cat .git/refs/remotes/origin/main` 的值若與 `git rev-parse HEAD` 不同，即有未推送 commit。

### ✅ 步驟 3：確認 APP_VERSION 不是「殘留的舊 ghost SHA」

```bash
git show HEAD:index.html | grep "APP_VERSION"
```

**背景說明：**
- `commit_patch.py`（single-pass）的 git blob 保留呼叫時傳入的原始內容
- disk 檔案會被更新為 `sha7`（新 commit 的前 7 碼），供本機預覽
- GitHub Actions 部署時的 `sed` 會把 blob 裡的舊值替換成正確的 deploy SHA
- **如果 blob 裡的 APP_VERSION 是非 hex 字元**，sed 不會替換，版次徽章會顯示錯誤

**正常狀態範例：**
```
var APP_VERSION = 'cc0ebb9';   ← OK，sed 會替換
var APP_VERSION = '0000000';   ← OK，sed 會替換
var APP_VERSION = '47ec404';   ← OK，sed 會替換
```

### ✅ 步驟 4：確認 deploy.yml 有 Inject version sha 步驟

```bash
grep -c "Inject version sha" .github/workflows/deploy.yml
# 必須 = 1
# 若 = 0，表示 deploy.yml 遺失注入步驟，頁面版次不會自動更新
```

### ✅ 步驟 5：確認推送後的部署結果（使用者 push 後約 3–5 分鐘）

1. 前往 `https://github.com/k22614775-spec/smooth-erp` → 確認最新 commit SHA
2. 前往 `https://k22614775-spec.github.io/smooth-erp/` → 確認頁面右上角版次徽章
3. 版次徽章應顯示與 GitHub commit SHA **前 7 碼相符**

**⚠️ 若版次徽章顯示舊值，排查順序：**

| 症狀 | 原因 | 解法 |
|------|------|------|
| 無痕模式也顯示舊版 | GitHub Pages CDN 尚未刷新（最多 10–15 分鐘） | 等待後再試 |
| 版次顯示 `v7c2600d`（非本次 SHA） | cdeb033 之前的舊部署仍被 CDN 服務 | 推送新 commit，觸發新部署 |
| 版次正確但畫面無變化 | 瀏覽器快取 | `Ctrl+Shift+R` 強制重整 |
| GitHub Actions log 顯示失敗 | deploy.yml 或 Secrets 設定問題 | 檢查 Actions → 對應 workflow run |

---

## 十一、APP_VERSION 版次徽章機制說明

```
commit_patch.py 行為（single-pass）：
  ┌─────────────────────────────────────────────────────┐
  │  輸入 src_content（含任意 APP_VERSION 值）            │
  │     ↓                                               │
  │  git hash-object → git blob（保留 src_content 原值） │
  │     ↓                                               │
  │  git commit-tree → sha_final                        │
  │     ↓                                               │
  │  disk 檔案 APP_VERSION 更新為 sha_final[:7]           │
  │  （供本機預覽，不影響 git blob）                      │
  └─────────────────────────────────────────────────────┘

GitHub Actions 部署行為：
  ┌─────────────────────────────────────────────────────┐
  │  checkout（取 git blob 原始值）                       │
  │     ↓                                               │
  │  SHA=$(git rev-parse --short HEAD)                  │
  │  sed 替換 APP_VERSION → 正確的 deploy SHA            │
  │     ↓                                               │
  │  部署到 GitHub Pages → 頁面版次 = GitHub commit SHA  │
  └─────────────────────────────────────────────────────┘
```

**結論：** 只要 blob 裡的 APP_VERSION 是合法的 hex 字串（包括 `0000000`），
GitHub Actions 的 sed 就能正確替換。**不依賴 blob 裡的值是否正確，只依賴格式正確。**

---

## 十二、⛔ 本次事故根因與禁止事項（2026-05 實際踩雷）

### 事故摘要

部署後頁面版次停在舊值 `v7c2600d`，多次 commit 與 push 後仍無法更新，
最終追查到**兩個根本錯誤**，寫入規則以防重蹈。

---

### ❌ 錯誤一：用 `git commit --allow-empty` 強制重新部署

**發生原因：**

`commit_patch.py` 使用 **獨立的臨時 index**（`GIT_INDEX_FILE=/tmp/ci_idx_{pid}`），
commit 完成後 `.git/index`（正式的 staging area）**從未被更新**。

當使用者或 Claude 在 bash 執行：

```bash
git commit --allow-empty -m "chore: force re-deploy"
```

git 讀取的是 `.git/index` 裡殘留的舊 blob（例如寫死了 `cc0ebb9` 的版本），
而不是 HEAD tree 的內容，導致新 commit 的 blob 含有錯誤的 SHA。

**禁止規則（永久）：**

> ⛔ **絕對禁止**使用 `git commit --allow-empty` 強制觸發部署。
> 這個指令在本專案永遠可能帶入 `.git/index` 裡的舊 staged 內容，結果不可預期。

**正確做法（強制重新部署）：**

```python
# 用 commit_patch.py 建一個含 0000000 佔位符的全新 commit
import re
from commit_patch import commit_index

with open(DISK, 'r', encoding='utf-8') as f:
    content = f.read()

# ★ 先正規化佔位符，再傳入 commit_index
src = re.sub(r"var APP_VERSION = '[0-9a-f]+'", "var APP_VERSION = '0000000'", content, count=1)
src = re.sub(r">v[0-9a-f]*<", ">v0000000<", src, count=1)

commit_index(src, "chore: force re-deploy")
```

---

### ❌ 錯誤二：把磁碟上的 index.html（含舊 SHA）直接傳入 `commit_index()`

**發生原因：**

`commit_patch.py` 完成 commit 後，會把 `sha7` 寫回磁碟的 APP_VERSION（供本機預覽）。
若下一次直接讀磁碟檔案後不正規化，就把舊的 SHA（如 `92a3ef4`）當作 `src_content` 傳入，
造成新 blob 寫死了舊 SHA，而不是 `0000000` 佔位符。

**禁止規則（永久）：**

> ⛔ **呼叫 `commit_index()` 前，`src_content` 必須先正規化 APP_VERSION 為 `0000000`。**
> 磁碟上的 index.html 永遠是「本機預覽版」，裡面的 SHA 是上一次 commit 的值，不可直接使用。

**正確的 commit_index 呼叫模式（模板）：**

```python
import re
from commit_patch import commit_index

with open(DISK, 'r', encoding='utf-8') as f:
    content = f.read()

# ── ★ 必做：正規化佔位符 ────────────────────────────────────
src = re.sub(r"var APP_VERSION = '[0-9a-f]+'",
             "var APP_VERSION = '0000000'", content, count=1)
src = re.sub(r">v[0-9a-f]*<", ">v0000000<", src, count=1)
assert "var APP_VERSION = '0000000'" in src, "正規化失敗"
# ────────────────────────────────────────────────────────────

# 在 src 上進行其他修改（如果有）
# src = src.replace(...)

commit_index(src, "fix: 說明修改內容")
```

---

### ❌ 錯誤三：誤判版次未更新的原因（CDN vs 程式問題）

**發生原因：**

GitHub Pages 使用 Fastly CDN，部署完成（Deployments 頁顯示 Active）後，
CDN edge node 可能再需要 **10–15 分鐘**才全球同步。
在這段時間內，無痕模式也會看到舊版，容易誤判為程式或 workflow 有問題，
導致繼續推送新 commit，製造更多混亂。

**正確排查順序：**

```
部署後版次未更新？
  ↓
Step 1：確認 GitHub Deployments 頁面顯示「Active」
  ↓ 是
Step 2：等候 10–15 分鐘，期間不要再推新 commit
  ↓ 仍未更新（超過 15 分鐘）
Step 3：確認 GitHub Actions log → Inject version sha 步驟有無執行成功
  ↓ sed 有執行
Step 4：確認 blob 裡的 APP_VERSION 格式是合法 hex（不含非 hex 字元）
  ↓ 格式錯誤
Step 5：用正確模板重新 commit（見錯誤二），請使用者 git push
```

**禁止行為：**

> ⛔ 等待期間不可連續 push 多個「測試 commit」，會製造多餘的 ghost commit 並污染 git log。
