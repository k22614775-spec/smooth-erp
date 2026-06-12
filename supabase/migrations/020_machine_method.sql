-- 020_machine_method.sql
-- 機台製作方式標準化為四選項；訂單選定機台後由機台帶入（前端鎖定不可改）
-- 冪等：可重複執行

UPDATE machines SET method='1.上板+底板' WHERE method LIKE '1%' AND method <> '1.上板+底板';
UPDATE machines SET method='2.上板→底板' WHERE method LIKE '2%' AND method <> '2.上板→底板';
UPDATE machines SET method='3.清板'      WHERE method LIKE '3%' AND method <> '3.清板';
UPDATE machines SET method='4.清板+彎工' WHERE method LIKE '4%' AND method <> '4.清板+彎工';

NOTIFY pgrst, 'reload schema';
