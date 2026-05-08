-- ============================================================
--  ERP + MES 種子資料（驗證通過版）
--  欄位名對應 schema 實際小寫欄位，213 欄位 0 錯誤
-- ============================================================

SET session_replication_role = replica;

-- ── 機台設定 → machines (2 筆) ──
INSERT INTO machines (id, name, method, widthstart, widthend, material, remark) VALUES
  ('255', '255成型機', '3.清版', '255', '400', NULL, '預設機台'),
  ('清板', '清板機', '1.一般', '200', '600', NULL, NULL)
ON CONFLICT DO NOTHING;

-- ── 訂單主檔 → orders (4 筆) ──
INSERT INTO orders (id, date, customercode, customername, customershort, site, contactphone, fax, salesno, doctype, taxtype, terms, audited, auditor, printcount, address, articletext, remark, dispatchremark, totalamt, tax, grandtotal, qtysum, totalsum, profit, status, weighno, dispatchid, createdat, updatedat) VALUES
  ('1150501001', '2026-05-01 00:00:00', 'A01', '楊梅工業廠股份有限公司', '楊梅工業', '楊梅A廠房', NULL, NULL, '1717', '1.一般銷貨', '1.應稅(外加)', NULL, NULL, NULL, NULL, NULL, NULL, '楊梅A廠房擴建工程', '請優先派工，2 週內完工', '14218', '711', '14929', '84', '1421.78', NULL, '待派工', NULL, NULL, '2026-04-30T00:35:31.466Z', '2026-05-07T11:56:37.684Z'),
  ('1150501002', '2026-05-03 00:00:00', 'A02', '中壢科技廠房有限公司', '中壢科技', '中壢科技園區', NULL, NULL, '1801', '1.一般銷貨', '1.應稅(外加)', NULL, NULL, NULL, NULL, NULL, NULL, '雙棟對稱型廠房', '兩棟各備一車', '19472', '974', '20445', '100', '1947.19', NULL, '待派工', NULL, NULL, '2026-04-30T00:35:36.026Z', '2026-05-07T11:56:47.675Z'),
  ('1150501003', '2026-05-05 00:00:00', 'A03', '桃園倉儲股份有限公司', '桃園倉儲', '桃園物流園區', NULL, NULL, '1717', '1.一般銷貨', '1.應稅(外加)', NULL, NULL, NULL, NULL, NULL, NULL, '三聯棟倉儲', '天溝先送', '21386', '1069', '22455', '138', '2138.61', NULL, '待派工', NULL, NULL, '2026-04-30T00:35:38.388Z', '2026-05-07T10:47:58.282Z'),
  ('1150501004', '2026-05-07 00:00:00', 'A04', '觀音物流中心有限公司', '觀音物流', '觀音物流中心', NULL, NULL, '1801', '1.一般銷貨', '1.應稅(外加)', NULL, NULL, NULL, NULL, NULL, NULL, '物流中心改建', '主棟與附屬棟分批出貨', '16924', '846', '17770', '114', '1692.41', NULL, '待派工', NULL, NULL, '2026-04-30T00:35:41.489Z', '2026-05-06T15:12:58.438Z')
ON CONFLICT DO NOTHING;

