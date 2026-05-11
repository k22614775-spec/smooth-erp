-- ================================================================
--  005_coil_transactions.sql
--  鋼捲異動系統：主表 + 鋼捲細項 + 入庫細項
-- ================================================================

-- 鋼捲異動主檔
CREATE TABLE IF NOT EXISTS coil_transactions (
  id           TEXT PRIMARY KEY,
  date         TEXT    DEFAULT '',
  docType      TEXT    DEFAULT '1.委外加工',
  companyCode  TEXT    DEFAULT '',
  companyName  TEXT    DEFAULT '',
  taxType      TEXT    DEFAULT '1.外加',
  taxRate      NUMERIC DEFAULT 5,
  vendorType   TEXT    DEFAULT '1.廠商',
  remark       TEXT    DEFAULT '',
  processAmount NUMERIC DEFAULT 0,
  status       TEXT    DEFAULT '待處理',
  dispatchId   TEXT    DEFAULT '',
  createdAt    TEXT    DEFAULT '',
  updatedAt    TEXT    DEFAULT ''
);

-- 鋼捲細項（出庫鋼捲）
CREATE TABLE IF NOT EXISTS coil_transaction_coils (
  id              TEXT PRIMARY KEY,
  transactionId   TEXT REFERENCES coil_transactions(id) ON DELETE CASCADE,
  itemNo          TEXT    DEFAULT '',
  dispatchNo      TEXT    DEFAULT '',   -- 派工單號（前置單據）
  salesNo         TEXT    DEFAULT '',
  outWarehouse    TEXT    DEFAULT '',
  inWarehouse     TEXT    DEFAULT '',
  model           TEXT    DEFAULT '',
  spec            TEXT    DEFAULT '',
  batchNo         TEXT    DEFAULT '',
  qty             NUMERIC DEFAULT 1,
  outWeight       NUMERIC DEFAULT 0,
  unit            TEXT    DEFAULT 'KG',
  outLength       NUMERIC DEFAULT 0,
  returnWarehouse TEXT    DEFAULT '',
  stockWeight     NUMERIC DEFAULT 0,
  returnWeight    NUMERIC DEFAULT 0,
  processPrice    NUMERIC DEFAULT 0,
  processAmount   NUMERIC DEFAULT 0,
  returnDate      TEXT    DEFAULT '',
  usedWeight      NUMERIC DEFAULT 0,
  usedLength      NUMERIC DEFAULT 0,
  remainLength    NUMERIC DEFAULT 0,
  closed          INTEGER DEFAULT 0,
  purchaseNo      TEXT    DEFAULT '',
  totalPerKg      NUMERIC DEFAULT 0,
  priceBasis      TEXT    DEFAULT '1.總尺/KG',
  remark          TEXT    DEFAULT '',
  createdAt       TEXT    DEFAULT ''
);

-- 入庫細項（委外加工後回入庫的鋼捲）
CREATE TABLE IF NOT EXISTS coil_transaction_items (
  id              TEXT PRIMARY KEY,
  transactionId   TEXT REFERENCES coil_transactions(id) ON DELETE CASCADE,
  itemNo          TEXT    DEFAULT '',
  orderNo         TEXT    DEFAULT '',
  warehouseCode   TEXT    DEFAULT '',
  model           TEXT    DEFAULT '',
  spec            TEXT    DEFAULT '',
  qty             NUMERIC DEFAULT 1,
  totalKg         NUMERIC DEFAULT 0,
  remark          TEXT    DEFAULT '',
  batchNo         TEXT    DEFAULT '',
  createdAt       TEXT    DEFAULT ''
);

-- ✅ 完成
