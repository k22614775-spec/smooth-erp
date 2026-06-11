-- 011_pricing_category_extras.sql
-- 1) 兩代碼表加 category（報價單類別：烤漆板/特殊斷面/白鐵板/裝潢板/壓花壁板）
-- 2) 新增 pricing_extras（配件/加價，非二維矩陣項目）
-- 3) 匯入 4 份新報價單之代碼、STD 標準價與配件
-- 冪等：可重複執行（請先執行 009、010）

ALTER TABLE pricing_types         ADD COLUMN IF NOT EXISTS category TEXT DEFAULT '';
ALTER TABLE pricing_machine_types ADD COLUMN IF NOT EXISTS category TEXT DEFAULT '';

CREATE TABLE IF NOT EXISTS pricing_extras (
  id          SERIAL PRIMARY KEY,
  "pricingNo" TEXT NOT NULL DEFAULT 'STD',
  category    TEXT DEFAULT '',   -- 報價單類別
  grp         TEXT DEFAULT '',   -- 群組（固定座/止水條/鋁料/琉璃瓦副件/加價…）
  name        TEXT NOT NULL,
  unit        TEXT DEFAULT '',
  price       NUMERIC DEFAULT 0,
  remark      TEXT DEFAULT '',
  seq         INTEGER DEFAULT 0
);
ALTER TABLE pricing_extras ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_all" ON pricing_extras;
CREATE POLICY "anon_all" ON pricing_extras FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
GRANT ALL ON pricing_extras TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- 代碼 category 與新增代碼
INSERT INTO pricing_types (value,category) VALUES ('副牌(鍍鋁)-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('副牌(鍍鋁)-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('副牌(消光)-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('副牌(消光)-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(鍍鋅)-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(鍍鋅)-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(消光)-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(消光)-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(鋁鋅)-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(鋁鋅)-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘(鋁鋅)-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘(鋁鋅)-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘(消光)-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘(消光)-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(礦纖)-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(礦纖)-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(玄鐵)-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(玄鐵)-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝樹脂牙/果/灰-單面','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝樹脂牙/果-雙面','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝樹脂墨綠-單面','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝樹脂紅-單面','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘SMP-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘PVDF-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('鎂合金(烤漆)k22-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('鎂合金(烤漆)k22-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('鎂合金(烤漆)k27-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('鎂合金(烤漆)k27-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('木石紋(盛餘)-0.5','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('髮絲(盛餘)-0.6','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(礦纖玄鐵)-0.6','特殊斷面') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('白鐵(烤漆)-0.4','特殊斷面') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('白鐵(烤漆)-0.5','特殊斷面') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('白鐵(烤透明漆)-0.4','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('白鐵(烤透明漆)-0.5','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('白鐵(烤鋁鋅色)-0.4','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('白鐵(烤鋁鋅色)-0.5','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('白鐵(烤鋁鋅色)-0.6','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('白鐵(烤消光色)-0.4','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('白鐵(烤消光色)-0.5','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('白鐵(烤消光色)-0.6','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('(烤漆)一般-0.5','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('(消光)一般-0.5','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘消光/燁輝玄鐵-0.5','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝單面樹脂/牙/果-0.5','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('一般色(烤漆)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('特殊色(消光)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘(鋁鋅)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘(消光)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(礦纖)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('木紋.石紋','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('燁輝(樹脂)牙.果','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘(烤漆.消光)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘(木紋.岩石)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘(岩石)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('盛餘(石紋)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('385城寶石(燁輝)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('方塊磚.小口磚(一般)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('方塊磚.小口磚(盛餘.燁輝)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('交丁型.直丁型(一般)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_types (value,category) VALUES ('交丁型.直丁型(盛餘.燁輝)','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('5溝760型-清板','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('5溝760型-PU','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('5溝760型-PU雙層','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('高三溝750型-清板','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('高三溝750型-PU','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('高三溝750型-PU雙層','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('高三溝750型-PU雙層3.5公分','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('高三溝750型-PU雙層5公分','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('琉璃瓦-清板','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('琉璃瓦-PU','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('琉璃瓦-PU雙層','烤漆板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('310型扣合式-清板','特殊斷面') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('425B型咬合式-清板','特殊斷面') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('430型2H扣合式-清板','特殊斷面') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('430型3H扣合式-清板','特殊斷面') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('730B型咬合式-清板','特殊斷面') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('1000型螺栓式-清板','特殊斷面') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('4溝770型-清板','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('4溝770型-金龍板OPP','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('5溝760型-PU雙層底白鐵','白鐵板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('350裝潢板-PU鋁箔','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('350裝潢板-PU烤板','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('153型企口板-清板','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('240型小圓浪-清板','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('265型企口板-清板','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('307型貨櫃浪-清板','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('320型三平面-清板','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('680型貨櫃浪-清板','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('770型磁鋼板-清板','裝潢板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('350型壓花壁板-PU鋁箔','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('350型壓花壁板-PU錏板','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('350型壓花壁板-PU烤板','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('360型壓花壁板-PU鋁箔','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('360型壓花壁板-PU錏板','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('360型壓花壁板-PU烤板','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('395型壓花壁板-PU鋁箔','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('395型壓花壁板-PU錏板','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('395型壓花壁板-PU烤板','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('385型壓花壁板-PU鋁箔','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('385型壓花壁板-PU烤板','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('760型磚型壁板-PU','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('760型磚型壁板-清板','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('210型壓花壁板-PU鋁箔','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('210型壓花壁板-PU錏板','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
INSERT INTO pricing_machine_types (value,category) VALUES ('210型壓花壁板-清板','壓花壁板') ON CONFLICT (value) DO UPDATE SET category=EXCLUDED.category;
-- STD 標準價（新 4 份報價單）
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price) VALUES
('STD','副牌(鍍鋁)-0.5','310型扣合式-清板',27.0),
('STD','副牌(鍍鋁)-0.6','310型扣合式-清板',31.0),
('STD','副牌(鍍鋁)-0.6','730B型咬合式-清板',52.0),
('STD','副牌(消光)-0.5','310型扣合式-清板',28.0),
('STD','副牌(消光)-0.6','310型扣合式-清板',32.0),
('STD','副牌(消光)-0.6','730B型咬合式-清板',54.0),
('STD','燁輝(鍍鋅)-0.5','310型扣合式-清板',28.0),
('STD','燁輝(鍍鋅)-0.6','310型扣合式-清板',33.0),
('STD','燁輝(鍍鋅)-0.6','730B型咬合式-清板',55.0),
('STD','燁輝(消光)-0.5','310型扣合式-清板',29.0),
('STD','燁輝(消光)-0.6','310型扣合式-清板',34.0),
('STD','燁輝(消光)-0.6','730B型咬合式-清板',57.0),
('STD','燁輝(鋁鋅)-0.5','310型扣合式-清板',33.0),
('STD','燁輝(鋁鋅)-0.6','310型扣合式-清板',38.0),
('STD','燁輝(鋁鋅)-0.6','730B型咬合式-清板',65.0),
('STD','盛餘(鋁鋅)-0.5','310型扣合式-清板',34.0),
('STD','盛餘(鋁鋅)-0.6','310型扣合式-清板',39.0),
('STD','盛餘(鋁鋅)-0.6','730B型咬合式-清板',68.0),
('STD','盛餘(消光)-0.5','310型扣合式-清板',35.0),
('STD','燁輝(礦纖玄鐵)-0.6','310型扣合式-清板',40.0),
('STD','燁輝(礦纖玄鐵)-0.6','730B型咬合式-清板',70.0),
('STD','木石紋(盛餘)-0.5','310型扣合式-清板',37.0),
('STD','髮絲(盛餘)-0.6','310型扣合式-清板',38.0),
('STD','髮絲(盛餘)-0.6','730B型咬合式-清板',70.0),
('STD','盛餘SMP-0.6','310型扣合式-清板',40.0),
('STD','盛餘SMP-0.6','425B型咬合式-清板',49.0),
('STD','盛餘SMP-0.6','430型2H扣合式-清板',49.0),
('STD','盛餘SMP-0.6','430型3H扣合式-清板',49.0),
('STD','盛餘SMP-0.6','730B型咬合式-清板',69.0),
('STD','盛餘SMP-0.6','1000型螺栓式-清板',92.0),
('STD','盛餘PVDF-0.6','310型扣合式-清板',48.0),
('STD','盛餘PVDF-0.6','425B型咬合式-清板',59.0),
('STD','盛餘PVDF-0.6','430型2H扣合式-清板',59.0),
('STD','盛餘PVDF-0.6','430型3H扣合式-清板',59.0),
('STD','盛餘PVDF-0.6','730B型咬合式-清板',84.0),
('STD','盛餘PVDF-0.6','1000型螺栓式-清板',111.0),
('STD','白鐵(烤漆)-0.4','310型扣合式-清板',57.0),
('STD','白鐵(烤漆)-0.5','310型扣合式-清板',66.0),
('STD','白鐵(烤透明漆)-0.4','4溝770型-清板',92.0),
('STD','白鐵(烤透明漆)-0.4','4溝770型-金龍板OPP',100.0),
('STD','白鐵(烤透明漆)-0.4','5溝760型-PU',108.0),
('STD','白鐵(烤透明漆)-0.4','5溝760型-PU雙層',126.0),
('STD','白鐵(烤透明漆)-0.4','5溝760型-PU雙層底白鐵',178.0),
('STD','白鐵(烤透明漆)-0.4','高三溝750型-清板',93.0),
('STD','白鐵(烤透明漆)-0.4','高三溝750型-PU',109.0),
('STD','白鐵(烤透明漆)-0.4','高三溝750型-PU雙層',127.0),
('STD','白鐵(烤透明漆)-0.4','琉璃瓦-清板',97.0),
('STD','白鐵(烤透明漆)-0.4','琉璃瓦-PU',118.0),
('STD','白鐵(烤透明漆)-0.4','琉璃瓦-PU雙層',134.0),
('STD','白鐵(烤透明漆)-0.5','4溝770型-清板',108.0)
ON CONFLICT ("pricingNo","pricingType","pricingMachineType") DO NOTHING;
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price) VALUES
('STD','白鐵(烤透明漆)-0.5','4溝770型-金龍板OPP',116.0),
('STD','白鐵(烤透明漆)-0.5','5溝760型-PU',124.0),
('STD','白鐵(烤透明漆)-0.5','5溝760型-PU雙層',142.0),
('STD','白鐵(烤透明漆)-0.5','5溝760型-PU雙層底白鐵',194.0),
('STD','白鐵(烤透明漆)-0.5','高三溝750型-清板',109.0),
('STD','白鐵(烤透明漆)-0.5','高三溝750型-PU',125.0),
('STD','白鐵(烤透明漆)-0.5','高三溝750型-PU雙層',143.0),
('STD','白鐵(烤透明漆)-0.5','琉璃瓦-清板',113.0),
('STD','白鐵(烤透明漆)-0.5','琉璃瓦-PU',134.0),
('STD','白鐵(烤透明漆)-0.5','琉璃瓦-PU雙層',150.0),
('STD','白鐵(烤鋁鋅色)-0.4','4溝770型-清板',96.0),
('STD','白鐵(烤鋁鋅色)-0.4','4溝770型-金龍板OPP',104.0),
('STD','白鐵(烤鋁鋅色)-0.4','5溝760型-PU',112.0),
('STD','白鐵(烤鋁鋅色)-0.4','5溝760型-PU雙層',130.0),
('STD','白鐵(烤鋁鋅色)-0.4','5溝760型-PU雙層底白鐵',182.0),
('STD','白鐵(烤鋁鋅色)-0.4','高三溝750型-清板',97.0),
('STD','白鐵(烤鋁鋅色)-0.4','高三溝750型-PU',113.0),
('STD','白鐵(烤鋁鋅色)-0.4','高三溝750型-PU雙層',131.0),
('STD','白鐵(烤鋁鋅色)-0.4','琉璃瓦-清板',101.0),
('STD','白鐵(烤鋁鋅色)-0.4','琉璃瓦-PU',122.0),
('STD','白鐵(烤鋁鋅色)-0.4','琉璃瓦-PU雙層',138.0),
('STD','白鐵(烤鋁鋅色)-0.5','4溝770型-清板',112.0),
('STD','白鐵(烤鋁鋅色)-0.5','4溝770型-金龍板OPP',120.0),
('STD','白鐵(烤鋁鋅色)-0.5','5溝760型-PU',128.0),
('STD','白鐵(烤鋁鋅色)-0.5','5溝760型-PU雙層',146.0),
('STD','白鐵(烤鋁鋅色)-0.5','5溝760型-PU雙層底白鐵',198.0),
('STD','白鐵(烤鋁鋅色)-0.5','高三溝750型-清板',113.0),
('STD','白鐵(烤鋁鋅色)-0.5','高三溝750型-PU',129.0),
('STD','白鐵(烤鋁鋅色)-0.5','高三溝750型-PU雙層',147.0),
('STD','白鐵(烤鋁鋅色)-0.5','琉璃瓦-清板',117.0),
('STD','白鐵(烤鋁鋅色)-0.5','琉璃瓦-PU',138.0),
('STD','白鐵(烤鋁鋅色)-0.5','琉璃瓦-PU雙層',154.0),
('STD','白鐵(烤鋁鋅色)-0.6','4溝770型-清板',142.0),
('STD','白鐵(烤鋁鋅色)-0.6','4溝770型-金龍板OPP',150.0),
('STD','白鐵(烤鋁鋅色)-0.6','5溝760型-PU',158.0),
('STD','白鐵(烤鋁鋅色)-0.6','5溝760型-PU雙層',176.0),
('STD','白鐵(烤鋁鋅色)-0.6','5溝760型-PU雙層底白鐵',228.0),
('STD','白鐵(烤消光色)-0.4','4溝770型-清板',98.0),
('STD','白鐵(烤消光色)-0.4','4溝770型-金龍板OPP',106.0),
('STD','白鐵(烤消光色)-0.4','5溝760型-PU',114.0),
('STD','白鐵(烤消光色)-0.4','5溝760型-PU雙層',132.0),
('STD','白鐵(烤消光色)-0.4','5溝760型-PU雙層底白鐵',184.0),
('STD','白鐵(烤消光色)-0.4','高三溝750型-清板',99.0),
('STD','白鐵(烤消光色)-0.4','高三溝750型-PU',115.0),
('STD','白鐵(烤消光色)-0.4','高三溝750型-PU雙層',133.0),
('STD','白鐵(烤消光色)-0.4','琉璃瓦-清板',103.0),
('STD','白鐵(烤消光色)-0.4','琉璃瓦-PU',124.0),
('STD','白鐵(烤消光色)-0.4','琉璃瓦-PU雙層',140.0),
('STD','白鐵(烤消光色)-0.5','4溝770型-清板',114.0),
('STD','白鐵(烤消光色)-0.5','4溝770型-金龍板OPP',122.0)
ON CONFLICT ("pricingNo","pricingType","pricingMachineType") DO NOTHING;
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price) VALUES
('STD','白鐵(烤消光色)-0.5','5溝760型-PU',130.0),
('STD','白鐵(烤消光色)-0.5','5溝760型-PU雙層',148.0),
('STD','白鐵(烤消光色)-0.5','5溝760型-PU雙層底白鐵',200.0),
('STD','白鐵(烤消光色)-0.5','高三溝750型-清板',115.0),
('STD','白鐵(烤消光色)-0.5','高三溝750型-PU',131.0),
('STD','白鐵(烤消光色)-0.5','高三溝750型-PU雙層',149.0),
('STD','白鐵(烤消光色)-0.5','琉璃瓦-清板',119.0),
('STD','白鐵(烤消光色)-0.5','琉璃瓦-PU',140.0),
('STD','白鐵(烤消光色)-0.5','琉璃瓦-PU雙層',156.0),
('STD','白鐵(烤消光色)-0.6','4溝770型-清板',144.0),
('STD','白鐵(烤消光色)-0.6','4溝770型-金龍板OPP',152.0),
('STD','白鐵(烤消光色)-0.6','5溝760型-PU',160.0),
('STD','白鐵(烤消光色)-0.6','5溝760型-PU雙層',178.0),
('STD','白鐵(烤消光色)-0.6','5溝760型-PU雙層底白鐵',230.0),
('STD','(烤漆)一般-0.5','350裝潢板-PU鋁箔',36.0),
('STD','(烤漆)一般-0.5','350裝潢板-PU烤板',48.0),
('STD','(烤漆)一般-0.5','153型企口板-清板',21.0),
('STD','(烤漆)一般-0.5','240型小圓浪-清板',26.0),
('STD','(烤漆)一般-0.5','265型企口板-清板',26.0),
('STD','(烤漆)一般-0.5','307型貨櫃浪-清板',26.0),
('STD','(烤漆)一般-0.5','320型三平面-清板',26.0),
('STD','(烤漆)一般-0.5','680型貨櫃浪-清板',40.0),
('STD','(烤漆)一般-0.5','770型磁鋼板-清板',40.0),
('STD','(消光)一般-0.5','350裝潢板-PU鋁箔',37.0),
('STD','(消光)一般-0.5','350裝潢板-PU烤板',49.0),
('STD','(消光)一般-0.5','153型企口板-清板',22.0),
('STD','(消光)一般-0.5','240型小圓浪-清板',27.0),
('STD','(消光)一般-0.5','265型企口板-清板',27.0),
('STD','(消光)一般-0.5','307型貨櫃浪-清板',27.0),
('STD','(消光)一般-0.5','320型三平面-清板',27.0),
('STD','(消光)一般-0.5','680型貨櫃浪-清板',42.0),
('STD','(消光)一般-0.5','770型磁鋼板-清板',42.0),
('STD','燁輝(鍍鋅)-0.5','350裝潢板-PU鋁箔',37.0),
('STD','燁輝(鍍鋅)-0.5','350裝潢板-PU烤板',49.0),
('STD','燁輝(鍍鋅)-0.5','153型企口板-清板',22.0),
('STD','燁輝(鍍鋅)-0.5','240型小圓浪-清板',27.0),
('STD','燁輝(鍍鋅)-0.5','265型企口板-清板',27.0),
('STD','燁輝(鍍鋅)-0.5','307型貨櫃浪-清板',27.0),
('STD','燁輝(鍍鋅)-0.5','320型三平面-清板',27.0),
('STD','燁輝(鍍鋅)-0.5','680型貨櫃浪-清板',42.0),
('STD','燁輝(鍍鋅)-0.5','770型磁鋼板-清板',42.0),
('STD','燁輝(消光)-0.5','350裝潢板-PU鋁箔',38.0),
('STD','燁輝(消光)-0.5','350裝潢板-PU烤板',50.0),
('STD','燁輝(消光)-0.5','153型企口板-清板',23.0),
('STD','燁輝(消光)-0.5','240型小圓浪-清板',28.0),
('STD','燁輝(消光)-0.5','265型企口板-清板',28.0),
('STD','燁輝(消光)-0.5','307型貨櫃浪-清板',28.0),
('STD','燁輝(消光)-0.5','320型三平面-清板',28.0),
('STD','燁輝(消光)-0.5','680型貨櫃浪-清板',44.0),
('STD','燁輝(消光)-0.5','770型磁鋼板-清板',44.0)
ON CONFLICT ("pricingNo","pricingType","pricingMachineType") DO NOTHING;
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price) VALUES
('STD','燁輝(鋁鋅)-0.5','350裝潢板-PU鋁箔',42.0),
('STD','燁輝(鋁鋅)-0.5','350裝潢板-PU烤板',54.0),
('STD','燁輝(鋁鋅)-0.5','153型企口板-清板',25.0),
('STD','燁輝(鋁鋅)-0.5','240型小圓浪-清板',32.0),
('STD','燁輝(鋁鋅)-0.5','265型企口板-清板',32.0),
('STD','燁輝(鋁鋅)-0.5','307型貨櫃浪-清板',32.0),
('STD','燁輝(鋁鋅)-0.5','320型三平面-清板',32.0),
('STD','燁輝(鋁鋅)-0.5','680型貨櫃浪-清板',52.0),
('STD','燁輝(鋁鋅)-0.5','770型磁鋼板-清板',52.0),
('STD','盛餘(鋁鋅)-0.5','350裝潢板-PU鋁箔',43.0),
('STD','盛餘(鋁鋅)-0.5','350裝潢板-PU烤板',55.0),
('STD','盛餘(鋁鋅)-0.5','153型企口板-清板',26.0),
('STD','盛餘(鋁鋅)-0.5','240型小圓浪-清板',33.0),
('STD','盛餘(鋁鋅)-0.5','265型企口板-清板',33.0),
('STD','盛餘(鋁鋅)-0.5','307型貨櫃浪-清板',33.0),
('STD','盛餘(鋁鋅)-0.5','320型三平面-清板',33.0),
('STD','盛餘(鋁鋅)-0.5','680型貨櫃浪-清板',55.0),
('STD','盛餘(鋁鋅)-0.5','770型磁鋼板-清板',55.0),
('STD','盛餘消光/燁輝玄鐵-0.5','350裝潢板-PU鋁箔',44.0),
('STD','盛餘消光/燁輝玄鐵-0.5','350裝潢板-PU烤板',56.0),
('STD','盛餘消光/燁輝玄鐵-0.5','153型企口板-清板',27.0),
('STD','盛餘消光/燁輝玄鐵-0.5','240型小圓浪-清板',34.0),
('STD','盛餘消光/燁輝玄鐵-0.5','265型企口板-清板',34.0),
('STD','盛餘消光/燁輝玄鐵-0.5','307型貨櫃浪-清板',34.0),
('STD','盛餘消光/燁輝玄鐵-0.5','320型三平面-清板',34.0),
('STD','盛餘消光/燁輝玄鐵-0.5','680型貨櫃浪-清板',57.0),
('STD','盛餘消光/燁輝玄鐵-0.5','770型磁鋼板-清板',57.0),
('STD','燁輝(礦纖)-0.5','350裝潢板-PU鋁箔',44.0),
('STD','燁輝(礦纖)-0.5','350裝潢板-PU烤板',56.0),
('STD','燁輝(礦纖)-0.5','153型企口板-清板',27.0),
('STD','燁輝(礦纖)-0.5','240型小圓浪-清板',34.0),
('STD','燁輝(礦纖)-0.5','265型企口板-清板',34.0),
('STD','燁輝(礦纖)-0.5','307型貨櫃浪-清板',34.0),
('STD','燁輝(礦纖)-0.5','320型三平面-清板',34.0),
('STD','燁輝(礦纖)-0.5','680型貨櫃浪-清板',57.0),
('STD','燁輝(礦纖)-0.5','770型磁鋼板-清板',57.0),
('STD','木石紋(盛餘)-0.5','350裝潢板-PU鋁箔',45.0),
('STD','木石紋(盛餘)-0.5','350裝潢板-PU烤板',57.0),
('STD','木石紋(盛餘)-0.5','153型企口板-清板',29.0),
('STD','木石紋(盛餘)-0.5','240型小圓浪-清板',36.0),
('STD','木石紋(盛餘)-0.5','265型企口板-清板',36.0),
('STD','木石紋(盛餘)-0.5','307型貨櫃浪-清板',36.0),
('STD','木石紋(盛餘)-0.5','320型三平面-清板',36.0),
('STD','木石紋(盛餘)-0.5','680型貨櫃浪-清板',64.0),
('STD','木石紋(盛餘)-0.5','770型磁鋼板-清板',64.0),
('STD','髮絲(盛餘)-0.6','350裝潢板-PU鋁箔',46.0),
('STD','髮絲(盛餘)-0.6','350裝潢板-PU烤板',58.0),
('STD','髮絲(盛餘)-0.6','153型企口板-清板',30.0),
('STD','髮絲(盛餘)-0.6','240型小圓浪-清板',37.0),
('STD','髮絲(盛餘)-0.6','265型企口板-清板',37.0)
ON CONFLICT ("pricingNo","pricingType","pricingMachineType") DO NOTHING;
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price) VALUES
('STD','髮絲(盛餘)-0.6','307型貨櫃浪-清板',37.0),
('STD','髮絲(盛餘)-0.6','320型三平面-清板',37.0),
('STD','髮絲(盛餘)-0.6','680型貨櫃浪-清板',66.0),
('STD','髮絲(盛餘)-0.6','770型磁鋼板-清板',66.0),
('STD','盛餘SMP-0.6','350裝潢板-PU鋁箔',49.0),
('STD','盛餘SMP-0.6','350裝潢板-PU烤板',61.0),
('STD','盛餘SMP-0.6','153型企口板-清板',30.0),
('STD','盛餘SMP-0.6','240型小圓浪-清板',39.0),
('STD','盛餘SMP-0.6','265型企口板-清板',39.0),
('STD','盛餘SMP-0.6','307型貨櫃浪-清板',39.0),
('STD','盛餘SMP-0.6','320型三平面-清板',39.0),
('STD','盛餘SMP-0.6','680型貨櫃浪-清板',65.0),
('STD','盛餘SMP-0.6','770型磁鋼板-清板',65.0),
('STD','盛餘PVDF-0.6','350裝潢板-PU鋁箔',57.0),
('STD','盛餘PVDF-0.6','350裝潢板-PU烤板',69.0),
('STD','盛餘PVDF-0.6','153型企口板-清板',35.0),
('STD','盛餘PVDF-0.6','240型小圓浪-清板',47.0),
('STD','盛餘PVDF-0.6','265型企口板-清板',47.0),
('STD','盛餘PVDF-0.6','307型貨櫃浪-清板',47.0),
('STD','盛餘PVDF-0.6','320型三平面-清板',47.0),
('STD','盛餘PVDF-0.6','680型貨櫃浪-清板',80.0),
('STD','盛餘PVDF-0.6','770型磁鋼板-清板',80.0),
('STD','燁輝單面樹脂/牙/果-0.5','350裝潢板-PU鋁箔',54.0),
('STD','燁輝單面樹脂/牙/果-0.5','350裝潢板-PU烤板',66.0),
('STD','燁輝單面樹脂/牙/果-0.5','153型企口板-清板',33.0),
('STD','燁輝單面樹脂/牙/果-0.5','240型小圓浪-清板',44.0),
('STD','燁輝單面樹脂/牙/果-0.5','265型企口板-清板',44.0),
('STD','燁輝單面樹脂/牙/果-0.5','307型貨櫃浪-清板',44.0),
('STD','燁輝單面樹脂/牙/果-0.5','320型三平面-清板',44.0),
('STD','燁輝單面樹脂/牙/果-0.5','680型貨櫃浪-清板',82.0),
('STD','燁輝單面樹脂/牙/果-0.5','770型磁鋼板-清板',82.0),
('STD','白鐵(烤漆)-0.4','350裝潢板-PU鋁箔',66.0),
('STD','白鐵(烤漆)-0.4','350裝潢板-PU烤板',78.0),
('STD','白鐵(烤漆)-0.4','153型企口板-清板',42.0),
('STD','白鐵(烤漆)-0.4','240型小圓浪-清板',56.0),
('STD','白鐵(烤漆)-0.4','265型企口板-清板',56.0),
('STD','白鐵(烤漆)-0.4','307型貨櫃浪-清板',56.0),
('STD','白鐵(烤漆)-0.4','320型三平面-清板',56.0),
('STD','白鐵(烤漆)-0.5','350裝潢板-PU鋁箔',75.0),
('STD','白鐵(烤漆)-0.5','350裝潢板-PU烤板',87.0),
('STD','白鐵(烤漆)-0.5','153型企口板-清板',48.0),
('STD','白鐵(烤漆)-0.5','240型小圓浪-清板',65.0),
('STD','白鐵(烤漆)-0.5','265型企口板-清板',65.0),
('STD','白鐵(烤漆)-0.5','307型貨櫃浪-清板',65.0),
('STD','白鐵(烤漆)-0.5','320型三平面-清板',65.0),
('STD','一般色(烤漆)','350型壓花壁板-PU鋁箔',41.0),
('STD','一般色(烤漆)','350型壓花壁板-PU錏板',51.0),
('STD','一般色(烤漆)','350型壓花壁板-PU烤板',53.0),
('STD','特殊色(消光)','350型壓花壁板-PU鋁箔',42.0),
('STD','特殊色(消光)','350型壓花壁板-PU錏板',52.0)
ON CONFLICT ("pricingNo","pricingType","pricingMachineType") DO NOTHING;
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price) VALUES
('STD','特殊色(消光)','350型壓花壁板-PU烤板',54.0),
('STD','盛餘(鋁鋅)','350型壓花壁板-PU鋁箔',48.0),
('STD','盛餘(鋁鋅)','350型壓花壁板-PU錏板',58.0),
('STD','盛餘(鋁鋅)','350型壓花壁板-PU烤板',60.0),
('STD','盛餘(消光)','350型壓花壁板-PU鋁箔',49.0),
('STD','盛餘(消光)','350型壓花壁板-PU錏板',59.0),
('STD','盛餘(消光)','350型壓花壁板-PU烤板',61.0),
('STD','燁輝(礦纖)','350型壓花壁板-PU鋁箔',49.0),
('STD','燁輝(礦纖)','350型壓花壁板-PU錏板',59.0),
('STD','燁輝(礦纖)','350型壓花壁板-PU烤板',61.0),
('STD','木紋.石紋','350型壓花壁板-PU鋁箔',51.0),
('STD','木紋.石紋','350型壓花壁板-PU錏板',61.0),
('STD','木紋.石紋','350型壓花壁板-PU烤板',63.0),
('STD','燁輝(樹脂)牙.果','350型壓花壁板-PU鋁箔',59.0),
('STD','燁輝(樹脂)牙.果','350型壓花壁板-PU錏板',59.0),
('STD','燁輝(樹脂)牙.果','350型壓花壁板-PU烤板',71.0),
('STD','盛餘(烤漆.消光)','360型壓花壁板-PU鋁箔',53.0),
('STD','盛餘(烤漆.消光)','360型壓花壁板-PU錏板',68.0),
('STD','盛餘(烤漆.消光)','360型壓花壁板-PU烤板',70.0),
('STD','盛餘(木紋.岩石)','360型壓花壁板-PU鋁箔',57.0),
('STD','盛餘(木紋.岩石)','360型壓花壁板-PU錏板',72.0),
('STD','盛餘(木紋.岩石)','360型壓花壁板-PU烤板',74.0),
('STD','盛餘(烤漆.消光)','395型壓花壁板-PU鋁箔',56.0),
('STD','盛餘(烤漆.消光)','395型壓花壁板-PU錏板',73.0),
('STD','盛餘(烤漆.消光)','395型壓花壁板-PU烤板',75.0),
('STD','盛餘(岩石)','395型壓花壁板-PU鋁箔',60.0),
('STD','盛餘(岩石)','395型壓花壁板-PU錏板',77.0),
('STD','盛餘(岩石)','395型壓花壁板-PU烤板',79.0),
('STD','盛餘(消光)','385型壓花壁板-PU鋁箔',52.0),
('STD','盛餘(消光)','385型壓花壁板-PU烤板',65.0),
('STD','盛餘(石紋)','385型壓花壁板-PU鋁箔',56.0),
('STD','盛餘(石紋)','385型壓花壁板-PU烤板',69.0),
('STD','燁輝(礦纖)','385型壓花壁板-PU鋁箔',54.0),
('STD','燁輝(礦纖)','385型壓花壁板-PU烤板',67.0),
('STD','385城寶石(燁輝)','385型壓花壁板-PU鋁箔',52.0),
('STD','385城寶石(燁輝)','385型壓花壁板-PU烤板',65.0),
('STD','方塊磚.小口磚(一般)','760型磚型壁板-PU',80.0),
('STD','方塊磚.小口磚(一般)','760型磚型壁板-清板',63.0),
('STD','方塊磚.小口磚(盛餘.燁輝)','760型磚型壁板-PU',91.0),
('STD','方塊磚.小口磚(盛餘.燁輝)','760型磚型壁板-清板',74.0),
('STD','交丁型.直丁型(一般)','760型磚型壁板-PU',83.0),
('STD','交丁型.直丁型(一般)','760型磚型壁板-清板',66.0),
('STD','交丁型.直丁型(盛餘.燁輝)','760型磚型壁板-PU',94.0),
('STD','交丁型.直丁型(盛餘.燁輝)','760型磚型壁板-清板',77.0),
('STD','盛餘(烤漆.消光)','210型壓花壁板-PU鋁箔',38.0),
('STD','盛餘(烤漆.消光)','210型壓花壁板-PU錏板',49.0),
('STD','盛餘(烤漆.消光)','210型壓花壁板-清板',34.0),
('STD','盛餘(木紋.岩石)','210型壓花壁板-PU鋁箔',42.0),
('STD','盛餘(木紋.岩石)','210型壓花壁板-PU錏板',53.0),
('STD','盛餘(木紋.岩石)','210型壓花壁板-清板',38.0)
ON CONFLICT ("pricingNo","pricingType","pricingMachineType") DO NOTHING;
-- 配件/加價（pricing_extras）
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','烤漆板','加價','OPP金龍板','尺',8,'',1 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='烤漆板' AND name='OPP金龍板');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','烤漆板','加價','彎弓(5H-750)','尺',4,'',2 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='烤漆板' AND name='彎弓(5H-750)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','固定座','固定座-425B型咬合式','個',33.0,'1m2約2.8個',1 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='固定座-425B型咬合式');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','固定座','固定座-430型2H扣合式','個',11.0,'1m2約2.8個',2 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='固定座-430型2H扣合式');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','固定座','固定座-430型3H扣合式','個',14.0,'1m2約2.8個',3 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='固定座-430型3H扣合式');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','固定座','固定座-730B型咬合式','個',35.0,'1m2約1.7個',4 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='固定座-730B型咬合式');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','止水條(2條/組)','止水條(2條/組)-310型','組',18.0,'',5 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='止水條(2條/組)-310型');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','止水條(2條/組)','止水條(2條/組)-425B型','組',31.0,'',6 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='止水條(2條/組)-425B型');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','止水條(2條/組)','止水條(2條/組)-430型2H','組',28.0,'',7 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='止水條(2條/組)-430型2H');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','止水條(2條/組)','止水條(2條/組)-430型3H','組',24.0,'',8 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='止水條(2條/組)-430型3H');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','止水條(2條/組)','止水條(2條/組)-730B型','組',35.0,'',9 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='止水條(2條/組)-730B型');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','出租電動咬合器','出租電動咬合器-425B型','天',300.0,'',10 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='出租電動咬合器-425B型');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','出租電動咬合器','出租電動咬合器-730B型','天',600.0,'',11 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='出租電動咬合器-730B型');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','出租手動夾具','出租手動夾具-425B型','天',200.0,'',12 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='出租手動夾具-425B型');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','出租手動夾具','出租手動夾具-730B型','天',400.0,'',13 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='出租手動夾具-730B型');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','彎曲','彎曲-310型','尺',6.0,'',14 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='彎曲-310型');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','彎曲','彎曲-425B型','尺',6.0,'',15 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='彎曲-425B型');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','特殊斷面','彎曲','彎曲-430型2H','尺',6.0,'',16 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='特殊斷面' AND name='彎曲-430型2H');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','350裝潢板專用鋁料','SL-01 外起底條(牙白/6米)','組',410.0,'',1 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='SL-01 外起底條(牙白/6米)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','350裝潢板專用鋁料','SL-02 工字連接條(牙白/6米)','組',945.0,'面395/底550',2 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='SL-02 工字連接條(牙白/6米)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','350裝潢板專用鋁料','SL-08 小外內角條組合(牙白/6米)','組',1200.0,'面560/底640',3 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='SL-08 小外內角條組合(牙白/6米)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','350裝潢板專用鋁料','SL-09 大外內角條組合(牙白/6米)','組',1490.0,'面850/底640',4 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='SL-09 大外內角條組合(牙白/6米)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','350裝潢板專用鋁料','SL-03 7字收邊組合(大)(牙白/6米)','組',690.0,'面300/底390',5 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='SL-03 7字收邊組合(大)(牙白/6米)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','350裝潢板專用鋁料','SL-07 7字收邊組合(小)(牙白/6米)','組',670.0,'面280/底390',6 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='SL-07 7字收邊組合(小)(牙白/6米)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','350裝潢板專用鋁料','SL-04 7字收邊固定(牙白/6米)','組',465.0,'',7 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='SL-04 7字收邊固定(牙白/6米)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','止水條','153止水條(2條/組)','組',12.0,'',8 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='153止水條(2條/組)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','半圓中脊','半圓中脊0.5(一般料)--尺','支',40.0,'',9 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='半圓中脊0.5(一般料)--尺');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','立體獅頭','個',850.0,'',10 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='立體獅頭');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','止水條','240止水條(2條/組)','組',19.0,'',11 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='240止水條(2條/組)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','半圓中脊','半圓中脊0.5(燁輝盛餘)尺','支',45.0,'',12 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='半圓中脊0.5(燁輝盛餘)尺');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','立體龍鳳頭','個',850.0,'',13 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='立體龍鳳頭');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','止水條','265止水條(2條/組)','組',13.0,'',14 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='265止水條(2條/組)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','半圓中脊','半圓中脊0.4(白鐵烤漆)尺','支',72.0,'',15 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='半圓中脊0.4(白鐵烤漆)尺');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','小牛角(1.5尺)','個',1100.0,'',16 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='小牛角(1.5尺)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','止水條','307止水條(2條/組)','組',18.0,'',17 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='307止水條(2條/組)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','半圓中脊','半圓中脊0.5(白鐵烤漆)尺','支',82.0,'',18 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='半圓中脊0.5(白鐵烤漆)尺');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','大牛角(2.2尺)','個',1200.0,'',19 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='大牛角(2.2尺)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','半圓封口','個',20.0,'',20 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='半圓封口');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','沿口瓦(塑膠)','個',80.0,'',21 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='沿口瓦(塑膠)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','沿口瓦(鐵製)','個',130.0,'',22 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='沿口瓦(鐵製)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','沿口瓦(白鐵烤漆)','個',175.0,'',23 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='沿口瓦(白鐵烤漆)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','大巴瓦','個',430.0,'',24 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='大巴瓦');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','梅花頭(鐵製)','個',350.0,'',25 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='梅花頭(鐵製)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','梅花頭(白鐵烤漆)','個',650.0,'',26 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='梅花頭(白鐵烤漆)');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','獅子頭','個',700.0,'',27 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='獅子頭');
INSERT INTO pricing_extras ("pricingNo",category,grp,name,unit,price,remark,seq) SELECT 'STD','裝潢板','琉璃瓦副件','鳳尾(1.8尺)','個',1300.0,'',28 WHERE NOT EXISTS (SELECT 1 FROM pricing_extras WHERE "pricingNo"='STD' AND category='裝潢板' AND name='鳳尾(1.8尺)');
NOTIFY pgrst, 'reload schema';