-- ── 訂單細項 → order_items (4 筆) ──
INSERT INTO order_items (id, orderid, itemno, machine, bottommachine, model, spec, method, basematerialmodel, materialno, factory, coating, strength, size, color, paint, qty, totalfeet, totalqty, length, unit, price, amount, standardprice, pricemodifier, pricemodifytime, costbasis, formula, deliverydate, category) VALUES
  ('1150501001-0010', '1150501001', '10', '255', NULL, '255A05AE100', '255K企口板*鍍鋅 0.5*燁輝-米黃', '3. 上板->底板', 'ZBE0.500*0255R001', '鍍鋅', '燁輝', 'AZ100', 'G550', '0.50x 255.0x 0.0', '燁輝米黃', 'PE', '84', '1421.78', '431.23', '5500', '台尺', '10', '14218', NULL, NULL, NULL, '1.總數', NULL, '2026-05-01 00:00:00', '255企口板'),
  ('1150501002-0010', '1150501002', '10', '255', NULL, '255A05AE100', '255K企口板*鍍鋅 0.5*燁輝-米黃', '3. 上板->底板', 'ZBE0.500*0255R001', '鍍鋅', '燁輝', 'AZ100', 'G550', '0.50x 255.0x 0.0', '燁輝米黃', 'PE', '100', '1947.19', '590.59', '6000', '台尺', '10', '19472', NULL, NULL, NULL, '1.總數', NULL, '2026-05-03 00:00:00', '255企口板'),
  ('1150501003-0010', '1150501003', '10', '255', NULL, '255A05AE100', '255K企口板*鍍鋅 0.5*燁輝-米黃', '3. 上板->底板', 'ZBE0.500*0255R001', '鍍鋅', '燁輝', 'AZ100', 'G550', '0.50x 255.0x 0.0', '燁輝米黃', 'PE', '138', '2138.61', '648.65', '4500', '台尺', '10', '21386', NULL, NULL, NULL, '1.總數', NULL, '2026-05-05 00:00:00', '255企口板'),
  ('1150501004-0010', '1150501004', '10', '255', NULL, '255A05AE100', '255K企口板*鍍鋅 0.5*燁輝-米黃', '3. 上板->底板', 'ZBE0.500*0255R001', '鍍鋅', '燁輝', 'AZ100', 'G550', '0.50x 255.0x 0.0', '燁輝米黃', 'PE', '114', '1692.41', '513.31', '5200', '台尺', '10', '16924', NULL, NULL, NULL, '1.總數', NULL, '2026-05-07 00:00:00', '255企口板')
ON CONFLICT DO NOTHING;

