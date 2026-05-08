-- ================================================================
--  修正所有資料表欄位名稱：小寫 → camelCase（加引號保留大小寫）
--  在 Supabase SQL Editor 執行此腳本
--  資料不會遺失，只是欄位重命名
-- ================================================================

-- ── orders ──
ALTER TABLE orders RENAME COLUMN customercode TO "customerCode";
ALTER TABLE orders RENAME COLUMN customername TO "customerName";
ALTER TABLE orders RENAME COLUMN customershort TO "customerShort";
ALTER TABLE orders RENAME COLUMN contactphone TO "contactPhone";
ALTER TABLE orders RENAME COLUMN salesno TO "salesNo";
ALTER TABLE orders RENAME COLUMN doctype TO "docType";
ALTER TABLE orders RENAME COLUMN taxtype TO "taxType";
ALTER TABLE orders RENAME COLUMN printcount TO "printCount";
ALTER TABLE orders RENAME COLUMN articletext TO "articleText";
ALTER TABLE orders RENAME COLUMN dispatchremark TO "dispatchRemark";
ALTER TABLE orders RENAME COLUMN totalamt TO "totalAmt";
ALTER TABLE orders RENAME COLUMN grandtotal TO "grandTotal";
ALTER TABLE orders RENAME COLUMN qtysum TO "qtySum";
ALTER TABLE orders RENAME COLUMN totalsum TO "totalSum";
ALTER TABLE orders RENAME COLUMN weighno TO "weighNo";
ALTER TABLE orders RENAME COLUMN dispatchid TO "dispatchId";
ALTER TABLE orders RENAME COLUMN createdat TO "createdAt";
ALTER TABLE orders RENAME COLUMN updatedat TO "updatedAt";

-- ── order_items ──
ALTER TABLE order_items RENAME COLUMN orderid TO "orderId";
ALTER TABLE order_items RENAME COLUMN itemno TO "itemNo";
ALTER TABLE order_items RENAME COLUMN bottommachine TO "bottomMachine";
ALTER TABLE order_items RENAME COLUMN basematerialmodel TO "baseMaterialModel";
ALTER TABLE order_items RENAME COLUMN materialno TO "materialNo";
ALTER TABLE order_items RENAME COLUMN totalfeet TO "totalFeet";
ALTER TABLE order_items RENAME COLUMN totalqty TO "totalQty";
ALTER TABLE order_items RENAME COLUMN standardprice TO "standardPrice";
ALTER TABLE order_items RENAME COLUMN pricemodifier TO "priceModifier";
ALTER TABLE order_items RENAME COLUMN pricemodifytime TO "priceModifyTime";
ALTER TABLE order_items RENAME COLUMN costbasis TO "costBasis";
ALTER TABLE order_items RENAME COLUMN deliverydate TO "deliveryDate";

-- ── cutting_details ──
ALTER TABLE cutting_details RENAME COLUMN orderid TO "orderId";
ALTER TABLE cutting_details RENAME COLUMN orderitemno TO "orderItemNo";
ALTER TABLE cutting_details RENAME COLUMN lengthmm TO "lengthMm";
ALTER TABLE cutting_details RENAME COLUMN totalfeet TO "totalFeet";
ALTER TABLE cutting_details RENAME COLUMN topunfinish TO "topUnfinish";
ALTER TABLE cutting_details RENAME COLUMN topdone TO "topDone";
ALTER TABLE cutting_details RENAME COLUMN bottomunfinish TO "bottomUnfinish";
ALTER TABLE cutting_details RENAME COLUMN bottomdone TO "bottomDone";
ALTER TABLE cutting_details RENAME COLUMN mesunfinish TO "mesUnfinish";
ALTER TABLE cutting_details RENAME COLUMN dispatchid TO "dispatchId";
ALTER TABLE cutting_details RENAME COLUMN dispatchseq TO "dispatchSeq";
ALTER TABLE cutting_details RENAME COLUMN processno TO "processNo";
ALTER TABLE cutting_details RENAME COLUMN inboundno TO "inboundNo";
ALTER TABLE cutting_details RENAME COLUMN packagingmethod TO "packagingMethod";
ALTER TABLE cutting_details RENAME COLUMN deliverydate TO "deliveryDate";
ALTER TABLE cutting_details RENAME COLUMN inlocation TO "inLocation";
ALTER TABLE cutting_details RENAME COLUMN inbatchno TO "inBatchNo";
ALTER TABLE cutting_details RENAME COLUMN unreturnedqty TO "unreturnedQty";
ALTER TABLE cutting_details RENAME COLUMN unreturnedtotal TO "unreturnedTotal";
ALTER TABLE cutting_details RENAME COLUMN theoreticallenm TO "theoreticalLenM";
ALTER TABLE cutting_details RENAME COLUMN starttime TO "startTime";
ALTER TABLE cutting_details RENAME COLUMN finishtime TO "finishTime";
ALTER TABLE cutting_details RENAME COLUMN reportedat TO "reportedAt";

