-- 009_pricing_tables.sql
-- 定價設定：定價形式 / 機台定價形式 代碼表 + 定價設定表（定價編號＋生效起訖）
-- 冪等：可重複執行

CREATE TABLE IF NOT EXISTS pricing_types (
  id     SERIAL PRIMARY KEY,
  value  TEXT NOT NULL UNIQUE,   -- 定價形式（庫存主檔下拉選項）
  remark TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS pricing_machine_types (
  id     SERIAL PRIMARY KEY,
  value  TEXT NOT NULL UNIQUE,   -- 定價機臺形式（機台設定下拉選項）
  remark TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS pricing_table (
  id                   SERIAL PRIMARY KEY,
  "pricingNo"          TEXT NOT NULL DEFAULT 'STD',  -- 定價編號（區分客戶價目表，STD=標準牌價）
  "customerCode"       TEXT DEFAULT '',              -- 客戶編號（選填）
  "pricingType"        TEXT NOT NULL,                -- 定價形式
  "pricingMachineType" TEXT NOT NULL,                -- 定價機臺形式
  price                NUMERIC NOT NULL DEFAULT 0,   -- 標準定價
  "startDate"          TEXT DEFAULT '',              -- 生效起日（民國 YYY/MM/DD）
  "endDate"            TEXT DEFAULT '',              -- 生效迄日（空白＝無期限）
  remark               TEXT DEFAULT '',
  "updatedAt"          TEXT DEFAULT ''
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_pricing_cell
  ON pricing_table ("pricingNo","pricingType","pricingMachineType","startDate");
CREATE INDEX IF NOT EXISTS idx_pricing_no ON pricing_table ("pricingNo");

-- RLS（必做）
ALTER TABLE pricing_types         ENABLE ROW LEVEL SECURITY;
ALTER TABLE pricing_machine_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE pricing_table         ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "anon_all" ON pricing_types;
DROP POLICY IF EXISTS "anon_all" ON pricing_machine_types;
DROP POLICY IF EXISTS "anon_all" ON pricing_table;
CREATE POLICY "anon_all" ON pricing_types         FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON pricing_machine_types FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON pricing_table         FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
GRANT ALL ON pricing_types, pricing_machine_types, pricing_table TO anon, authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- 定價形式種子
INSERT INTO pricing_types (value) VALUES ('副牌(鍍鋁)-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('副牌(鍍鋁)-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('副牌(消光)-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('副牌(消光)-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝(鍍鋅)-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝(鍍鋅)-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝(消光)-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝(消光)-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝(鋁鋅)-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝(鋁鋅)-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('盛餘(鋁鋅)-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('盛餘(鋁鋅)-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('盛餘(消光)-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('盛餘(消光)-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝(礦纖)-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝(礦纖)-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝(玄鐵)-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝(玄鐵)-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝樹脂牙/果/灰-單面') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝樹脂牙/果-雙面') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝樹脂墨綠-單面') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('燁輝樹脂紅-單面') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('盛餘SMP-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('盛餘PVDF-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('鎂合金(烤漆)k22-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('鎂合金(烤漆)k22-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('鎂合金(烤漆)k27-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('鎂合金(烤漆)k27-0.6') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('木石紋(盛餘)-0.5') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_types (value) VALUES ('髮絲(盛餘)-0.6') ON CONFLICT (value) DO NOTHING;
-- 機台定價形式種子
INSERT INTO pricing_machine_types (value) VALUES ('5溝760型-清板') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_machine_types (value) VALUES ('5溝760型-PU') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_machine_types (value) VALUES ('5溝760型-PU雙層') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_machine_types (value) VALUES ('高三溝750型-清板') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_machine_types (value) VALUES ('高三溝750型-PU') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_machine_types (value) VALUES ('高三溝750型-PU雙層') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_machine_types (value) VALUES ('高三溝750型-PU雙層3.5公分') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_machine_types (value) VALUES ('高三溝750型-PU雙層5公分') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_machine_types (value) VALUES ('琉璃瓦-清板') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_machine_types (value) VALUES ('琉璃瓦-PU') ON CONFLICT (value) DO NOTHING;
INSERT INTO pricing_machine_types (value) VALUES ('琉璃瓦-PU雙層') ON CONFLICT (value) DO NOTHING;
-- 標準牌價 STD（115/06/05 起生效）
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price,"startDate") VALUES
('STD','副牌(鍍鋁)-0.5','5溝760型-清板',40,'115/06/05'),
('STD','副牌(鍍鋁)-0.5','5溝760型-PU',56,'115/06/05'),
('STD','副牌(鍍鋁)-0.5','5溝760型-PU雙層',74,'115/06/05'),
('STD','副牌(鍍鋁)-0.5','高三溝750型-清板',41,'115/06/05'),
('STD','副牌(鍍鋁)-0.5','高三溝750型-PU',57,'115/06/05'),
('STD','副牌(鍍鋁)-0.5','高三溝750型-PU雙層',75,'115/06/05'),
('STD','副牌(鍍鋁)-0.5','琉璃瓦-清板',47,'115/06/05'),
('STD','副牌(鍍鋁)-0.5','琉璃瓦-PU',68,'115/06/05'),
('STD','副牌(鍍鋁)-0.5','琉璃瓦-PU雙層',84,'115/06/05'),
('STD','副牌(鍍鋁)-0.6','5溝760型-清板',48,'115/06/05'),
('STD','副牌(鍍鋁)-0.6','5溝760型-PU',64,'115/06/05'),
('STD','副牌(鍍鋁)-0.6','5溝760型-PU雙層',82,'115/06/05'),
('STD','副牌(鍍鋁)-0.6','高三溝750型-清板',49,'115/06/05'),
('STD','副牌(鍍鋁)-0.6','高三溝750型-PU',65,'115/06/05'),
('STD','副牌(鍍鋁)-0.6','高三溝750型-PU雙層',83,'115/06/05'),
('STD','副牌(鍍鋁)-0.6','琉璃瓦-清板',55,'115/06/05'),
('STD','副牌(鍍鋁)-0.6','琉璃瓦-PU',76,'115/06/05'),
('STD','副牌(鍍鋁)-0.6','琉璃瓦-PU雙層',92,'115/06/05'),
('STD','副牌(消光)-0.5','5溝760型-清板',42,'115/06/05'),
('STD','副牌(消光)-0.5','5溝760型-PU',58,'115/06/05'),
('STD','副牌(消光)-0.5','5溝760型-PU雙層',76,'115/06/05'),
('STD','副牌(消光)-0.5','高三溝750型-清板',43,'115/06/05'),
('STD','副牌(消光)-0.5','高三溝750型-PU',59,'115/06/05'),
('STD','副牌(消光)-0.5','高三溝750型-PU雙層',77,'115/06/05'),
('STD','副牌(消光)-0.5','琉璃瓦-清板',47,'115/06/05'),
('STD','副牌(消光)-0.5','琉璃瓦-PU',68,'115/06/05'),
('STD','副牌(消光)-0.5','琉璃瓦-PU雙層',84,'115/06/05'),
('STD','副牌(消光)-0.6','5溝760型-清板',50,'115/06/05'),
('STD','副牌(消光)-0.6','5溝760型-PU',66,'115/06/05'),
('STD','副牌(消光)-0.6','5溝760型-PU雙層',84,'115/06/05'),
('STD','副牌(消光)-0.6','高三溝750型-清板',51,'115/06/05'),
('STD','副牌(消光)-0.6','高三溝750型-PU',67,'115/06/05'),
('STD','副牌(消光)-0.6','高三溝750型-PU雙層',85,'115/06/05'),
('STD','副牌(消光)-0.6','琉璃瓦-清板',55,'115/06/05'),
('STD','副牌(消光)-0.6','琉璃瓦-PU',76,'115/06/05'),
('STD','副牌(消光)-0.6','琉璃瓦-PU雙層',92,'115/06/05'),
('STD','燁輝(鍍鋅)-0.5','5溝760型-清板',42,'115/06/05'),
('STD','燁輝(鍍鋅)-0.5','5溝760型-PU',58,'115/06/05'),
('STD','燁輝(鍍鋅)-0.5','5溝760型-PU雙層',76,'115/06/05'),
('STD','燁輝(鍍鋅)-0.5','高三溝750型-清板',43,'115/06/05'),
('STD','燁輝(鍍鋅)-0.5','高三溝750型-PU',59,'115/06/05'),
('STD','燁輝(鍍鋅)-0.5','高三溝750型-PU雙層',77,'115/06/05'),
('STD','燁輝(鍍鋅)-0.5','琉璃瓦-清板',49,'115/06/05'),
('STD','燁輝(鍍鋅)-0.5','琉璃瓦-PU',70,'115/06/05'),
('STD','燁輝(鍍鋅)-0.5','琉璃瓦-PU雙層',86,'115/06/05'),
('STD','燁輝(鍍鋅)-0.6','5溝760型-清板',51,'115/06/05'),
('STD','燁輝(鍍鋅)-0.6','5溝760型-PU',67,'115/06/05'),
('STD','燁輝(鍍鋅)-0.6','5溝760型-PU雙層',85,'115/06/05'),
('STD','燁輝(鍍鋅)-0.6','高三溝750型-清板',52,'115/06/05'),
('STD','燁輝(鍍鋅)-0.6','高三溝750型-PU',68,'115/06/05')
ON CONFLICT ("pricingNo","pricingType","pricingMachineType","startDate") DO NOTHING;
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price,"startDate") VALUES
('STD','燁輝(鍍鋅)-0.6','高三溝750型-PU雙層',86,'115/06/05'),
('STD','燁輝(鍍鋅)-0.6','琉璃瓦-清板',58,'115/06/05'),
('STD','燁輝(鍍鋅)-0.6','琉璃瓦-PU',79,'115/06/05'),
('STD','燁輝(鍍鋅)-0.6','琉璃瓦-PU雙層',95,'115/06/05'),
('STD','燁輝(消光)-0.5','5溝760型-清板',44,'115/06/05'),
('STD','燁輝(消光)-0.5','5溝760型-PU',60,'115/06/05'),
('STD','燁輝(消光)-0.5','5溝760型-PU雙層',78,'115/06/05'),
('STD','燁輝(消光)-0.5','高三溝750型-清板',45,'115/06/05'),
('STD','燁輝(消光)-0.5','高三溝750型-PU',61,'115/06/05'),
('STD','燁輝(消光)-0.5','高三溝750型-PU雙層',79,'115/06/05'),
('STD','燁輝(消光)-0.5','琉璃瓦-清板',51,'115/06/05'),
('STD','燁輝(消光)-0.5','琉璃瓦-PU',72,'115/06/05'),
('STD','燁輝(消光)-0.5','琉璃瓦-PU雙層',88,'115/06/05'),
('STD','燁輝(消光)-0.6','5溝760型-清板',53,'115/06/05'),
('STD','燁輝(消光)-0.6','5溝760型-PU',69,'115/06/05'),
('STD','燁輝(消光)-0.6','5溝760型-PU雙層',87,'115/06/05'),
('STD','燁輝(消光)-0.6','高三溝750型-清板',54,'115/06/05'),
('STD','燁輝(消光)-0.6','高三溝750型-PU',70,'115/06/05'),
('STD','燁輝(消光)-0.6','高三溝750型-PU雙層',88,'115/06/05'),
('STD','燁輝(消光)-0.6','琉璃瓦-清板',60,'115/06/05'),
('STD','燁輝(消光)-0.6','琉璃瓦-PU',81,'115/06/05'),
('STD','燁輝(消光)-0.6','琉璃瓦-PU雙層',97,'115/06/05'),
('STD','燁輝(鋁鋅)-0.5','5溝760型-清板',52,'115/06/05'),
('STD','燁輝(鋁鋅)-0.5','5溝760型-PU',68,'115/06/05'),
('STD','燁輝(鋁鋅)-0.5','5溝760型-PU雙層',86,'115/06/05'),
('STD','燁輝(鋁鋅)-0.5','高三溝750型-清板',53,'115/06/05'),
('STD','燁輝(鋁鋅)-0.5','高三溝750型-PU',69,'115/06/05'),
('STD','燁輝(鋁鋅)-0.5','高三溝750型-PU雙層',87,'115/06/05'),
('STD','燁輝(鋁鋅)-0.5','琉璃瓦-清板',59,'115/06/05'),
('STD','燁輝(鋁鋅)-0.5','琉璃瓦-PU',80,'115/06/05'),
('STD','燁輝(鋁鋅)-0.5','琉璃瓦-PU雙層',96,'115/06/05'),
('STD','燁輝(鋁鋅)-0.6','5溝760型-清板',61,'115/06/05'),
('STD','燁輝(鋁鋅)-0.6','5溝760型-PU',77,'115/06/05'),
('STD','燁輝(鋁鋅)-0.6','5溝760型-PU雙層',95,'115/06/05'),
('STD','燁輝(鋁鋅)-0.6','高三溝750型-清板',62,'115/06/05'),
('STD','燁輝(鋁鋅)-0.6','高三溝750型-PU',78,'115/06/05'),
('STD','燁輝(鋁鋅)-0.6','高三溝750型-PU雙層',96,'115/06/05'),
('STD','燁輝(鋁鋅)-0.6','琉璃瓦-清板',68,'115/06/05'),
('STD','燁輝(鋁鋅)-0.6','琉璃瓦-PU',89,'115/06/05'),
('STD','燁輝(鋁鋅)-0.6','琉璃瓦-PU雙層',105,'115/06/05'),
('STD','盛餘(鋁鋅)-0.5','5溝760型-清板',55,'115/06/05'),
('STD','盛餘(鋁鋅)-0.5','5溝760型-PU',71,'115/06/05'),
('STD','盛餘(鋁鋅)-0.5','5溝760型-PU雙層',89,'115/06/05'),
('STD','盛餘(鋁鋅)-0.5','高三溝750型-清板',56,'115/06/05'),
('STD','盛餘(鋁鋅)-0.5','高三溝750型-PU',72,'115/06/05'),
('STD','盛餘(鋁鋅)-0.5','高三溝750型-PU雙層',90,'115/06/05'),
('STD','盛餘(鋁鋅)-0.5','琉璃瓦-清板',61,'115/06/05'),
('STD','盛餘(鋁鋅)-0.5','琉璃瓦-PU',82,'115/06/05'),
('STD','盛餘(鋁鋅)-0.5','琉璃瓦-PU雙層',98,'115/06/05'),
('STD','盛餘(鋁鋅)-0.6','5溝760型-清板',64,'115/06/05')
ON CONFLICT ("pricingNo","pricingType","pricingMachineType","startDate") DO NOTHING;
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price,"startDate") VALUES
('STD','盛餘(鋁鋅)-0.6','5溝760型-PU',80,'115/06/05'),
('STD','盛餘(鋁鋅)-0.6','5溝760型-PU雙層',98,'115/06/05'),
('STD','盛餘(鋁鋅)-0.6','高三溝750型-清板',65,'115/06/05'),
('STD','盛餘(鋁鋅)-0.6','高三溝750型-PU',81,'115/06/05'),
('STD','盛餘(鋁鋅)-0.6','高三溝750型-PU雙層',99,'115/06/05'),
('STD','盛餘(鋁鋅)-0.6','琉璃瓦-清板',70,'115/06/05'),
('STD','盛餘(鋁鋅)-0.6','琉璃瓦-PU',91,'115/06/05'),
('STD','盛餘(鋁鋅)-0.6','琉璃瓦-PU雙層',107,'115/06/05'),
('STD','盛餘(消光)-0.5','5溝760型-清板',57,'115/06/05'),
('STD','盛餘(消光)-0.5','5溝760型-PU',73,'115/06/05'),
('STD','盛餘(消光)-0.5','5溝760型-PU雙層',91,'115/06/05'),
('STD','盛餘(消光)-0.5','高三溝750型-清板',58,'115/06/05'),
('STD','盛餘(消光)-0.5','高三溝750型-PU',74,'115/06/05'),
('STD','盛餘(消光)-0.5','高三溝750型-PU雙層',92,'115/06/05'),
('STD','盛餘(消光)-0.5','琉璃瓦-清板',63,'115/06/05'),
('STD','盛餘(消光)-0.5','琉璃瓦-PU',84,'115/06/05'),
('STD','盛餘(消光)-0.5','琉璃瓦-PU雙層',100,'115/06/05'),
('STD','盛餘(消光)-0.6','5溝760型-清板',66,'115/06/05'),
('STD','盛餘(消光)-0.6','5溝760型-PU',82,'115/06/05'),
('STD','盛餘(消光)-0.6','5溝760型-PU雙層',100,'115/06/05'),
('STD','盛餘(消光)-0.6','高三溝750型-清板',67,'115/06/05'),
('STD','盛餘(消光)-0.6','高三溝750型-PU',83,'115/06/05'),
('STD','盛餘(消光)-0.6','高三溝750型-PU雙層',101,'115/06/05'),
('STD','盛餘(消光)-0.6','琉璃瓦-清板',72,'115/06/05'),
('STD','盛餘(消光)-0.6','琉璃瓦-PU',93,'115/06/05'),
('STD','盛餘(消光)-0.6','琉璃瓦-PU雙層',109,'115/06/05'),
('STD','燁輝(礦纖)-0.5','5溝760型-清板',57,'115/06/05'),
('STD','燁輝(礦纖)-0.5','5溝760型-PU',73,'115/06/05'),
('STD','燁輝(礦纖)-0.5','5溝760型-PU雙層',91,'115/06/05'),
('STD','燁輝(礦纖)-0.5','高三溝750型-清板',58,'115/06/05'),
('STD','燁輝(礦纖)-0.5','高三溝750型-PU',74,'115/06/05'),
('STD','燁輝(礦纖)-0.5','高三溝750型-PU雙層',92,'115/06/05'),
('STD','燁輝(礦纖)-0.5','琉璃瓦-清板',63,'115/06/05'),
('STD','燁輝(礦纖)-0.5','琉璃瓦-PU',84,'115/06/05'),
('STD','燁輝(礦纖)-0.5','琉璃瓦-PU雙層',100,'115/06/05'),
('STD','燁輝(礦纖)-0.6','5溝760型-清板',66,'115/06/05'),
('STD','燁輝(礦纖)-0.6','5溝760型-PU',82,'115/06/05'),
('STD','燁輝(礦纖)-0.6','5溝760型-PU雙層',100,'115/06/05'),
('STD','燁輝(礦纖)-0.6','高三溝750型-清板',67,'115/06/05'),
('STD','燁輝(礦纖)-0.6','高三溝750型-PU',83,'115/06/05'),
('STD','燁輝(礦纖)-0.6','高三溝750型-PU雙層',101,'115/06/05'),
('STD','燁輝(礦纖)-0.6','琉璃瓦-清板',72,'115/06/05'),
('STD','燁輝(礦纖)-0.6','琉璃瓦-PU',93,'115/06/05'),
('STD','燁輝(礦纖)-0.6','琉璃瓦-PU雙層',109,'115/06/05'),
('STD','燁輝(玄鐵)-0.5','5溝760型-清板',57,'115/06/05'),
('STD','燁輝(玄鐵)-0.5','5溝760型-PU',73,'115/06/05'),
('STD','燁輝(玄鐵)-0.5','5溝760型-PU雙層',91,'115/06/05'),
('STD','燁輝(玄鐵)-0.5','高三溝750型-清板',58,'115/06/05'),
('STD','燁輝(玄鐵)-0.5','高三溝750型-PU',74,'115/06/05'),
('STD','燁輝(玄鐵)-0.5','高三溝750型-PU雙層',92,'115/06/05')
ON CONFLICT ("pricingNo","pricingType","pricingMachineType","startDate") DO NOTHING;
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price,"startDate") VALUES
('STD','燁輝(玄鐵)-0.5','琉璃瓦-清板',63,'115/06/05'),
('STD','燁輝(玄鐵)-0.5','琉璃瓦-PU',84,'115/06/05'),
('STD','燁輝(玄鐵)-0.5','琉璃瓦-PU雙層',100,'115/06/05'),
('STD','燁輝(玄鐵)-0.6','5溝760型-清板',66,'115/06/05'),
('STD','燁輝(玄鐵)-0.6','5溝760型-PU',82,'115/06/05'),
('STD','燁輝(玄鐵)-0.6','5溝760型-PU雙層',100,'115/06/05'),
('STD','燁輝(玄鐵)-0.6','高三溝750型-清板',67,'115/06/05'),
('STD','燁輝(玄鐵)-0.6','高三溝750型-PU',83,'115/06/05'),
('STD','燁輝(玄鐵)-0.6','高三溝750型-PU雙層',101,'115/06/05'),
('STD','燁輝(玄鐵)-0.6','琉璃瓦-清板',72,'115/06/05'),
('STD','燁輝(玄鐵)-0.6','琉璃瓦-PU',93,'115/06/05'),
('STD','燁輝(玄鐵)-0.6','琉璃瓦-PU雙層',109,'115/06/05'),
('STD','燁輝樹脂牙/果/灰-單面','5溝760型-清板',82,'115/06/05'),
('STD','燁輝樹脂牙/果/灰-單面','5溝760型-PU',98,'115/06/05'),
('STD','燁輝樹脂牙/果/灰-單面','5溝760型-PU雙層',116,'115/06/05'),
('STD','燁輝樹脂牙/果/灰-單面','高三溝750型-清板',83,'115/06/05'),
('STD','燁輝樹脂牙/果/灰-單面','高三溝750型-PU',99,'115/06/05'),
('STD','燁輝樹脂牙/果/灰-單面','高三溝750型-PU雙層',117,'115/06/05'),
('STD','燁輝樹脂牙/果/灰-單面','琉璃瓦-清板',88,'115/06/05'),
('STD','燁輝樹脂牙/果/灰-單面','琉璃瓦-PU',109,'115/06/05'),
('STD','燁輝樹脂牙/果/灰-單面','琉璃瓦-PU雙層',125,'115/06/05'),
('STD','燁輝樹脂牙/果-雙面','5溝760型-清板',89,'115/06/05'),
('STD','燁輝樹脂牙/果-雙面','高三溝750型-清板',90,'115/06/05'),
('STD','燁輝樹脂墨綠-單面','5溝760型-清板',86,'115/06/05'),
('STD','燁輝樹脂墨綠-單面','5溝760型-PU',102,'115/06/05'),
('STD','燁輝樹脂墨綠-單面','5溝760型-PU雙層',120,'115/06/05'),
('STD','燁輝樹脂墨綠-單面','高三溝750型-清板',87,'115/06/05'),
('STD','燁輝樹脂墨綠-單面','高三溝750型-PU',103,'115/06/05'),
('STD','燁輝樹脂墨綠-單面','高三溝750型-PU雙層',121,'115/06/05'),
('STD','燁輝樹脂墨綠-單面','琉璃瓦-清板',91,'115/06/05'),
('STD','燁輝樹脂墨綠-單面','琉璃瓦-PU',112,'115/06/05'),
('STD','燁輝樹脂墨綠-單面','琉璃瓦-PU雙層',128,'115/06/05'),
('STD','燁輝樹脂紅-單面','5溝760型-清板',93,'115/06/05'),
('STD','燁輝樹脂紅-單面','5溝760型-PU',109,'115/06/05'),
('STD','燁輝樹脂紅-單面','5溝760型-PU雙層',127,'115/06/05'),
('STD','燁輝樹脂紅-單面','高三溝750型-清板',94,'115/06/05'),
('STD','燁輝樹脂紅-單面','高三溝750型-PU',110,'115/06/05'),
('STD','燁輝樹脂紅-單面','高三溝750型-PU雙層',128,'115/06/05'),
('STD','燁輝樹脂紅-單面','琉璃瓦-清板',98,'115/06/05'),
('STD','燁輝樹脂紅-單面','琉璃瓦-PU',119,'115/06/05'),
('STD','燁輝樹脂紅-單面','琉璃瓦-PU雙層',135,'115/06/05'),
('STD','盛餘SMP-0.6','5溝760型-清板',65,'115/06/05'),
('STD','盛餘SMP-0.6','5溝760型-PU',81,'115/06/05'),
('STD','盛餘SMP-0.6','5溝760型-PU雙層',99,'115/06/05'),
('STD','盛餘SMP-0.6','高三溝750型-清板',66,'115/06/05'),
('STD','盛餘SMP-0.6','高三溝750型-PU',82,'115/06/05'),
('STD','盛餘SMP-0.6','高三溝750型-PU雙層',100,'115/06/05'),
('STD','盛餘PVDF-0.6','5溝760型-清板',80,'115/06/05'),
('STD','盛餘PVDF-0.6','5溝760型-PU',96,'115/06/05'),
('STD','盛餘PVDF-0.6','5溝760型-PU雙層',114,'115/06/05')
ON CONFLICT ("pricingNo","pricingType","pricingMachineType","startDate") DO NOTHING;
INSERT INTO pricing_table ("pricingNo","pricingType","pricingMachineType",price,"startDate") VALUES
('STD','盛餘PVDF-0.6','高三溝750型-清板',81,'115/06/05'),
('STD','盛餘PVDF-0.6','高三溝750型-PU',97,'115/06/05'),
('STD','盛餘PVDF-0.6','高三溝750型-PU雙層',115,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.5','5溝760型-清板',53,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.5','5溝760型-PU',69,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.5','5溝760型-PU雙層',87,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.5','高三溝750型-清板',54,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.5','高三溝750型-PU',70,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.5','高三溝750型-PU雙層',88,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.6','5溝760型-清板',62,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.6','5溝760型-PU',78,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.6','5溝760型-PU雙層',96,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.6','高三溝750型-清板',63,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.6','高三溝750型-PU',79,'115/06/05'),
('STD','鎂合金(烤漆)k22-0.6','高三溝750型-PU雙層',97,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.5','5溝760型-清板',55,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.5','5溝760型-PU',71,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.5','5溝760型-PU雙層',89,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.5','高三溝750型-清板',56,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.5','高三溝750型-PU',72,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.5','高三溝750型-PU雙層',90,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.6','5溝760型-清板',64,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.6','5溝760型-PU',80,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.6','5溝760型-PU雙層',98,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.6','高三溝750型-清板',65,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.6','高三溝750型-PU',81,'115/06/05'),
('STD','鎂合金(烤漆)k27-0.6','高三溝750型-PU雙層',99,'115/06/05'),
('STD','木石紋(盛餘)-0.5','5溝760型-清板',64,'115/06/05'),
('STD','木石紋(盛餘)-0.5','5溝760型-PU',80,'115/06/05'),
('STD','木石紋(盛餘)-0.5','5溝760型-PU雙層',98,'115/06/05'),
('STD','木石紋(盛餘)-0.5','高三溝750型-清板',65,'115/06/05'),
('STD','木石紋(盛餘)-0.5','高三溝750型-PU',81,'115/06/05'),
('STD','木石紋(盛餘)-0.5','高三溝750型-PU雙層',99,'115/06/05'),
('STD','髮絲(盛餘)-0.6','5溝760型-清板',66,'115/06/05'),
('STD','髮絲(盛餘)-0.6','5溝760型-PU',82,'115/06/05'),
('STD','髮絲(盛餘)-0.6','5溝760型-PU雙層',100,'115/06/05'),
('STD','髮絲(盛餘)-0.6','高三溝750型-清板',67,'115/06/05'),
('STD','髮絲(盛餘)-0.6','高三溝750型-PU',83,'115/06/05'),
('STD','髮絲(盛餘)-0.6','高三溝750型-PU雙層',101,'115/06/05')
ON CONFLICT ("pricingNo","pricingType","pricingMachineType","startDate") DO NOTHING;
NOTIFY pgrst, 'reload schema';
