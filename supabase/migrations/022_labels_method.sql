-- 022_labels_method.sql
-- 例外路線：標籤紀錄存「製作方式」(method)，供標籤紀錄管理顯示與條碼標籤報工判斷報幾段。
-- 產生標籤時由訂單帶入，之後不再變動。
-- 冪等：可重複執行

ALTER TABLE labels ADD COLUMN IF NOT EXISTS method TEXT;

NOTIFY pgrst, 'reload schema';