-- ── machines ──
ALTER TABLE machines RENAME COLUMN widthstart TO "widthStart";
ALTER TABLE machines RENAME COLUMN widthend TO "widthEnd";

-- ── warehouse_stock ──
ALTER TABLE warehouse_stock RENAME COLUMN warehouseno TO "warehouseNo";
ALTER TABLE warehouse_stock RENAME COLUMN movedate TO "moveDate";

-- ── batch_detail ──
ALTER TABLE batch_detail RENAME COLUMN warehouseno TO "warehouseNo";
ALTER TABLE batch_detail RENAME COLUMN batchno TO "batchNo";
ALTER TABLE batch_detail RENAME COLUMN originalrollno TO "originalRollNo";
ALTER TABLE batch_detail RENAME COLUMN lengthm TO "lengthM";
ALTER TABLE batch_detail RENAME COLUMN innerring TO "innerRing";
ALTER TABLE batch_detail RENAME COLUMN coildirection TO "coilDirection";
ALTER TABLE batch_detail RENAME COLUMN detailremark TO "detailRemark";

-- ── purchases ──
ALTER TABLE purchases RENAME COLUMN billingmonth TO "billingMonth";
ALTER TABLE purchases RENAME COLUMN vendorcode TO "vendorCode";
ALTER TABLE purchases RENAME COLUMN vendorname TO "vendorName";
ALTER TABLE purchases RENAME COLUMN taxtype TO "taxType";
ALTER TABLE purchases RENAME COLUMN taxrate TO "taxRate";
ALTER TABLE purchases RENAME COLUMN paydate TO "payDate";
ALTER TABLE purchases RENAME COLUMN returnno TO "returnNo";
ALTER TABLE purchases RENAME COLUMN accountvoucher TO "accountVoucher";
ALTER TABLE purchases RENAME COLUMN nevertransfer TO "neverTransfer";
ALTER TABLE purchases RENAME COLUMN invoiceno TO "invoiceNo";
ALTER TABLE purchases RENAME COLUMN totalamt TO "totalAmt";
ALTER TABLE purchases RENAME COLUMN grandtotal TO "grandTotal";
ALTER TABLE purchases RENAME COLUMN totalqty TO "totalQty";
ALTER TABLE purchases RENAME COLUMN paidamt TO "paidAmt";
ALTER TABLE purchases RENAME COLUMN unpaidamt TO "unpaidAmt";

-- ── purchase_items ──
ALTER TABLE purchase_items RENAME COLUMN purchaseid TO "purchaseId";
ALTER TABLE purchase_items RENAME COLUMN itemno TO "itemNo";

-- ── purchase_batch ──
ALTER TABLE purchase_batch RENAME COLUMN purchaseid TO "purchaseId";
ALTER TABLE purchase_batch RENAME COLUMN purchaseitemno TO "purchaseItemNo";
ALTER TABLE purchase_batch RENAME COLUMN batchno TO "batchNo";
ALTER TABLE purchase_batch RENAME COLUMN originalrollno TO "originalRollNo";
ALTER TABLE purchase_batch RENAME COLUMN indate TO "inDate";
ALTER TABLE purchase_batch RENAME COLUMN lengthm TO "lengthM";
ALTER TABLE purchase_batch RENAME COLUMN innerring TO "innerRing";
ALTER TABLE purchase_batch RENAME COLUMN coildirection TO "coilDirection";
ALTER TABLE purchase_batch RENAME COLUMN detailremark TO "detailRemark";

-- ── labels ──
ALTER TABLE labels RENAME COLUMN labelno TO "labelNo";
ALTER TABLE labels RENAME COLUMN orderid TO "orderId";
ALTER TABLE labels RENAME COLUMN orderitemno TO "orderItemNo";
ALTER TABLE labels RENAME COLUMN customershort TO "customerShort";
ALTER TABLE labels RENAME COLUMN totallen TO "totalLen";
ALTER TABLE labels RENAME COLUMN totalweight TO "totalWeight";
ALTER TABLE labels RENAME COLUMN createtime TO "createTime";
ALTER TABLE labels RENAME COLUMN starttime TO "startTime";
ALTER TABLE labels RENAME COLUMN endtime TO "endTime";

