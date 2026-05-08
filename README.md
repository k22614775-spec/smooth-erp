# 誼冠 ERP + MES 整合系統（Supabase 版）

> 原版：Google Apps Script + Google Sheets  
> 新版：Supabase (PostgreSQL + Edge Functions) + GitHub Pages

---

## 架構總覽

```
┌─────────────────────────────┐     HTTPS POST      ┌──────────────────────────┐
│  GitHub Pages               │  ──────────────►   │  Supabase Edge Function  │
│  index.html (前端)          │                     │  /functions/v1/erp-api   │
│  window.API = fetch(...)    │                     │  (Deno TypeScript)       │
└─────────────────────────────┘                     └──────────┬───────────────┘
                                                               │ supabase-js
                                                    ┌──────────▼───────────────┐
                                                    │  Supabase PostgreSQL     │
                                                    │  (20+ 資料表)            │
                                                    └──────────────────────────┘
```

---

## 第一步：建立 Supabase 專案

1. 前往 [supabase.com](https://supabase.com) 登入，點「New Project」
2. 填入名稱（例：`smooth-erp`）、資料庫密碼，選擇最近的 Region（建議 `ap-northeast-1` 東京）
3. 等待專案初始化完成（約 1–2 分鐘）

---

## 第二步：建立資料庫 Schema

1. 在 Supabase Dashboard 左側選「**SQL Editor**」
2. 點「New query」
3. 複製 `supabase/migrations/001_schema.sql` 的全部內容貼入
4. 點「**Run**」（▶）執行
5. 確認右側 Table Editor 中出現 20+ 張資料表

---

## 第三步：部署 Edge Function

### 安裝 Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Windows (PowerShell)
winget install Supabase.CLI

# npm（跨平台）
npm install -g supabase
```

### 登入並連結專案

```bash
# 登入 Supabase
supabase login

# 在專案根目錄初始化（只需做一次）
supabase init

# 連結至您的 Supabase 專案（Project Ref 在 Settings > General）
supabase link --project-ref YOUR_PROJECT_REF
```

### 部署 Edge Function

```bash
# 部署 erp-api 函式
supabase functions deploy erp-api

# 驗證部署
supabase functions list
```

### 設定 Edge Function Secrets

```bash
# Edge Function 需要 service_role key（在 Settings > API 取得）
supabase secrets set SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=eyJhbG...（service_role key）
```

> ⚠️ **安全注意**：`service_role` key 絕對不能寫在前端或 Git！  
> 前端只使用 `anon` key，Edge Function 內部才使用 `service_role`。

### 測試 Edge Function

```bash
# 取得所有訂單（測試）
curl -X POST \
  https://YOUR_PROJECT_REF.supabase.co/functions/v1/erp-api \
  -H "Content-Type: application/json" \
  -H "apikey: YOUR_ANON_KEY" \
  -d '{"action":"listOrderIds"}'
```

---

## 第四步：發布到 GitHub

### 建立 GitHub Repo

```bash
# 進入 smooth-erp 資料夾
cd smooth-erp

# 初始化 Git
git init
git add .
git commit -m "feat: 初始版本 ERP+MES Supabase 遷移"

# 在 GitHub 建立新 Repo（名稱：smooth-erp）後連結
git remote add origin https://github.com/YOUR_USERNAME/smooth-erp.git
git branch -M main
git push -u origin main
```

### 設定 GitHub Secrets

在 GitHub Repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**：

| Secret 名稱 | 值 |
|---|---|
| `SUPABASE_URL` | `https://YOUR_PROJECT_REF.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase Dashboard → Settings → API → `anon` `public` key |

### 開啟 GitHub Pages

1. Repo → **Settings** → **Pages**
2. Source 選「**GitHub Actions**」
3. 推送任何更新到 `main` 分支就會自動重新部署

---

## 第五步：本機開發測試

不需 GitHub Actions，可直接在瀏覽器開啟 `index.html`，但需先設定正確的 Supabase URL：

編輯 `index.html` 頂部的設定區塊：

```html
<script>
  window.SUPABASE_URL      = "https://YOUR_PROJECT_REF.supabase.co";
  window.SUPABASE_ANON_KEY = "YOUR_ANON_KEY";
  window.ERP_API_URL = window.SUPABASE_URL + "/functions/v1/erp-api";
</script>
```

---

## 專案檔案說明

```
smooth-erp/
├── index.html                         ← 前端（ERP+MES 完整 UI，Supabase 版）
├── supabase/
│   ├── migrations/
│   │   └── 001_schema.sql             ← 建立 20+ 張 PostgreSQL 資料表
│   └── functions/
│       └── erp-api/
│           └── index.ts               ← Edge Function（對應原 Code_merged.gs）
├── .github/
│   └── workflows/
│       └── deploy.yml                 ← 自動部署到 GitHub Pages
└── README.md
```

---

## API 對照表（GAS → Supabase Edge Function）

| 原 GAS 函式 | Edge Function action | 說明 |
|---|---|---|
| `loadAllData()` | `loadAllData` | 全量讀取所有表 |
| `getOrders()` | `getOrders` | 訂單+細項 join |
| `getPendingDispatchOrders()` | `getPendingDispatchOrders` | 未派工訂單 |
| `getOrderHeader(id)` | `getOrderHeader` | 訂單主檔單筆 |
| `getOrderItems(id)` | `getOrderItems` | 訂單細項 |
| `getCuttingDetails(id,no)` | `getCuttingDetails` | 裁切細項（合併版）|
| `getOrderFull(id)` | `getOrderFull` | 訂單全資料 |
| `saveOrder(payload)` | `saveOrder` | 建立/更新訂單 |
| `updateOrder(data)` | `updateOrder` | 更新細項 (MES) |
| `saveCuttingReport(recs)` | `saveCuttingReport` | MES 報工結果 |
| `saveLabel(label)` | `saveLabel` | 標籤 upsert |
| `getLabelsByOrder(id)` | `getLabelsByOrder` | 標籤查詢 |
| `getInventoryFull()` | `getInventoryFull` | 庫存三表全讀 |
| `saveInventory(payload)` | `saveInventory` | 庫存覆寫 |
| `searchCoilStock(filter)` | `searchCoilStock` | 鋼捲搜尋 |
| `savePurchase(payload)` | `savePurchase` | 進貨+入庫 |
| `getPurchaseFull(id)` | `getPurchaseFull` | 進貨全資料 |
| `createDispatchFromOrder()` | `createDispatchFromOrder` | 建立派工單 |
| `getDispatchFull(id)` | `getDispatchFull` | 派工全資料 |
| `addCoilMove()` | `addCoilMove` | 鋼捲上架 |
| `endDispatch()` | `endDispatch` | 派工結束+回單 |
| `checkActiveDispatch()` | `checkActiveDispatch` | 機台有無進行中派工 |
| `resetSimulationData()` | `resetSimulationData` | 還原模擬資料 |

---

## 從 Google Sheets 匯出舊資料

若要把舊 Google Sheets 資料匯入 Supabase：

1. 在 Google Sheets 對每張工作表下載 CSV（**檔案 → 下載 → CSV**）
2. 在 Supabase Dashboard → **Table Editor** → 選擇對應表 → 點右上角「**Import data from CSV**」
3. 逐一匯入即可

或透過 Supabase CLI 批次匯入：

```bash
# 範例：匯入 orders.csv
psql postgresql://postgres:[YOUR_DB_PASSWORD]@db.YOUR_PROJECT_REF.supabase.co:5432/postgres \
  -c "\copy orders FROM 'orders.csv' CSV HEADER"
```

---

## 常見問題

**Q: Edge Function 回傳 CORS 錯誤？**  
A: Edge Function 已包含 `Access-Control-Allow-Origin: *`，如仍有問題請確認 Supabase 專案的 CORS 設定（Dashboard → API → CORS）。

**Q: 401 Unauthorized？**  
A: 確認 `index.html` 中的 `SUPABASE_ANON_KEY` 正確，且 GitHub Secret 也已設定。

**Q: Edge Function 部署後無法呼叫？**  
A: 執行 `supabase functions logs erp-api` 查看錯誤日誌。

**Q: 資料表已有資料，再次執行 schema 會清空嗎？**  
A: 不會。`001_schema.sql` 使用 `CREATE TABLE IF NOT EXISTS`，只在資料表不存在時才建立。

---

## 安全建議（上線前）

1. **移除 `anon` 的 `anon_all` policy**，改為依使用者角色設定 RLS
2. **啟用 Supabase Auth**（Email / Google SSO）
3. **Edge Function 加入 JWT 驗證**：驗證 `Authorization: Bearer <user_token>`
4. **環境分離**：建立 development / production 兩個 Supabase 專案

---

最後更新：2026-05-07
