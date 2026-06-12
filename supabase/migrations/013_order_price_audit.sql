-- 013_order_price_audit.sql
-- 訂單細項：單價審核欄位（審核人 / 審核時間）
-- 標準單價(standardPrice) 既有欄位改由系統依 定價形式×機台定價形式 自動帶入
-- 冪等：可重複執行

ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "priceAuditor"   TEXT DEFAULT '';
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS "priceAuditTime" TEXT DEFAULT '';

NOTIFY pgrst, 'reload schema';