-- ── dispatch_orders ──
ALTER TABLE dispatch_orders RENAME COLUMN doccategory TO "docCategory";
ALTER TABLE dispatch_orders RENAME COLUMN doctype TO "docType";
ALTER TABLE dispatch_orders RENAME COLUMN orderid TO "orderId";
ALTER TABLE dispatch_orders RENAME COLUMN partnercode TO "partnerCode";
ALTER TABLE dispatch_orders RENAME COLUMN partnername TO "partnerName";
ALTER TABLE dispatch_orders RENAME COLUMN receivetime TO "receiveTime";
ALTER TABLE dispatch_orders RENAME COLUMN finishtime TO "finishTime";
ALTER TABLE dispatch_orders RENAME COLUMN workhours TO "workHours";
ALTER TABLE dispatch_orders RENAME COLUMN printcount TO "printCount";
ALTER TABLE dispatch_orders RENAME COLUMN dispatchremark TO "dispatchRemark";
ALTER TABLE dispatch_orders RENAME COLUMN estimatedpickqty TO "estimatedPickQty";
ALTER TABLE dispatch_orders RENAME COLUMN estimatedinqty TO "estimatedInQty";
ALTER TABLE dispatch_orders RENAME COLUMN estimatedremainqty TO "estimatedRemainQty";
ALTER TABLE dispatch_orders RENAME COLUMN totallength TO "totalLength";
ALTER TABLE dispatch_orders RENAME COLUMN difflength TO "diffLength";
ALTER TABLE dispatch_orders RENAME COLUMN lossrate TO "lossRate";
ALTER TABLE dispatch_orders RENAME COLUMN toptotallen TO "topTotalLen";
ALTER TABLE dispatch_orders RENAME COLUMN bottomtotallen TO "bottomTotalLen";
ALTER TABLE dispatch_orders RENAME COLUMN finishedtotallen TO "finishedTotalLen";
ALTER TABLE dispatch_orders RENAME COLUMN createdat TO "createdAt";
ALTER TABLE dispatch_orders RENAME COLUMN updatedat TO "updatedAt";

-- ── dispatch_coil_moves ──
ALTER TABLE dispatch_coil_moves RENAME COLUMN dispatchid TO "dispatchId";
ALTER TABLE dispatch_coil_moves RENAME COLUMN itemno TO "itemNo";
ALTER TABLE dispatch_coil_moves RENAME COLUMN dispatchseq TO "dispatchSeq";
ALTER TABLE dispatch_coil_moves RENAME COLUMN orderitemno TO "orderItemNo";
ALTER TABLE dispatch_coil_moves RENAME COLUMN processno TO "processNo";
ALTER TABLE dispatch_coil_moves RENAME COLUMN inboundno TO "inboundNo";
ALTER TABLE dispatch_coil_moves RENAME COLUMN outbatchno TO "outBatchNo";
ALTER TABLE dispatch_coil_moves RENAME COLUMN materialno TO "materialNo";
ALTER TABLE dispatch_coil_moves RENAME COLUMN categoryunreturned TO "categoryUnreturned";
ALTER TABLE dispatch_coil_moves RENAME COLUMN costbasis TO "costBasis";
ALTER TABLE dispatch_coil_moves RENAME COLUMN materialprice TO "materialPrice";
ALTER TABLE dispatch_coil_moves RENAME COLUMN factoryreturnedqty TO "factoryReturnedQty";
ALTER TABLE dispatch_coil_moves RENAME COLUMN unitweight TO "unitWeight";
ALTER TABLE dispatch_coil_moves RENAME COLUMN salereturn TO "saleReturn";
ALTER TABLE dispatch_coil_moves RENAME COLUMN salereturndate TO "saleReturnDate";
ALTER TABLE dispatch_coil_moves RENAME COLUMN usedtotalm TO "usedTotalM";
ALTER TABLE dispatch_coil_moves RENAME COLUMN outwarehouse TO "outWarehouse";
ALTER TABLE dispatch_coil_moves RENAME COLUMN outlocation TO "outLocation";
ALTER TABLE dispatch_coil_moves RENAME COLUMN inwarehouse TO "inWarehouse";
ALTER TABLE dispatch_coil_moves RENAME COLUMN inlocation TO "inLocation";
ALTER TABLE dispatch_coil_moves RENAME COLUMN inbatchno TO "inBatchNo";
ALTER TABLE dispatch_coil_moves RENAME COLUMN topweight TO "topWeight";
ALTER TABLE dispatch_coil_moves RENAME COLUMN bottomweight TO "bottomWeight";
ALTER TABLE dispatch_coil_moves RENAME COLUMN fullyused TO "fullyUsed";
ALTER TABLE dispatch_coil_moves RENAME COLUMN usedpart TO "usedPart";
ALTER TABLE dispatch_coil_moves RENAME COLUMN createtime TO "createTime";
ALTER TABLE dispatch_coil_moves RENAME COLUMN weightadjustreason TO "weightAdjustReason";
ALTER TABLE dispatch_coil_moves RENAME COLUMN originalrollno TO "originalRollNo";
ALTER TABLE dispatch_coil_moves RENAME COLUMN furnaceno TO "furnaceNo";
ALTER TABLE dispatch_coil_moves RENAME COLUMN coilno TO "coilNo";
ALTER TABLE dispatch_coil_moves RENAME COLUMN loadweight TO "loadWeight";
ALTER TABLE dispatch_coil_moves RENAME COLUMN unloadweight TO "unloadWeight";

