-- 021_machine_default_material.sql
-- 機台 255 預設底板用料 = ZBE0.500*0255R001（訂單選機台後自動帶入底板用料）
-- 冪等：可重複執行

UPDATE machines SET material = 'ZBE0.500*0255R001'
WHERE id = '255' AND (material IS NULL OR material = '');

NOTIFY pgrst, 'reload schema';
