-- 023_label_completion.sql
-- 例外路線 條碼標籤報工「刷標籤即完工」邏輯所需欄位：
--   cutting_details.dispatchUnfinish：未派工量（分吊），初始＝數量，產生標籤時扣除
--   labels.topDone / bottomDone：上板/底板是否已完工（method 2 兩段刷標籤判定）
-- 冪等：可重複執行

ALTER TABLE cutting_details ADD COLUMN IF NOT EXISTS "dispatchUnfinish" INTEGER;
UPDATE cutting_details SET "dispatchUnfinish" = qty WHERE "dispatchUnfinish" IS NULL;

ALTER TABLE labels ADD COLUMN IF NOT EXISTS "topDone" INTEGER DEFAULT 0;
ALTER TABLE labels ADD COLUMN IF NOT EXISTS "bottomDone" INTEGER DEFAULT 0;

NOTIFY pgrst, 'reload schema';
