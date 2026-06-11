-- 012_pricing_versioning.sql
-- 定價設定以「定價編號＋生效日期起」為複合鍵（同一編號可有多版本價格）
-- 生效日期止由系統自動帶入「下一版本的生效日期起」（最後一版＝空白無期限）
-- 冪等：可重複執行（請先執行 009、010、011）

-- 1) pricing_headers：PK 改為 (pricingNo, startDate)
UPDATE pricing_headers SET "startDate"='' WHERE "startDate" IS NULL;
ALTER TABLE pricing_headers ALTER COLUMN "startDate" SET DEFAULT '';
ALTER TABLE pricing_headers ALTER COLUMN "startDate" SET NOT NULL;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname='pricing_headers_pkey'
             AND conrelid='pricing_headers'::regclass
             AND (SELECT count(*) FROM unnest(conkey)) = 1) THEN
    ALTER TABLE pricing_headers DROP CONSTRAINT pricing_headers_pkey;
    ALTER TABLE pricing_headers ADD PRIMARY KEY ("pricingNo","startDate");
  END IF;
END $$;

-- 2) pricing_table：表身加 startDate（綁定版本）
ALTER TABLE pricing_table ADD COLUMN IF NOT EXISTS "startDate" TEXT NOT NULL DEFAULT '';

-- 既有表身回填所屬表頭的起日（目前一編號一版本，對應唯一）
UPDATE pricing_table t SET "startDate" = h."startDate"
FROM pricing_headers h
WHERE t."pricingNo" = h."pricingNo"
  AND (t."startDate" = '' OR t."startDate" IS NULL)
  AND h."startDate" <> '';

-- 3) 唯一鍵改為 (編號, 起日, 形式, 機台形式)
DROP INDEX IF EXISTS uq_pricing_cell2;
DROP INDEX IF EXISTS uq_pricing_cell3;
CREATE UNIQUE INDEX uq_pricing_cell3
  ON pricing_table ("pricingNo","startDate","pricingType","pricingMachineType");
CREATE INDEX IF NOT EXISTS idx_pricing_ver ON pricing_table ("pricingNo","startDate");

NOTIFY pgrst, 'reload schema';
