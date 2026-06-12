-- 014_inventory_pricing_seed.sql
-- 庫存主檔：ZBE0.500*0255R001 定價形式 = 燁輝(鍍鋅)-0.5
-- 冪等：可重複執行

UPDATE inventory SET "pricingType" = '燁輝(鍍鋅)-0.5'
WHERE model = 'ZBE0.500*0255R001';

NOTIFY pgrst, 'reload schema';
