-- ================================================================
--  修正欄位名稱：小寫 → camelCase（安全版，已改過的欄位自動略過）
--  使用 DO $$ BEGIN...EXCEPTION WHEN undefined_column THEN NULL; END $$;
--  重複執行安全，不會報錯
-- ================================================================

-- ── orders ──
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN customercode TO "customerCode";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN customername TO "customerName";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN customershort TO "customerShort";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN contactphone TO "contactPhone";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN salesno TO "salesNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN doctype TO "docType";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN taxtype TO "taxType";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN printcount TO "printCount";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN articletext TO "articleText";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN dispatchremark TO "dispatchRemark";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN totalamt TO "totalAmt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN grandtotal TO "grandTotal";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN qtysum TO "qtySum";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN totalsum TO "totalSum";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN weighno TO "weighNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN dispatchid TO "dispatchId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN createdat TO "createdAt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE orders RENAME COLUMN updatedat TO "updatedAt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── order_items ──
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN orderid TO "orderId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN itemno TO "itemNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN bottommachine TO "bottomMachine";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN basematerialmodel TO "baseMaterialModel";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN materialno TO "materialNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN totalfeet TO "totalFeet";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN totalqty TO "totalQty";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN standardprice TO "standardPrice";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN pricemodifier TO "priceModifier";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN pricemodifytime TO "priceModifyTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN costbasis TO "costBasis";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE order_items RENAME COLUMN deliverydate TO "deliveryDate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── cutting_details ──
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN orderid TO "orderId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN orderitemno TO "orderItemNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN lengthmm TO "lengthMm";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN totalfeet TO "totalFeet";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN topunfinish TO "topUnfinish";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN topdone TO "topDone";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN bottomunfinish TO "bottomUnfinish";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN bottomdone TO "bottomDone";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN mesunfinish TO "mesUnfinish";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN dispatchid TO "dispatchId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN dispatchseq TO "dispatchSeq";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN processno TO "processNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN inboundno TO "inboundNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN packagingmethod TO "packagingMethod";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN deliverydate TO "deliveryDate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN inlocation TO "inLocation";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN inbatchno TO "inBatchNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN unreturnedqty TO "unreturnedQty";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN unreturnedtotal TO "unreturnedTotal";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN theoreticallenm TO "theoreticalLenM";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN starttime TO "startTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN finishtime TO "finishTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE cutting_details RENAME COLUMN reportedat TO "reportedAt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── machines ──
DO $$ BEGIN
  ALTER TABLE machines RENAME COLUMN widthstart TO "widthStart";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE machines RENAME COLUMN widthend TO "widthEnd";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── warehouse_stock ──
DO $$ BEGIN
  ALTER TABLE warehouse_stock RENAME COLUMN warehouseno TO "warehouseNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE warehouse_stock RENAME COLUMN movedate TO "moveDate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── batch_detail ──
DO $$ BEGIN
  ALTER TABLE batch_detail RENAME COLUMN warehouseno TO "warehouseNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE batch_detail RENAME COLUMN batchno TO "batchNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE batch_detail RENAME COLUMN originalrollno TO "originalRollNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE batch_detail RENAME COLUMN lengthm TO "lengthM";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE batch_detail RENAME COLUMN innerring TO "innerRing";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE batch_detail RENAME COLUMN coildirection TO "coilDirection";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE batch_detail RENAME COLUMN detailremark TO "detailRemark";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── purchases ──
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN billingmonth TO "billingMonth";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN vendorcode TO "vendorCode";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN vendorname TO "vendorName";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN taxtype TO "taxType";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN taxrate TO "taxRate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN paydate TO "payDate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN returnno TO "returnNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN accountvoucher TO "accountVoucher";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN nevertransfer TO "neverTransfer";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN invoiceno TO "invoiceNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN totalamt TO "totalAmt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN grandtotal TO "grandTotal";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN totalqty TO "totalQty";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN paidamt TO "paidAmt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchases RENAME COLUMN unpaidamt TO "unpaidAmt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── purchase_items ──
DO $$ BEGIN
  ALTER TABLE purchase_items RENAME COLUMN purchaseid TO "purchaseId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchase_items RENAME COLUMN itemno TO "itemNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── purchase_batch ──