-- ── dispatch_production ──
ALTER TABLE dispatch_production RENAME COLUMN dispatchid TO "dispatchId";
ALTER TABLE dispatch_production RENAME COLUMN dispatchseq TO "dispatchSeq";
ALTER TABLE dispatch_production RENAME COLUMN orderid TO "orderId";
ALTER TABLE dispatch_production RENAME COLUMN orderitemno TO "orderItemNo";
ALTER TABLE dispatch_production RENAME COLUMN lengthmm TO "lengthMm";
ALTER TABLE dispatch_production RENAME COLUMN totalfeet TO "totalFeet";
ALTER TABLE dispatch_production RENAME COLUMN theoreticallenm TO "theoreticalLenM";
ALTER TABLE dispatch_production RENAME COLUMN materialno TO "materialNo";
ALTER TABLE dispatch_production RENAME COLUMN customercode TO "customerCode";
ALTER TABLE dispatch_production RENAME COLUMN sitename TO "siteName";
ALTER TABLE dispatch_production RENAME COLUMN deliverydate TO "deliveryDate";
ALTER TABLE dispatch_production RENAME COLUMN topunfinish TO "topUnfinish";
ALTER TABLE dispatch_production RENAME COLUMN topdone TO "topDone";
ALTER TABLE dispatch_production RENAME COLUMN bottomunfinish TO "bottomUnfinish";
ALTER TABLE dispatch_production RENAME COLUMN bottomdone TO "bottomDone";
ALTER TABLE dispatch_production RENAME COLUMN mesunfinish TO "mesUnfinish";
ALTER TABLE dispatch_production RENAME COLUMN unreturnedqty TO "unreturnedQty";
ALTER TABLE dispatch_production RENAME COLUMN unreturnedtotal TO "unreturnedTotal";
ALTER TABLE dispatch_production RENAME COLUMN starttime TO "startTime";
ALTER TABLE dispatch_production RENAME COLUMN finishtime TO "finishTime";
ALTER TABLE dispatch_production RENAME COLUMN inboundno TO "inboundNo";
ALTER TABLE dispatch_production RENAME COLUMN unitprice TO "unitPrice";
ALTER TABLE dispatch_production RENAME COLUMN pricebasis TO "priceBasis";
ALTER TABLE dispatch_production RENAME COLUMN materialprice TO "materialPrice";
ALTER TABLE dispatch_production RENAME COLUMN costbasis TO "costBasis";
ALTER TABLE dispatch_production RENAME COLUMN costprice TO "costPrice";
ALTER TABLE dispatch_production RENAME COLUMN salereturn TO "saleReturn";
ALTER TABLE dispatch_production RENAME COLUMN unitweight TO "unitWeight";
ALTER TABLE dispatch_production RENAME COLUMN inlocation TO "inLocation";
ALTER TABLE dispatch_production RENAME COLUMN inbatchno TO "inBatchNo";
ALTER TABLE dispatch_production RENAME COLUMN originalrollno TO "originalRollNo";
ALTER TABLE dispatch_production RENAME COLUMN furnaceno TO "furnaceNo";
ALTER TABLE dispatch_production RENAME COLUMN processno TO "processNo";
ALTER TABLE dispatch_production RENAME COLUMN packagingmethod TO "packagingMethod";
ALTER TABLE dispatch_production RENAME COLUMN shipmethod TO "shipMethod";