-- ── 裁切細項 → cutting_details (23 筆) ──
INSERT INTO cutting_details (id, orderid, orderitemno, zone, bundle, feet, lengthmm, qty, totalfeet, kg, topunfinish, topdone, bottomunfinish, bottomdone, mesunfinish, remark, dispatchid, dispatchseq, processno, inboundno, packagingmethod, deliverydate, inlocation, inbatchno, closed, unreturnedqty, unreturnedtotal, theoreticallenm, starttime, finishtime, reporter, reportedat) VALUES
  ('m-1150501001-10-第一棟-右面-18.15', '1150501001', '10', '第一棟-右面', '0', '18.15', '5500', '30', '544.5', '165.3', '30', '0', '30', '0', '30', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-01 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501001-10-第一棟-左面-18.15', '1150501001', '10', '第一棟-左面', '0', '18.15', '5500', '30', '544.5', '165.3', '30', '0', '30', '0', '30', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-01 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501001-10-第一棟-前牆-13.86', '1150501001', '10', '第一棟-前牆', '0', '13.86', '4200', '12', '166.32', '50.4', '12', '0', '12', '0', '12', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-01 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501001-10-第一棟-後牆-13.86', '1150501001', '10', '第一棟-後牆', '0', '13.86', '4200', '12', '166.32', '50.4', '12', '0', '12', '0', '12', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-01 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501002-10-第一棟-左右-1-19.80', '1150501002', '10', '第一棟-左右-1', '0', '19.8', '6000', '25', '495', '150.25', '25', '0', '25', '0', '25', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-03 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501002-10-第一棟-左右-2-19.14', '1150501002', '10', '第一棟-左右-2', '0', '19.14', '5800', '25', '478.5', '145.25', '25', '0', '25', '0', '25', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-03 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501002-10-第二棟-左右-1-19.80', '1150501002', '10', '第二棟-左右-1', '0', '19.8', '6000', '25', '495', '150.25', '25', '0', '25', '0', '25', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-03 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501002-10-第二棟-左右-2-19.14', '1150501002', '10', '第二棟-左右-2', '0', '19.14', '5800', '25', '478.5', '145.25', '25', '0', '25', '0', '25', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-03 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501003-10-共用-天溝-19.80', '1150501003', '10', '共用-天溝', '0', '19.8', '6000', '18', '356.4', '108.18', '18', '0', '18', '0', '18', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-05 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501003-10-第一棟-屋面-14.85', '1150501003', '10', '第一棟-屋面', '0', '14.85', '4500', '40', '594', '180', '40', '0', '40', '0', '40', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-05 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501003-10-第二棟-屋面-14.85', '1150501003', '10', '第二棟-屋面', '0', '14.85', '4500', '40', '594', '180', '40', '0', '40', '0', '40', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-05 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501003-10-第三棟-屋面-14.85', '1150501003', '10', '第三棟-屋面', '0', '14.85', '4500', '40', '594', '180', '40', '0', '40', '0', '40', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-05 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501004-10-主棟-上層-17.16', '1150501004', '10', '主棟-上層', '0', '17.16', '5200', '35', '600.6', '182.35', '35', '0', '35', '0', '35', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-07 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501004-10-主棟-下層-17.16', '1150501004', '10', '主棟-下層', '0', '17.16', '5200', '35', '600.6', '182.35', '35', '0', '35', '0', '35', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-07 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501004-10-附屬棟-1-11.88', '1150501004', '10', '附屬棟-1', '0', '11.88', '3600', '18', '213.84', '64.8', '18', '0', '18', '0', '18', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-07 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501004-10-附屬棟-2-11.88', '1150501004', '10', '附屬棟-2', '0', '11.88', '3600', '18', '213.84', '64.8', '18', '0', '18', '0', '18', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-07 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501004-10-接續區-1-7.92', '1150501004', '10', '接續區-1', '0', '7.92', '2400', '8', '63.36', '19.2', '8', '0', '8', '0', '8', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-07 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501002-10|19.80', '1150501002', '10', '第一棟-左右-1、第一棟-左右-1、第一棟-左右-1、第一棟-左右-1、第二棟-左右-1、第二棟-左右-1、第二棟-左右-1、第二棟-左右-1', '0', '19.8', NULL, '200', '3960', '1202', '200', '0', '200', '0', '200', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-03 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501002-10|19.14', '1150501002', '10', '第一棟-左右-2、第一棟-左右-2、第一棟-左右-2、第一棟-左右-2、第二棟-左右-2、第二棟-左右-2、第二棟-左右-2、第二棟-左右-2', '0', '19.14', NULL, '200', '3828', '1162', '200', '0', '200', '0', '200', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-03 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501003-10|19.80', '1150501003', '10', '共用-天溝', NULL, '19.8', NULL, '18', '356.4', '108.18', '18', '0', '18', '0', '18', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-05 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501003-10|14.85', '1150501003', '10', '第一棟-屋面、第三棟-屋面、第二棟-屋面', '0', '14.85', NULL, '120', '1782', '540', '120', '0', '120', '0', '120', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-05 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501001-10|18.15', '1150501001', '10', '第一棟-右面、第一棟-右面、第一棟-右面、第一棟-右面、第一棟-右面、第一棟-左面、第一棟-左面、第一棟-左面、第一棟-左面、第一棟-左面', '0', '18.15', NULL, '300', '5445', '1653', '300', '0', '300', '0', '300', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-01 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
  ('m-1150501001-10|13.86', '1150501001', '10', '第一棟-前牆、第一棟-前牆、第一棟-前牆、第一棟-前牆、第一棟-前牆、第一棟-後牆、第一棟-後牆、第一棟-後牆、第一棟-後牆、第一棟-後牆', '0', '13.86', NULL, '120', '1663.2', '504', '120', '0', '120', '0', '120', NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-01 00:00:00', NULL, NULL, '0', NULL, NULL, NULL, NULL, NULL, NULL, NULL)
ON CONFLICT DO NOTHING;

-- ── 庫存主檔 → inventory (1 筆) ──
INSERT INTO inventory (category, model, productname, salesname, materialno, factory, size, color, colorcode, paint, frontpaint, backpaint, frontpaintthick, backpaintthick, coating, strength, packagingmethod, unit, qty, total, remark) VALUES
  ('鍍鋅捲', 'ZBE0.500*0255R001', '鍍鋅鋼捲 0.5*255 AZ100 G550', '鍍鋅鋼捲 0.5*255', '鍍鋅', '燁輝', '0.50x 255.0x 0.0', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'AZ100', 'G550', '捲裝', 'KG', '5', '29750', '255企口板專用原料')
ON CONFLICT DO NOTHING;

-- ── 倉庫存量 → warehouse_stock (1 筆) ──
INSERT INTO warehouse_stock (model, warehouseno, qty, total, price, amount, movedate, remark) VALUES
  ('ZBE0.500*0255R001', '鋼捲倉', '5', '29750', '0', '0', '2026-05-08 21:59:08', '進貨單 1150430002')
ON CONFLICT DO NOTHING;

-- ── 批號明細 → batch_detail (5 筆) ──
INSERT INTO batch_detail (model, warehouseno, location, batchno, qty, total, originalrollno, vendor, thickness, width, density, lengthm, innerring, coildirection, price, detailremark) VALUES
  ('ZBE0.500*0255R001', '鋼捲倉', 'A-01', '1001', '1', '5800', 'YH26-1001', '燁輝', '0.5', '255', '7.85', '2900', '508', '順捲', '32.5', '進貨單 1150430001 / 1001 今日進料'),
  ('ZBE0.500*0255R001', '鋼捲倉', 'A-01', '1002', '1', '6000', 'YH26-1002', '燁輝', '0.5', '255', '7.85', '3000', '508', '順捲', '32.5', '進貨單 1150430001 / 1002 今日進料'),
  ('ZBE0.500*0255R001', '鋼捲倉', 'A-01', '1003', '1', '5900', 'YH26-1003', '燁輝', '0.5', '255', '7.85', '2950', '508', '順捲', '32.5', '進貨單 1150430002 / 1003 今日進料'),
  ('ZBE0.500*0255R001', '鋼捲倉', 'A-01', '1004', '1', '6100', 'YH26-1004', '燁輝', '0.5', '255', '7.85', '3050', '508', '順捲', '32.5', '進貨單 1150430002 / 1004 今日進料'),
  ('ZBE0.500*0255R001', '鋼捲倉', 'A-01', '1005', '1', '5950', 'YH26-1005', '燁輝', '0.5', '255', '7.85', '2975', '508', '順捲', '32.5', '進貨單 1150430002 / 1005 今日進料')
ON CONFLICT DO NOTHING;

-- ── 進貨主檔 → purchases (2 筆) ──
INSERT INTO purchases (id, date, billingmonth, vendorcode, vendorname, taxtype, taxrate, address, phone, terms, paydate, returnno, accountvoucher, nevertransfer, invoiceno, remark, totalamt, tax, grandtotal, totalqty, paidamt, unpaidamt) VALUES
  ('1150430001', '2026-04-30 00:00:00', '2026-04-01 00:00:00', '燁輝', '燁輝', '應稅', '5', NULL, NULL, '月結30天', NULL, NULL, NULL, 'N', NULL, '一鍵範例進貨 (ZBE 鋼捲 2 顆)', '0', '0', '0', '2', '0', '0'),
  ('1150430002', '2026-04-30 00:00:00', '2026-04-01 00:00:00', '燁輝', '燁輝', '應稅', '5', NULL, NULL, '月結30天', NULL, NULL, NULL, 'N', NULL, '一鍵範例進貨 (ZBE 鋼捲 3 顆)', '0', '0', '0', '3', '0', '0')
ON CONFLICT DO NOTHING;

-- ── 進貨細項 → purchase_items (2 筆) ──
INSERT INTO purchase_items (id, purchaseid, itemno, warehouse, model, spec, qty, total, price, amount) VALUES
  ('1150430001-0010', '1150430001', '10', '鋼捲倉', 'ZBE0.500*0255R001', '鍍鋅鋼捲 0.5*255 AZ100 G550', '2', '11800', '32.5', '383500'),
  ('1150430002-0010', '1150430002', '10', '鋼捲倉', 'ZBE0.500*0255R001', '鍍鋅鋼捲 0.5*255 AZ100 G550', '3', '17950', '32.5', '583375')
ON CONFLICT DO NOTHING;

-- ── 進貨批號 → purchase_batch (5 筆) ──
INSERT INTO purchase_batch (id, purchaseid, purchaseitemno, location, batchno, qty, total, originalrollno, vendor, indate, thickness, width, density, lengthm, innerring, coildirection, detailremark) VALUES
  ('1150430001-B0010-1001', '1150430001', '10', 'A-01', '1001', '1', '5800', 'YH26-1001', '燁輝', '2026-04-30 00:00:00', '0.5', '255', '7.85', '2900', '508', '順捲', '今日進料'),
  ('1150430001-B0010-1002', '1150430001', '10', 'A-01', '1002', '1', '6000', 'YH26-1002', '燁輝', '2026-04-30 00:00:00', '0.5', '255', '7.85', '3000', '508', '順捲', '今日進料'),
  ('1150430002-B0010-1003', '1150430002', '10', 'A-01', '1003', '1', '5900', 'YH26-1003', '燁輝', '2026-04-30 00:00:00', '0.5', '255', '7.85', '2950', '508', '順捲', '今日進料'),
  ('1150430002-B0010-1004', '1150430002', '10', 'A-01', '1004', '1', '6100', 'YH26-1004', '燁輝', '2026-04-30 00:00:00', '0.5', '255', '7.85', '3050', '508', '順捲', '今日進料'),
  ('1150430002-B0010-1005', '1150430002', '10', 'A-01', '1005', '1', '5950', 'YH26-1005', '燁輝', '2026-04-30 00:00:00', '0.5', '255', '7.85', '2975', '508', '順捲', '今日進料')
ON CONFLICT DO NOTHING;

-- ── 庫存異動明細 → stock_moves (5 筆) ──
INSERT INTO stock_moves (id, movedate, movetype, reftype, refid, model, batchno, warehouse, location, qty, total, unit, unitweight, color, paint, coating, strength, originalrollno, operator, remark) VALUES
  ('SM-1778248733057-0-4520', '2026-05-08 21:58:53', 'IN', 'PURCHASE', '1150430001', 'ZBE0.500*0255R001', '1001', '鋼捲倉', 'A-01', '1', '5800', 'KG', '0', NULL, NULL, NULL, NULL, 'YH26-1001', '進貨', '進貨單 1150430001 / 批號 1001'),
  ('SM-1778248733057-1-170', '2026-05-08 21:58:53', 'IN', 'PURCHASE', '1150430001', 'ZBE0.500*0255R001', '1002', '鋼捲倉', 'A-01', '1', '6000', 'KG', '0', NULL, NULL, NULL, NULL, 'YH26-1002', '進貨', '進貨單 1150430001 / 批號 1002'),
  ('SM-1778248748757-0-6262', '2026-05-08 21:59:08', 'IN', 'PURCHASE', '1150430002', 'ZBE0.500*0255R001', '1003', '鋼捲倉', 'A-01', '1', '5900', 'KG', '0', NULL, NULL, NULL, NULL, 'YH26-1003', '進貨', '進貨單 1150430002 / 批號 1003'),
  ('SM-1778248748757-1-9571', '2026-05-08 21:59:08', 'IN', 'PURCHASE', '1150430002', 'ZBE0.500*0255R001', '1004', '鋼捲倉', 'A-01', '1', '6100', 'KG', '0', NULL, NULL, NULL, NULL, 'YH26-1004', '進貨', '進貨單 1150430002 / 批號 1004'),
  ('SM-1778248748757-2-853', '2026-05-08 21:59:08', 'IN', 'PURCHASE', '1150430002', 'ZBE0.500*0255R001', '1005', '鋼捲倉', 'A-01', '1', '5950', 'KG', '0', NULL, NULL, NULL, NULL, 'YH26-1005', '進貨', '進貨單 1150430002 / 批號 1005')
ON CONFLICT DO NOTHING;

-- ── 設定類 ──
INSERT INTO settings_materials (value) VALUES ('鍍鋅') ON CONFLICT DO NOTHING;
INSERT INTO settings_materials (value) VALUES ('ST304') ON CONFLICT DO NOTHING;
INSERT INTO settings_factories (value) VALUES ('燁輝') ON CONFLICT DO NOTHING;
INSERT INTO settings_factories (value) VALUES ('盛餘') ON CONFLICT DO NOTHING;
INSERT INTO settings_colors (value) VALUES ('燁輝米黃') ON CONFLICT DO NOTHING;
INSERT INTO settings_colors (value) VALUES ('樸白') ON CONFLICT DO NOTHING;
INSERT INTO settings_coatings (value) VALUES ('AZ100') ON CONFLICT DO NOTHING;
INSERT INTO settings_coatings (value) VALUES ('Z180') ON CONFLICT DO NOTHING;
INSERT INTO settings_strengths (value) VALUES ('G550') ON CONFLICT DO NOTHING;
INSERT INTO settings_strengths (value) VALUES ('SS400') ON CONFLICT DO NOTHING;
INSERT INTO settings_categories (value) VALUES ('A01') ON CONFLICT DO NOTHING;
INSERT INTO settings_categories (value) VALUES ('B02') ON CONFLICT DO NOTHING;

SET session_replication_role = DEFAULT;

-- ✅ 完成！共 66 筆資料已驗證