DO $$ BEGIN
  ALTER TABLE purchase_batch RENAME COLUMN purchaseid TO "purchaseId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchase_batch RENAME COLUMN purchaseitemno TO "purchaseItemNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchase_batch RENAME COLUMN batchno TO "batchNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchase_batch RENAME COLUMN originalrollno TO "originalRollNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchase_batch RENAME COLUMN indate TO "inDate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchase_batch RENAME COLUMN lengthm TO "lengthM";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchase_batch RENAME COLUMN innerring TO "innerRing";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchase_batch RENAME COLUMN coildirection TO "coilDirection";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE purchase_batch RENAME COLUMN detailremark TO "detailRemark";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── labels ──
DO $$ BEGIN
  ALTER TABLE labels RENAME COLUMN labelno TO "labelNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE labels RENAME COLUMN orderid TO "orderId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE labels RENAME COLUMN orderitemno TO "orderItemNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE labels RENAME COLUMN customershort TO "customerShort";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE labels RENAME COLUMN totallen TO "totalLen";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE labels RENAME COLUMN totalweight TO "totalWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE labels RENAME COLUMN createtime TO "createTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE labels RENAME COLUMN starttime TO "startTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE labels RENAME COLUMN endtime TO "endTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── dispatch_orders ──
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN doccategory TO "docCategory";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN doctype TO "docType";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN orderid TO "orderId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN partnercode TO "partnerCode";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN partnername TO "partnerName";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN receivetime TO "receiveTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN finishtime TO "finishTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN workhours TO "workHours";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN printcount TO "printCount";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN dispatchremark TO "dispatchRemark";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN estimatedpickqty TO "estimatedPickQty";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN estimatedinqty TO "estimatedInQty";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN estimatedremainqty TO "estimatedRemainQty";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN totallength TO "totalLength";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN difflength TO "diffLength";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN lossrate TO "lossRate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN toptotallen TO "topTotalLen";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN bottomtotallen TO "bottomTotalLen";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN finishedtotallen TO "finishedTotalLen";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN createdat TO "createdAt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_orders RENAME COLUMN updatedat TO "updatedAt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── dispatch_coil_moves ──
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN dispatchid TO "dispatchId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN itemno TO "itemNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN dispatchseq TO "dispatchSeq";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN orderitemno TO "orderItemNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN processno TO "processNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN inboundno TO "inboundNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN outbatchno TO "outBatchNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN materialno TO "materialNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN categoryunreturned TO "categoryUnreturned";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN costbasis TO "costBasis";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN materialprice TO "materialPrice";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN factoryreturnedqty TO "factoryReturnedQty";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN unitweight TO "unitWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN salereturn TO "saleReturn";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN salereturndate TO "saleReturnDate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN usedtotalm TO "usedTotalM";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN outwarehouse TO "outWarehouse";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN outlocation TO "outLocation";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN inwarehouse TO "inWarehouse";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN inlocation TO "inLocation";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN inbatchno TO "inBatchNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN topweight TO "topWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN bottomweight TO "bottomWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN fullyused TO "fullyUsed";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN usedpart TO "usedPart";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN createtime TO "createTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN weightadjustreason TO "weightAdjustReason";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN originalrollno TO "originalRollNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN furnaceno TO "furnaceNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN coilno TO "coilNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN loadweight TO "loadWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_coil_moves RENAME COLUMN unloadweight TO "unloadWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── dispatch_production ──
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN dispatchid TO "dispatchId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN dispatchseq TO "dispatchSeq";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN orderid TO "orderId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN orderitemno TO "orderItemNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN lengthmm TO "lengthMm";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN totalfeet TO "totalFeet";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN theoreticallenm TO "theoreticalLenM";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN materialno TO "materialNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN customercode TO "customerCode";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN sitename TO "siteName";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN deliverydate TO "deliveryDate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN topunfinish TO "topUnfinish";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN topdone TO "topDone";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN bottomunfinish TO "bottomUnfinish";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN bottomdone TO "bottomDone";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN mesunfinish TO "mesUnfinish";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN unreturnedqty TO "unreturnedQty";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN unreturnedtotal TO "unreturnedTotal";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN starttime TO "startTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN finishtime TO "finishTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN inboundno TO "inboundNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN unitprice TO "unitPrice";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN pricebasis TO "priceBasis";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN materialprice TO "materialPrice";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN costbasis TO "costBasis";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN costprice TO "costPrice";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN salereturn TO "saleReturn";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN unitweight TO "unitWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN inlocation TO "inLocation";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN inbatchno TO "inBatchNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN originalrollno TO "originalRollNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN furnaceno TO "furnaceNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN processno TO "processNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN packagingmethod TO "packagingMethod";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_production RENAME COLUMN shipmethod TO "shipMethod";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── dispatch_returns ──
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN dispatchid TO "dispatchId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN doccategory TO "docCategory";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN orderid TO "orderId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN partnercode TO "partnerCode";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN partnername TO "partnerName";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN finishtime TO "finishTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN totalin TO "totalIn";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN totaldeduct TO "totalDeduct";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN createdat TO "createdAt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN updatedat TO "updatedAt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN purchaseorderid TO "purchaseOrderId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN printcount TO "printCount";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN processamount TO "processAmount";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN processtotal TO "processTotal";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN lossrate TO "lossRate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN dispatchremark TO "dispatchRemark";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN remaintotal TO "remainTotal";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN effectiveworkhours TO "effectiveWorkHours";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN pausedhours TO "pausedHours";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_returns RENAME COLUMN sessioncount TO "sessionCount";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── dispatch_return_items ──
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN returnid TO "returnId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN dispatchid TO "dispatchId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN labelid TO "labelId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN labelno TO "labelNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN orderid TO "orderId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN orderitemno TO "orderItemNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN cuttingdetailid TO "cuttingDetailId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN totallen TO "totalLen";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN totalweight TO "totalWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN cutmethod TO "cutMethod";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN topdone TO "topDone";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN bottomdone TO "bottomDone";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN starttime TO "startTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN endtime TO "endTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN inboundno TO "inboundNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN materialno TO "materialNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN unitprice TO "unitPrice";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN pricebasis TO "priceBasis";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN materialprice TO "materialPrice";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN costbasis TO "costBasis";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN costprice TO "costPrice";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN salereturn TO "saleReturn";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN deliverydate TO "deliveryDate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN customercode TO "customerCode";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN unitweight TO "unitWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN inlocation TO "inLocation";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN inbatchno TO "inBatchNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN originalrollno TO "originalRollNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN furnaceno TO "furnaceNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN processno TO "processNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN packagingmethod TO "packagingMethod";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_items RENAME COLUMN shipmethod TO "shipMethod";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── dispatch_return_deduct ──
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN returnid TO "returnId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN dispatchid TO "dispatchId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN coilmoveid TO "coilMoveId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN batchno TO "batchNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN originalrollno TO "originalRollNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN createdat TO "createdAt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN materialno TO "materialNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN costbasis TO "costBasis";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN materialprice TO "materialPrice";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN unitweight TO "unitWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN furnaceno TO "furnaceNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_deduct RENAME COLUMN dispatchseq TO "dispatchSeq";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── dispatch_return_reporters ──
DO $$ BEGIN
  ALTER TABLE dispatch_return_reporters RENAME COLUMN returnid TO "returnId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_reporters RENAME COLUMN dispatchid TO "dispatchId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_reporters RENAME COLUMN itemno TO "itemNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_reporters RENAME COLUMN starttime TO "startTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_reporters RENAME COLUMN endtime TO "endTime";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_reporters RENAME COLUMN workhours TO "workHours";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_reporters RENAME COLUMN createdat TO "createdAt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE dispatch_return_reporters RENAME COLUMN updatedat TO "updatedAt";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── stock_moves ──
