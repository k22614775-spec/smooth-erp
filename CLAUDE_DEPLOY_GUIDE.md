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

**修正：** 永遠確保 commit_patch.py 的 `parent = run(['git', 'rev-parse'