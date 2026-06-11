-- 008_pricing_type.sql
-- 庫存主檔新增「定價形式」(pricingType)
-- 機台設定新增「定價機臺形式」(pricingMachineType)
-- 冪等：可重複執行

ALTER TABLE inventory ADD COLUMN IF NOT EXISTS "pricingType" TEXT DEFAULT '';
COMMENT ON COLUMN inventory."pricingType" IS '定價形式';

ALTER TABLE machines ADD COLUMN IF NOT EXISTS "pricingMachineType" TEXT DEFAULT '';
COMMENT ON COLUMN machines."pricingMachineType" IS '定價機臺形式';

-- 重新載入 PostgREST schema cache（必做，否則前端讀不到新欄位）
NOTIFY pgrst, 'reload schema';
