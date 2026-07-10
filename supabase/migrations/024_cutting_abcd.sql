-- 024_cutting_abcd.sql
-- 裁切明細新增 A/B/C/D 四個文字欄位（各 20 字元），供現場自訂註記
-- 冪等：可重複執行
ALTER TABLE cutting_details ADD COLUMN IF NOT EXISTS "colA" VARCHAR(20);
ALTER TABLE cutting_details ADD COLUMN IF NOT EXISTS "colB" VARCHAR(20);
ALTER TABLE cutting_details ADD COLUMN IF NOT EXISTS "colC" VARCHAR(20);
ALTER TABLE cutting_details ADD COLUMN IF NOT EXISTS "colD" VARCHAR(20);
NOTIFY pgrst, 'reload schema';