DO $$ BEGIN
  ALTER TABLE stock_moves RENAME COLUMN movedate TO "moveDate";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE stock_moves RENAME COLUMN movetype TO "moveType";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE stock_moves RENAME COLUMN reftype TO "refType";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE stock_moves RENAME COLUMN refid TO "refId";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE stock_moves RENAME COLUMN batchno TO "batchNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE stock_moves RENAME COLUMN unitweight TO "unitWeight";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE stock_moves RENAME COLUMN originalrollno TO "originalRollNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ── inventory ──
DO $$ BEGIN
  ALTER TABLE inventory RENAME COLUMN productname TO "productName";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE inventory RENAME COLUMN salesname TO "salesName";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE inventory RENAME COLUMN materialno TO "materialNo";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE inventory RENAME COLUMN colorcode TO "colorCode";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE inventory RENAME COLUMN frontpaint TO "frontPaint";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE inventory RENAME COLUMN backpaint TO "backPaint";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE inventory RENAME COLUMN frontpaintthick TO "frontPaintThick";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE inventory RENAME COLUMN backpaintthick TO "backPaintThick";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;
DO $$ BEGIN
  ALTER TABLE inventory RENAME COLUMN packagingmethod TO "packagingMethod";
EXCEPTION WHEN undefined_column OR duplicate_column THEN NULL;
END $$;

-- ✅ 完成！共 275 個欄位（已重命名的自動略過）