-- ── dispatch_returns ──
ALTER TABLE dispatch_returns RENAME COLUMN dispatchid TO "dispatchId";
ALTER TABLE dispatch_returns RENAME COLUMN doccategory TO "docCategory";
ALTER TABLE dispatch_returns RENAME COLUMN orderid TO "orderId";
ALTER TABLE dispatch_returns RENAME COLUMN partnercode TO "partnerCode";
ALTER TABLE dispatch_returns RENAME COLUMN partnername TO "partnerName";
ALTER TABLE dispatch_returns RENAME COLUMN finishtime TO "finishTime";
ALTER TABLE dispatch_returns RENAME COLUMN totalin TO "totalIn";
ALTER TABLE dispatch_returns RENAME COLUMN totaldeduct TO "totalDeduct";
ALTER TABLE dispatch_returns RENAME COLUMN createdat TO "createdAt";
ALTER TABLE dispatch_returns RENAME COLUMN updatedat TO "updatedAt";
ALTER TABLE dispatch_returns RENAME COLUMN purchaseorderid TO "purchaseOrderId";
ALTER TABLE dispatch_returns RENAME COLUMN printcount TO "printCount";
ALTER TABLE dispatch_returns RENAME COLUMN processamount TO "processAmount";
ALTER TABLE dispatch_returns RENAME COLUMN processtotal TO "processTotal";
ALTER TABLE dispatch_returns RENAME COLUMN lossrate TO "lossRate";
ALTER TABLE dispatch_returns RENAME COLUMN dispatchremark TO "dispatchRemark";
ALTER TABLE dispatch_returns RENAME COLUMN remaintotal TO "remainTotal";
ALTER TABLE dispatch_returns RENAME COLUMN effectiveworkhours TO "effectiveWorkHours";
ALTER TABLE dispatch_returns RENAME COLUMN pausedhours TO "pausedHours";
ALTER TABLE dispatch_returns RENAME COLUMN sessioncount TO "sessionCount";

-- ── dispatch_return_items ──
ALTER TABLE dispatch_return_items RENAME COLUMN returnid TO "returnId";
ALTER TABLE dispatch_return_items RENAME COLUMN dispatchid TO "dispatchId";
ALTER TABLE dispatch_return_items RENAME COLUMN labelid TO "labelId";
ALTER TABLE dispatch_return_items RENAME COLUMN labelno TO "labelNo";
ALTER TABLE dispatch_return_items RENAME COLUMN orderid TO "orderId";
ALTER TABLE dispatch_return_items RENAME COLUMN orderitemno TO "orderItemNo";
ALTER TABLE dispatch_return_items RENAME COLUMN cuttingdetailid TO "cuttingDetailId";
ALTER TABLE dispatch_return_items RENAME COLUMN totallen TO "totalLen";
ALTER TABLE dispatch_return_items RENAME COLUMN totalweight TO "totalWeight";
ALTER TABLE dispatch_return_items RENAME COLUMN cutmethod TO "cutMethod";
ALTER TABLE dispatch_return_items RENAME COLUMN topdone TO "topDone";
ALTER TABLE dispatch_return_items RENAME COLUMN bottomdone TO "bottomDone";
ALTER TABLE dispatch_return_items RENAME COLUMN starttime TO "startTime";
ALTER TABLE dispatch_return_items RENAME COLUMN endtime TO "endTime";
ALTER TABLE dispatch_return_items RENAME COLUMN inboundno TO "inboundNo";
ALTER TABLE dispatch_return_items RENAME COLUMN materialno TO "materialNo";
ALTER TABLE dispatch_return_items RENAME COLUMN unitprice TO "unitPrice";
ALTER TABLE dispatch_return_items RENAME COLUMN pricebasis TO "priceBasis";
ALTER TABLE dispatch_return_items RENAME COLUMN materialprice TO "materialPrice";
ALTER TABLE dispatch_return_items RENAME COLUMN costbasis TO "costBasis";
ALTER TABLE dispatch_return_items RENAME COLUMN costprice TO "costPrice";
ALTER TABLE dispatch_return_items RENAME COLUMN salereturn TO "saleReturn";
ALTER TABLE dispatch_return_items RENAME COLUMN deliverydate TO "deliveryDate";
ALTER TABLE dispatch_return_items RENAME COLUMN customercode TO "customerCode";
ALTER TABLE dispatch_return_items RENAME COLUMN unitweight TO "unitWeight";
ALTER TABLE dispatch_return_items RENAME COLUMN inlocation TO "inLocation";
ALTER TABLE dispatch_return_items RENAME COLUMN inbatchno TO "inBatchNo";
ALTER TABLE dispatch_return_items RENAME COLUMN originalrollno TO "originalRollNo";
ALTER TABLE dispatch_return_items RENAME COLUMN furnaceno TO "furnaceNo";
ALTER TABLE dispatch_return_items RENAME COLUMN processno TO "processNo";
ALTER TABLE dispatch_return_items RENAME COLUMN packagingmethod TO "packagingMethod";
ALTER TABLE dispatch_return_items RENAME COLUMN shipmethod TO "shipMethod";

