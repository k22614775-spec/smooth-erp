-- 019_method_labels.sql
-- 製作方式四選項標準化：
--   1.上板+底板（MES 報工需上架上板＋底板兩捲鋼捲）
--   2.上板→底板（先做上板，僅上架上板鋼捲；底板後續另行派工）
--   3.清板（單純上板）
--   4.清板+彎工（上架上板鋼捲；下工序由折工報工處理）
-- 冪等：可重複執行

UPDATE order_items SET method='1.上板+底板' WHERE method LIKE '1%' AND method <> '1.上板+底板';
UPDATE order_items SET method='2.上板→底板' WHERE method LIKE '2%' AND method <> '2.上板→底板';
UPDATE order_items SET method='3.清板'      WHERE method LIKE '3%' AND method <> '3.清板';
UPDATE order_items SET method='4.清板+彎工' WHERE method LIKE '4%' AND method <> '4.清板+彎工';

NOTIFY pgrst, 'reload schema';
