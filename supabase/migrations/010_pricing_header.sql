-- 010_pricing_header.sql
-- 定價設定改為「表頭 / 表身」結構：
--   表頭 pricing_headers：定價編號、定價名稱、生效日期起、生效日期止
--   表身 pricing_table  ：定價形式 × 機台定價形式 × 定價（移除客戶與日期欄，
--                         客戶由客戶系統掛定價編號）
-- 冪等：可重複執行（請先執行 009）

CREATE TABLE IF NOT EXISTS pricing_headers (
  "pricingNo"  TEXT PRIMARY KEY,   -- 定價編號
  name         TEXT DEFAULT '',    -- 定價名稱
  "startDate"  TEXT DEFAULT '',    -- 生效日期起（民國 YYY/MM/DD）
  "endDate"    TEXT DEFAULT '',    -- 生效日期止（空白＝無期限）
  remark       TEXT DEFAULT ''
);

ALTER TABLE pricing_headers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_all" ON pricing_headers;
CREATE POLICY "anon_all" ON pricing_headers FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
GRANT ALL ON pricing_headers TO anon, authenticated;

-- 標準牌價表頭（對應 009 匯入的 STD 表身）
INSERT INTO pricing_headers ("pricingNo", name, "startDate", "endDate")
VALUES ('STD', '標準牌價', '115/06/05', '')
ON CONFLICT ("pricingNo") DO NOTHING;

-- 表身瘦身：移除客戶與日期欄（日期移至表頭）
DROP INDEX IF EXISTS uq_pricing_cell;
ALTER TABLE pricing_table DROP COLUMN IF EXISTS "customerCode";
ALTER TABLE pricing_table DROP COLUMN IF EXISTS "startDate";
ALTER TABLE pricing_table DROP COLUMN IF EXISTS "endDate";
CREATE UNIQUE INDEX IF NOT EXISTS uq_pricing_cell2
  ON pricing_table ("pricingNo","pricingType","pricingMachineType");

NOTIFY pgrst, 'reload schema';