-- ── dispatch_return_deduct ──
ALTER TABLE dispatch_return_deduct RENAME COLUMN returnid TO "returnId";
ALTER TABLE dispatch_return_deduct RENAME COLUMN dispatchid TO "dispatchId";
ALTER TABLE dispatch_return_deduct RENAME COLUMN coilmoveid TO "coilMoveId";
ALTER TABLE dispatch_return_deduct RENAME COLUMN batchno TO "batchNo";
ALTER TABLE dispatch_return_deduct RENAME COLUMN originalrollno TO "originalRollNo";
ALTER TABLE dispatch_return_deduct RENAME COLUMN createdat TO "createdAt";
ALTER TABLE dispatch_return_deduct RENAME COLUMN materialno TO "materialNo";
ALTER TABLE dispatch_return_deduct RENAME COLUMN costbasis TO "costBasis";
ALTER TABLE dispatch_return_deduct RENAME COLUMN materialprice TO "materialPrice";
ALTER TABLE dispatch_return_deduct RENAME COLUMN unitweight TO "unitWeight";
ALTER TABLE dispatch_return_deduct RENAME COLUMN furnaceno TO "furnaceNo";
ALTER TABLE dispatch_return_deduct RENAME COLUMN dispatchseq TO "dispatchSeq";

-- ── dispatch_return_reporters ──
ALTER TABLE dispatch_return_reporters RENAME COLUMN returnid TO "returnId";
ALTER TABLE dispatch_return_reporters RENAME COLUMN dispatchid TO "dispatchId";
ALTER TABLE dispatch_return_reporters RENAME COLUMN itemno TO "itemNo";
ALTER TABLE dispatch_return_reporters RENAME COLUMN starttime TO "startTime";
ALTER TABLE dispatch_return_reporters RENAME COLUMN endtime TO "endTime";
ALTER TABLE dispatch_return_reporters RENAME COLUMN workhours TO "workHours";
ALTER TABLE dispatch_return_reporters RENAME COLUMN createdat TO "createdAt";
ALTER TABLE dispatch_return_reporters RENAME COLUMN updatedat TO "updatedAt";

-- ── stock_moves ──
ALTER TABLE stock_moves RENAME COLUMN movedate TO "moveDate";
ALTER TABLE stock_moves RENAME COLUMN movetype TO "moveType";
ALTER TABLE stock_moves RENAME COLUMN reftype TO "refType";
ALTER TABLE stock_moves RENAME COLUMN refid TO "refId";
ALTER TABLE stock_moves RENAME COLUMN batchno TO "batchNo";
ALTER TABLE stock_moves RENAME COLUMN unitweight TO "unitWeight";
ALTER TABLE stock_moves RENAME COLUMN originalrollno TO "originalRollNo";

-- ── inventory ──
ALTER TABLE inventory RENAME COLUMN productname TO "productName";
ALTER TABLE inventory RENAME COLUMN salesname TO "salesName";
ALTER TABLE inventory RENAME COLUMN materialno TO "materialNo";
ALTER TABLE inventory RENAME COLUMN colorcode TO "colorCode";
ALTER TABLE inventory RENAME COLUMN frontpaint TO "frontPaint";
ALTER TABLE inventory RENAME COLUMN backpaint TO "backPaint";
ALTER TABLE inventory RENAME COLUMN frontpaintthick TO "frontPaintThick";
ALTER TABLE inventory RENAME COLUMN backpaintthick TO "backPaintThick";
ALTER TABLE inventory RENAME COLUMN packagingmethod TO "packagingMethod";

-- ✅ 完成！共重命名 275 個欄位
