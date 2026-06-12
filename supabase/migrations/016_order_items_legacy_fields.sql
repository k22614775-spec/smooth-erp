-- 016_order_items_legacy_fields.sql
-- 訂單細項補齊法琪欄位（18 欄）
-- 冪等：可重複執行

ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "quoteNo"            TEXT DEFAULT '';      -- 報價單號
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "salesName"          TEXT DEFAULT '';      -- 銷貨品名
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "styleNo"            TEXT DEFAULT '';      -- 樣式編號
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS remark               TEXT DEFAULT '';      -- 備註
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "costBase"           TEXT DEFAULT '';      -- 成本基準
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "warehouseNo"        TEXT DEFAULT '';      -- 倉庫編號
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "isDispatched"       TEXT DEFAULT '否';    -- 是否派工
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "processRoute"       TEXT DEFAULT '';      -- 加工途程
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "undispatchedQty"    NUMERIC DEFAULT 0;    -- 未派數量
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "undispatchedTotal"  NUMERIC DEFAULT 0;    -- 未派總數
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "dispatchClosed"     TEXT DEFAULT '否';    -- 派結
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "undeliveredQty"     NUMERIC DEFAULT 0;    -- 未交數量
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "undeliveredTotal"   NUMERIC DEFAULT 0;    -- 未交總數
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS closed               TEXT DEFAULT '否';    -- 結案
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "unitWeight"         NUMERIC DEFAULT 0;    -- 單重
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "filmYN"             TEXT DEFAULT '否';    -- 是否貼膜
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "foamYN"             TEXT DEFAULT '否';    -- 是否流發泡
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "arcYN"              TEXT DEFAULT '否';    -- 是否彎弓

NOTIFY pgrst, 'reload schema';
