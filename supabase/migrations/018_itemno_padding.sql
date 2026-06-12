-- 018_itemno_padding.sql
-- 項次格式統一為 0010、0020…（4 碼補零）
-- 冪等：可重複執行

UPDATE order_items SET "itemNo" = lpad("itemNo", 4, '0')
WHERE "itemNo" ~ '^\d{1,3}$';

UPDATE cutting_details SET "orderItemNo" = lpad("orderItemNo", 4, '0')
WHERE "orderItemNo" ~ '^\d{1,3}$';

UPDATE labels SET "orderItemNo" = lpad("orderItemNo", 4, '0')
WHERE "orderItemNo" ~ '^\d{1,3}$';

NOTIFY pgrst, 'reload schema';
