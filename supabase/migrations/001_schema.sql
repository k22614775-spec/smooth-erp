-- =============================================================================
--  ERP + MES 整合系統 — Supabase PostgreSQL Schema
--  對應原 Google Apps Script / Google Sheets 版本 v2.0
--  所有欄位名稱維持 camelCase 以便前端 JSON 直接對應
-- =============================================================================

-- 啟用 UUID 擴充（若需要自動產生 uuid）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- 1. 設定類工作表
-- =============================================================================

CREATE TABLE IF NOT EXISTS machines (
  id          TEXT PRIMARY KEY,
  name        TEXT,
  method      TEXT,
  widthStart  TEXT,
  widthEnd    TEXT,
  material    TEXT,
  remark      TEXT
);

CREATE TABLE IF NOT EXISTS settings_materials (
  id    SERIAL PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS settings_factories (
  id    SERIAL PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS settings_colors (
  id    SERIAL PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS settings_coatings (
  id    SERIAL PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS settings_strengths (
  id    SERIAL PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS settings_categories (
  id    SERIAL PRIMARY KEY,
  value TEXT NOT NULL
);

-- =============================================================================
-- 2. 訂單系列
-- =============================================================================

CREATE TABLE IF NOT EXISTS orders (
  id              TEXT PRIMARY KEY,
  date            TEXT,
  customerCode    TEXT,
  customerName    TEXT,
  customerShort   TEXT,
  site            TEXT,
  contactPhone    TEXT,
  fax             TEXT,
  salesNo         TEXT,
  docType         TEXT,
  taxType         TEXT,
  terms           TEXT,
  audited         TEXT,
  auditor         TEXT,
  printCount      INTEGER DEFAULT 0,
  address         TEXT,
  articleText     TEXT,
  remark          TEXT,
  dispatchRemark  TEXT,
  totalAmt        NUMERIC DEFAULT 0,
  tax             NUMERIC DEFAULT 0,
  grandTotal      NUMERIC DEFAULT 0,
  qtySum          NUMERIC DEFAULT 0,
  totalSum        NUMERIC DEFAULT 0,
  profit          NUMERIC DEFAULT 0,
  status          TEXT DEFAULT '待派工',
  weighNo         TEXT,
  dispatchId      TEXT,
  createdAt       TEXT,
  updatedAt       TEXT
);

CREATE TABLE IF NOT EXISTS order_items (
  id                TEXT PRIMARY KEY,
  orderId           TEXT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  itemNo            TEXT,
  machine           TEXT,
  bottomMachine     TEXT,
  model             TEXT,
  spec              TEXT,
  method            TEXT,
  baseMaterialModel TEXT,
  materialNo        TEXT,
  factory           TEXT,
  coating           TEXT,
  strength          TEXT,
  size              TEXT,
  color             TEXT,
  paint             TEXT,
  qty               NUMERIC DEFAULT 0,
  totalFeet         NUMERIC DEFAULT 0,
  totalQty          NUMERIC DEFAULT 0,
  length            NUMERIC DEFAULT 0,
  unit              TEXT,
  price             NUMERIC DEFAULT 0,
  amount            NUMERIC DEFAULT 0,
  standardPrice     NUMERIC DEFAULT 0,
  priceModifier     TEXT,
  priceModifyTime   TEXT,
  costBasis         TEXT,
  formula           TEXT,
  deliveryDate      TEXT,
  category          TEXT
);

CREATE TABLE IF NOT EXISTS cutting_details (
  id              TEXT PRIMARY KEY,
  orderId         TEXT NOT NULL,
  orderItemNo     TEXT,
  zone            TEXT,
  bundle          TEXT,
  feet            NUMERIC DEFAULT 0,
  lengthMm        NUMERIC DEFAULT 0,
  qty             INTEGER DEFAULT 0,
  totalFeet       NUMERIC DEFAULT 0,
  kg              NUMERIC DEFAULT 0,
  topUnfinish     INTEGER DEFAULT 0,
  topDone         INTEGER DEFAULT 0,
  bottomUnfinish  INTEGER DEFAULT 0,
  bottomDone      INTEGER DEFAULT 0,
  mesUnfinish     INTEGER DEFAULT 0,
  remark          TEXT,
  -- 派工延伸欄位
  dispatchId      TEXT,
  dispatchSeq     TEXT,
  processNo       TEXT,
  inboundNo       TEXT,
  packagingMethod TEXT,
  deliveryDate    TEXT,
  inLocation      TEXT,
  inBatchNo       TEXT,
  closed          INTEGER DEFAULT 0,
  unreturnedQty   INTEGER DEFAULT 0,
  unreturnedTotal NUMERIC DEFAULT 0,
  theoreticalLenM NUMERIC DEFAULT 0,
  -- MES 報工延伸欄位
  startTime       TEXT,
  finishTime      TEXT,
  reporter        TEXT,
  reportedAt      TEXT
);

-- =============================================================================
-- 3. 庫存系列
-- =============================================================================

CREATE TABLE IF NOT EXISTS inventory (
  id              SERIAL PRIMARY KEY,
  category        TEXT,   -- 類別
  model           TEXT,   -- 型號
  productName     TEXT,   -- 品名規格
  salesName       TEXT,   -- 銷貨品名
  materialNo      TEXT,   -- 材質編號
  factory         TEXT,   -- 廠別
  size            TEXT,   -- 尺寸
  color           TEXT,   -- 顏色
  colorCode       TEXT,   -- 色碼
  paint           TEXT,   -- 漆種
  frontPaint      TEXT,   -- 正面漆種
  backPaint       TEXT,   -- 背面漆種
  frontPaintThick TEXT,   -- 正面漆膜厚
  backPaintThick  TEXT,   -- 背面漆膜厚
  coating         TEXT,   -- 鍍層
  strength        TEXT,   -- 強度
  packagingMethod TEXT,   -- 包裝方式
  unit            TEXT,   -- 單位
  qty             NUMERIC DEFAULT 0,  -- 數量
  total           NUMERIC DEFAULT 0,  -- 總數
  remark          TEXT    -- 備註
);

CREATE TABLE IF NOT EXISTS warehouse_stock (
  id          SERIAL PRIMARY KEY,
  model       TEXT,         -- 型號
  warehouseNo TEXT,         -- 倉庫編號
  qty         NUMERIC DEFAULT 0,
  total       NUMERIC DEFAULT 0,
  price       NUMERIC DEFAULT 0,
  amount      NUMERIC DEFAULT 0,
  moveDate    TEXT,         -- 異動日期
  remark      TEXT
);

CREATE TABLE IF NOT EXISTS batch_detail (
  id              SERIAL PRIMARY KEY,
  model           TEXT,   -- 型號
  warehouseNo     TEXT,   -- 倉庫編號
  location        TEXT,   -- 儲位
  batchNo         TEXT,   -- 批號
  qty             NUMERIC DEFAULT 0,
  total           NUMERIC DEFAULT 0,
  originalRollNo  TEXT,   -- 原廠捲號
  vendor          TEXT,   -- 供應商
  thickness       NUMERIC DEFAULT 0,  -- 鋼捲厚度
  width           NUMERIC DEFAULT 0,  -- 鋼捲寬度
  density         NUMERIC DEFAULT 0,  -- 鋼捲比重
  lengthM         NUMERIC DEFAULT 0,  -- 長度M
  innerRing       TEXT,   -- 內圈
  coilDirection   TEXT,   -- 鋼捲捲向
  price           NUMERIC DEFAULT 0,  -- 進價
  detailRemark    TEXT    -- 細項備註
);

CREATE TABLE IF NOT EXISTS stock_moves (
  id              TEXT PRIMARY KEY,
  moveDate        TEXT,
  moveType        TEXT,   -- IN / OUT
  refType         TEXT,   -- PURCHASE / PURCHASE_REVERSE / DISPATCH / ...
  refId           TEXT,
  model           TEXT,
  batchNo         TEXT,
  warehouse       TEXT,
  location        TEXT,
  qty             NUMERIC DEFAULT 0,
  total           NUMERIC DEFAULT 0,
  unit            TEXT,
  unitWeight      NUMERIC DEFAULT 0,
  color           TEXT,
  paint           TEXT,
  coating         TEXT,
  strength        TEXT,
  originalRollNo  TEXT,
  operator        TEXT,
  remark          TEXT
);

-- =============================================================================
-- 4. 進貨系列
-- =============================================================================

CREATE TABLE IF NOT EXISTS purchases (
  id              TEXT PRIMARY KEY,
  date            TEXT,
  billingMonth    TEXT,
  vendorCode      TEXT,
  vendorName      TEXT,
  taxType         TEXT,
  taxRate         NUMERIC DEFAULT 0,
  address         TEXT,
  phone           TEXT,
  terms           TEXT,
  payDate         TEXT,
  returnNo        TEXT,
  accountVoucher  TEXT,
  neverTransfer   TEXT,
  invoiceNo       TEXT,
  remark          TEXT,
  totalAmt        NUMERIC DEFAULT 0,
  tax             NUMERIC DEFAULT 0,
  grandTotal      NUMERIC DEFAULT 0,
  totalQty        NUMERIC DEFAULT 0,
  paidAmt         NUMERIC DEFAULT 0,
  unpaidAmt       NUMERIC DEFAULT 0
);

CREATE TABLE IF NOT EXISTS purchase_items (
  id          TEXT PRIMARY KEY,
  purchaseId  TEXT NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
  itemNo      TEXT,
  warehouse   TEXT,
  model       TEXT,
  spec        TEXT,
  qty         NUMERIC DEFAULT 0,
  total       NUMERIC DEFAULT 0,
  price       NUMERIC DEFAULT 0,
  amount      NUMERIC DEFAULT 0
);

CREATE TABLE IF NOT EXISTS purchase_batch (
  id              TEXT PRIMARY KEY,
  purchaseId      TEXT NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
  purchaseItemNo  TEXT,
  location        TEXT,
  batchNo         TEXT,
  qty             NUMERIC DEFAULT 0,
  total           NUMERIC DEFAULT 0,
  originalRollNo  TEXT,
  vendor          TEXT,
  inDate          TEXT,
  thickness       NUMERIC DEFAULT 0,
  width           NUMERIC DEFAULT 0,
  density         NUMERIC DEFAULT 0,
  lengthM         NUMERIC DEFAULT 0,
  innerRing       TEXT,
  coilDirection   TEXT,
  detailRemark    TEXT
);

-- =============================================================================
-- 5. 標籤
-- =============================================================================

CREATE TABLE IF NOT EXISTS labels (
  id          TEXT PRIMARY KEY,
  labelNo     TEXT,
  orderId     TEXT,
  orderItemNo TEXT,
  machine     TEXT,
  customerShort TEXT,
  model       TEXT,
  spec        TEXT,
  qty         NUMERIC DEFAULT 0,
  totalLen    NUMERIC DEFAULT 0,
  totalWeight NUMERIC DEFAULT 0,
  unit        TEXT,
  createTime  TEXT,
  startTime   TEXT,
  endTime     TEXT,
  operator    TEXT,
  status      TEXT,
  remark      TEXT
);

-- =============================================================================
-- 6. 派工系列
-- =============================================================================

CREATE TABLE IF NOT EXISTS dispatch_orders (
  id                    TEXT PRIMARY KEY,
  date                  TEXT,
  docCategory           TEXT,
  docType               TEXT,
  source                TEXT,
  orderId               TEXT,
  partnerCode           TEXT,
  partnerName           TEXT,
  operator              TEXT,
  machine               TEXT,
  phase                 TEXT,
  receiveTime           TEXT,
  finishTime            TEXT,
  workHours             TEXT,
  printCount            INTEGER DEFAULT 0,
  remark                TEXT,
  dispatchRemark        TEXT,
  estimatedPickQty      NUMERIC DEFAULT 0,
  estimatedInQty        NUMERIC DEFAULT 0,
  estimatedRemainQty    NUMERIC DEFAULT 0,
  totalLength           NUMERIC DEFAULT 0,
  diffLength            NUMERIC DEFAULT 0,
  lossRate              NUMERIC DEFAULT 0,
  topTotalLen           NUMERIC DEFAULT 0,
  bottomTotalLen        NUMERIC DEFAULT 0,
  finishedTotalLen      NUMERIC DEFAULT 0,
  status                TEXT DEFAULT 'active',
  createdAt             TEXT,
  updatedAt             TEXT
);

CREATE TABLE IF NOT EXISTS dispatch_coil_moves (
  id                  TEXT PRIMARY KEY,
  dispatchId          TEXT NOT NULL,
  itemNo              TEXT,
  dispatchSeq         TEXT,
  orderItemNo         TEXT,
  processNo           TEXT,
  inboundNo           TEXT,
  model               TEXT,
  outBatchNo          TEXT,
  spec                TEXT,
  qty                 NUMERIC DEFAULT 0,
  total               NUMERIC DEFAULT 0,
  unit                TEXT,
  size                TEXT,
  materialNo          TEXT,
  factory             TEXT,
  categoryUnreturned  TEXT,
  costBasis           TEXT,
  materialPrice       NUMERIC DEFAULT 0,
  cost                NUMERIC DEFAULT 0,
  factoryReturnedQty  NUMERIC DEFAULT 0,
  formula             TEXT,
  unitWeight          NUMERIC DEFAULT 0,
  saleReturn          NUMERIC DEFAULT 0,
  saleReturnDate      TEXT,
  usedTotalM          NUMERIC DEFAULT 0,
  outWarehouse        TEXT,
  outLocation         TEXT,
  inWarehouse         TEXT,
  inLocation          TEXT,
  inBatchNo           TEXT,
  category            TEXT,
  topWeight           NUMERIC DEFAULT 0,
  bottomWeight        NUMERIC DEFAULT 0,
  fullyUsed           TEXT,
  usedPart            TEXT,
  createTime          TEXT,
  weightAdjustReason  TEXT,
  color               TEXT,
  paint               TEXT,
  coating             TEXT,
  strength            TEXT,
  originalRollNo      TEXT,
  furnaceNo           TEXT,
  remark              TEXT,
  coilNo              TEXT,
  loadWeight          NUMERIC DEFAULT 0,
  unloadWeight        NUMERIC DEFAULT 0
);

CREATE TABLE IF NOT EXISTS dispatch_production (
  id                TEXT PRIMARY KEY,
  dispatchId        TEXT NOT NULL,
  dispatchSeq       TEXT,
  orderId           TEXT,
  orderItemNo       TEXT,
  zone              TEXT,
  bundle            TEXT,
  category          TEXT,
  model             TEXT,
  spec              TEXT,
  feet              NUMERIC DEFAULT 0,
  lengthMm          NUMERIC DEFAULT 0,
  qty               NUMERIC DEFAULT 0,
  totalFeet         NUMERIC DEFAULT 0,
  theoreticalLenM   NUMERIC DEFAULT 0,
  kg                NUMERIC DEFAULT 0,
  materialNo        TEXT,
  factory           TEXT,
  size              TEXT,
  color             TEXT,
  paint             TEXT,
  coating           TEXT,
  strength          TEXT,
  customerCode      TEXT,
  siteName          TEXT,
  deliveryDate      TEXT,
  topUnfinish       INTEGER DEFAULT 0,
  topDone           INTEGER DEFAULT 0,
  bottomUnfinish    INTEGER DEFAULT 0,
  bottomDone        INTEGER DEFAULT 0,
  mesUnfinish       INTEGER DEFAULT 0,
  unreturnedQty     INTEGER DEFAULT 0,
  unreturnedTotal   NUMERIC DEFAULT 0,
  startTime         TEXT,
  finishTime        TEXT,
  reporter          TEXT,
  closed            INTEGER DEFAULT 0,
  remark            TEXT,
  inboundNo         TEXT,
  formula           TEXT,
  unitPrice         NUMERIC DEFAULT 0,
  priceBasis        TEXT,
  materialPrice     NUMERIC DEFAULT 0,
  costBasis         TEXT,
  costPrice         NUMERIC DEFAULT 0,
  saleReturn        NUMERIC DEFAULT 0,
  unitWeight        NUMERIC DEFAULT 0,
  inLocation        TEXT,
  inBatchNo         TEXT,
  originalRollNo    TEXT,
  furnaceNo         TEXT,
  processNo         TEXT,
  packagingMethod   TEXT,
  shipMethod        TEXT
);

-- =============================================================================
-- 7. 派工回單系列
-- =============================================================================

CREATE TABLE IF NOT EXISTS dispatch_returns (
  id                  TEXT PRIMARY KEY,
  dispatchId          TEXT NOT NULL,
  date                TEXT,
  docCategory         TEXT DEFAULT '回單',
  orderId             TEXT,
  partnerCode         TEXT,
  partnerName         TEXT,
  operator            TEXT,
  machine             TEXT,
  finishTime          TEXT,
  totalIn             NUMERIC DEFAULT 0,
  totalDeduct         NUMERIC DEFAULT 0,
  remark              TEXT,
  status              TEXT DEFAULT 'closed',
  createdAt           TEXT,
  updatedAt           TEXT,
  purchaseOrderId     TEXT,
  printCount          INTEGER DEFAULT 0,
  processAmount       NUMERIC DEFAULT 0,
  processTotal        NUMERIC DEFAULT 0,
  lossRate            NUMERIC DEFAULT 0,
  dispatchRemark      TEXT,
  remainTotal         NUMERIC DEFAULT 0,
  effectiveWorkHours  TEXT,
  pausedHours         TEXT,
  sessionCount        INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS dispatch_return_items (
  id              TEXT PRIMARY KEY,
  returnId        TEXT NOT NULL,
  dispatchId      TEXT,
  labelId         TEXT,
  labelNo         TEXT,
  orderId         TEXT,
  orderItemNo     TEXT,
  cuttingDetailId TEXT,
  machine         TEXT,
  model           TEXT,
  spec            TEXT,
  qty             NUMERIC DEFAULT 0,
  totalLen        NUMERIC DEFAULT 0,
  totalWeight     NUMERIC DEFAULT 0,
  unit            TEXT,
  cutMethod       TEXT,
  topDone         INTEGER DEFAULT 0,
  bottomDone      INTEGER DEFAULT 0,
  startTime       TEXT,
  endTime         TEXT,
  operator        TEXT,
  remark          TEXT,
  inboundNo       TEXT,
  formula         TEXT,
  materialNo      TEXT,
  factory         TEXT,
  size            TEXT,
  unitPrice       NUMERIC DEFAULT 0,
  priceBasis      TEXT,
  materialPrice   NUMERIC DEFAULT 0,
  costBasis       TEXT,
  costPrice       NUMERIC DEFAULT 0,
  saleReturn      NUMERIC DEFAULT 0,
  deliveryDate    TEXT,
  customerCode    TEXT,
  closed          INTEGER DEFAULT 0,
  unitWeight      NUMERIC DEFAULT 0,
  inLocation      TEXT,
  inBatchNo       TEXT,
  category        TEXT,
  color           TEXT,
  paint           TEXT,
  coating         TEXT,
  strength        TEXT,
  originalRollNo  TEXT,
  furnaceNo       TEXT,
  processNo       TEXT,
  packagingMethod TEXT,
  shipMethod      TEXT
);

CREATE TABLE IF NOT EXISTS dispatch_return_deduct (
  id              TEXT PRIMARY KEY,
  returnId        TEXT NOT NULL,
  dispatchId      TEXT,
  coilMoveId      TEXT,
  model           TEXT,
  batchNo         TEXT,
  warehouse       TEXT,
  location        TEXT,
  qty             NUMERIC DEFAULT 0,
  total           NUMERIC DEFAULT 0,
  unit            TEXT,
  originalRollNo  TEXT,
  createdAt       TEXT,
  spec            TEXT,
  size            TEXT,
  materialNo      TEXT,
  remark          TEXT,
  costBasis       TEXT,
  materialPrice   NUMERIC DEFAULT 0,
  factory         TEXT,
  formula         TEXT,
  unitWeight      NUMERIC DEFAULT 0,
  category        TEXT,
  color           TEXT,
  paint           TEXT,
  coating         TEXT,
  strength        TEXT,
  furnaceNo       TEXT,
  dispatchSeq     TEXT
);

CREATE TABLE IF NOT EXISTS dispatch_return_reporters (
  id          TEXT PRIMARY KEY,
  returnId    TEXT,
  dispatchId  TEXT NOT NULL,
  machine     TEXT,
  itemNo      TEXT,
  reporters   TEXT,
  startTime   TEXT,
  endTime     TEXT,
  workHours   TEXT,
  status      TEXT DEFAULT 'active',  -- active | paused | closed
  remark      TEXT,
  createdAt   TEXT,
  updatedAt   TEXT
);

-- =============================================================================
-- 8. 常用索引
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_order_items_orderId       ON order_items (orderId);
CREATE INDEX IF NOT EXISTS idx_cutting_details_orderId   ON cutting_details (orderId);
CREATE INDEX IF NOT EXISTS idx_cutting_details_dispatch  ON cutting_details (dispatchId);
CREATE INDEX IF NOT EXISTS idx_purchase_items_purchaseId ON purchase_items (purchaseId);
CREATE INDEX IF NOT EXISTS idx_purchase_batch_purchaseId ON purchase_batch (purchaseId);
CREATE INDEX IF NOT EXISTS idx_labels_orderId            ON labels (orderId);
CREATE INDEX IF NOT EXISTS idx_dispatch_coil_moves_did   ON dispatch_coil_moves (dispatchId);
CREATE INDEX IF NOT EXISTS idx_dispatch_production_did   ON dispatch_production (dispatchId);
CREATE INDEX IF NOT EXISTS idx_dispatch_returns_did      ON dispatch_returns (dispatchId);
CREATE INDEX IF NOT EXISTS idx_dispatch_ri_rid           ON dispatch_return_items (returnId);
CREATE INDEX IF NOT EXISTS idx_dispatch_rd_rid           ON dispatch_return_deduct (returnId);
CREATE INDEX IF NOT EXISTS idx_dispatch_rr_did           ON dispatch_return_reporters (dispatchId);
CREATE INDEX IF NOT EXISTS idx_stock_moves_refId         ON stock_moves (refId);
CREATE INDEX IF NOT EXISTS idx_batch_detail_model        ON batch_detail (model);
CREATE INDEX IF NOT EXISTS idx_orders_status             ON orders (status);
CREATE INDEX IF NOT EXISTS idx_dispatch_orders_machine   ON dispatch_orders (machine, status);

-- =============================================================================
-- 9. Row Level Security (RLS) — 依需求開關
--    目前全開放，正式上線前請依角色設定
-- =============================================================================

ALTER TABLE machines                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders                      ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE cutting_details             ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouse_stock             ENABLE ROW LEVEL SECURITY;
ALTER TABLE batch_detail                ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_moves                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_items              ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_batch              ENABLE ROW LEVEL SECURITY;
ALTER TABLE labels                      ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatch_orders             ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatch_coil_moves         ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatch_production         ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatch_returns            ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatch_return_items       ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatch_return_deduct      ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatch_return_reporters   ENABLE ROW LEVEL SECURITY;

-- 開放 anon / service_role 全讀寫（開發階段）
-- 正式上線後請移除 anon 的 policy 並改用 JWT 驗證
CREATE POLICY "anon_all" ON machines                  FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON orders                    FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON order_items               FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON cutting_details           FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON inventory                 FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON warehouse_stock           FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON batch_detail              FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON stock_moves               FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON purchases                 FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON purchase_items            FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON purchase_batch            FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON labels                    FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON dispatch_orders           FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON dispatch_coil_moves       FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON dispatch_production       FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON dispatch_returns          FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON dispatch_return_items     FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON dispatch_return_deduct    FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON dispatch_return_reporters FOR ALL TO anon, service_role USING (true) WITH CHECK (true);
