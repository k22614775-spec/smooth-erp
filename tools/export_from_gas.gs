/**
 * ============================================================
 *  ERP + MES — Google Sheets 全量匯出工具
 *  使用方法：
 *    1. 把此檔案貼到原本的 Google Apps Script 專案
 *    2. 執行 exportAllDataToJson()
 *    3. 到 Google Drive 找「ERP_export_YYYYMMDD.json」下載
 * ============================================================
 */

function exportAllDataToJson() {
  const ui = SpreadsheetApp.getUi();

  // 所有工作表清單（順序 = 匯入 Supabase 的正確順序）
  const EXPORT_SHEETS = [
    // 設定類（無相依）
    { sheet: '機台設定',   table: 'machines',         headers: ['id','name','method','widthStart','widthEnd','material','remark'] },
    // 訂單系列
    { sheet: '訂單主檔',   table: 'orders',            headers: ['id','date','customerCode','customerName','customerShort','site','contactPhone','fax','salesNo','docType','taxType','terms','audited','auditor','printCount','address','articleText','remark','dispatchRemark','totalAmt','tax','grandTotal','qtySum','totalSum','profit','status','weighNo','dispatchId','createdAt','updatedAt'] },
    { sheet: '訂單細項',   table: 'order_items',       headers: ['id','orderId','itemNo','machine','bottomMachine','model','spec','method','baseMaterialModel','materialNo','factory','coating','strength','size','color','paint','qty','totalFeet','totalQty','length','unit','price','amount','standardPrice','priceModifier','priceModifyTime','costBasis','formula','deliveryDate','category'] },
    { sheet: '裁切細項',   table: 'cutting_details',   headers: ['id','orderId','orderItemNo','zone','bundle','feet','lengthMm','qty','totalFeet','kg','topUnfinish','topDone','bottomUnfinish','bottomDone','mesUnfinish','remark','dispatchId','dispatchSeq','processNo','inboundNo','packagingMethod','deliveryDate','inLocation','inBatchNo','closed','unreturnedQty','unreturnedTotal','theoreticalLenM','startTime','finishTime','reporter','reportedAt'] },
    // 庫存系列
    { sheet: '庫存主檔',   table: 'inventory',         headers: ['類別','型號','品名規格','銷貨品名','材質編號','廠別','尺寸','顏色','色碼','漆種','正面漆種','背面漆種','正面漆膜厚','背面漆膜厚','鍍層','強度','包裝方式','單位','數量','總數','備註'], colMap: {category:'類別',model:'型號',productName:'品名規格',salesName:'銷貨品名',materialNo:'材質編號',factory:'廠別',size:'尺寸',color:'顏色',colorCode:'色碼',paint:'漆種',frontPaint:'正面漆種',backPaint:'背面漆種',frontPaintThick:'正面漆膜厚',backPaintThick:'背面漆膜厚',coating:'鍍層',strength:'強度',packagingMethod:'包裝方式',unit:'單位',qty:'數量',total:'總數',remark:'備註'} },
    { sheet: '倉庫存量',   table: 'warehouse_stock',   headers: ['型號','倉庫編號','數量','總數','進價','金額','異動日期','備註'], colMap: {model:'型號',warehouseNo:'倉庫編號',qty:'數量',total:'總數',price:'進價',amount:'金額',moveDate:'異動日期',remark:'備註'} },
    { sheet: '批號明細',   table: 'batch_detail',      headers: ['型號','倉庫編號','儲位','批號','數量','總數','原廠捲號','供應商','鋼捲厚度','鋼捲寬度','鋼捲比重','長度M','內圈','鋼捲捲向','進價','細項備註'], colMap: {model:'型號',warehouseNo:'倉庫編號',location:'儲位',batchNo:'批號',qty:'數量',total:'總數',originalRollNo:'原廠捲號',vendor:'供應商',thickness:'鋼捲厚度',width:'鋼捲寬度',density:'鋼捲比重',lengthM:'長度M',innerRing:'內圈',coilDirection:'鋼捲捲向',price:'進價',detailRemark:'細項備註'} },
    // 進貨系列
    { sheet: '進貨主檔',   table: 'purchases',         headers: ['id','date','billingMonth','vendorCode','vendorName','taxType','taxRate','address','phone','terms','payDate','returnNo','accountVoucher','neverTransfer','invoiceNo','remark','totalAmt','tax','grandTotal','totalQty','paidAmt','unpaidAmt'] },
    { sheet: '進貨細項',   table: 'purchase_items',    headers: ['id','purchaseId','itemNo','warehouse','model','spec','qty','total','price','amount'] },
    { sheet: '進貨批號',   table: 'purchase_batch',    headers: ['id','purchaseId','purchaseItemNo','location','batchNo','qty','total','originalRollNo','vendor','inDate','thickness','width','density','lengthM','innerRing','coilDirection','detailRemark'] },
    // 標籤
    { sheet: '標籤記錄',   table: 'labels',            headers: ['id','labelNo','orderId','orderItemNo','machine','customerShort','model','spec','qty','totalLen','totalWeight','unit','createTime','startTime','endTime','operator','status','remark'] },
    // 派工系列（依順序）
    { sheet: '派工單頭',   table: 'dispatch_orders',   headers: ['id','date','docCategory','docType','source','orderId','partnerCode','partnerName','operator','machine','phase','receiveTime','finishTime','workHours','printCount','remark','dispatchRemark','estimatedPickQty','estimatedInQty','estimatedRemainQty','totalLength','diffLength','lossRate','topTotalLen','bottomTotalLen','finishedTotalLen','status','createdAt','updatedAt'] },
    { sheet: '派工扣庫明細', table: 'dispatch_coil_moves', headers: ['id','dispatchId','itemNo','dispatchSeq','orderItemNo','processNo','inboundNo','model','outBatchNo','spec','qty','total','unit','size','materialNo','factory','categoryUnreturned','costBasis','materialPrice','cost','factoryReturnedQty','formula','unitWeight','saleReturn','saleReturnDate','usedTotalM','outWarehouse','outLocation','inWarehouse','inLocation','inBatchNo','category','topWeight','bottomWeight','fullyUsed','usedPart','createTime','weightAdjustReason','color','paint','coating','strength','originalRollNo','furnaceNo','remark','coilNo','loadWeight','unloadWeight'] },
    { sheet: '派工入庫明細', table: 'dispatch_production', headers: ['id','dispatchId','dispatchSeq','orderId','orderItemNo','zone','bundle','category','model','spec','feet','lengthMm','qty','totalFeet','theoreticalLenM','kg','materialNo','factory','size','color','paint','coating','strength','customerCode','siteName','deliveryDate','topUnfinish','topDone','bottomUnfinish','bottomDone','mesUnfinish','unreturnedQty','unreturnedTotal','startTime','finishTime','reporter','closed','remark','inboundNo','formula','unitPrice','priceBasis','materialPrice','costBasis','costPrice','saleReturn','unitWeight','inLocation','inBatchNo','originalRollNo','furnaceNo','processNo','packagingMethod','shipMethod'] },
    { sheet: '派工回單頭',  table: 'dispatch_returns',  headers: ['id','dispatchId','date','docCategory','orderId','partnerCode','partnerName','operator','machine','finishTime','totalIn','totalDeduct','remark','status','createdAt','updatedAt','purchaseOrderId','printCount','processAmount','processTotal','lossRate','dispatchRemark','remainTotal','effectiveWorkHours','pausedHours','sessionCount'] },
    { sheet: '派工回單入庫明細', table: 'dispatch_return_items', headers: ['id','returnId','dispatchId','labelId','labelNo','orderId','orderItemNo','cuttingDetailId','machine','model','spec','qty','totalLen','totalWeight','unit','cutMethod','topDone','bottomDone','startTime','endTime','operator','remark','inboundNo','formula','materialNo','factory','size','unitPrice','priceBasis','materialPrice','costBasis','costPrice','saleReturn','deliveryDate','customerCode','closed','unitWeight','inLocation','inBatchNo','category','color','paint','coating','strength','originalRollNo','furnaceNo','processNo','packagingMethod','shipMethod'] },
    { sheet: '派工回單扣庫明細', table: 'dispatch_return_deduct', headers: ['id','returnId','dispatchId','coilMoveId','model','batchNo','warehouse','location','qty','total','unit','originalRollNo','createdAt','spec','size','materialNo','remark','costBasis','materialPrice','factory','formula','unitWeight','category','color','paint','coating','strength','furnaceNo','dispatchSeq'] },
    { sheet: '派工回單回報人員', table: 'dispatch_return_reporters', headers: ['id','returnId','dispatchId','machine','itemNo','reporters','startTime','endTime','workHours','status','remark','createdAt','updatedAt'] },
    // 庫存異動
    { sheet: '庫存異動明細', table: 'stock_moves',    headers: ['id','moveDate','moveType','refType','refId','model','batchNo','warehouse','location','qty','total','unit','unitWeight','color','paint','coating','strength','originalRollNo','operator','remark'] },
  ];

  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const result = {};
  const log = [];
  let totalRows = 0;

  EXPORT_SHEETS.forEach(function(cfg) {
    const sheetName = cfg.sheet;
    const tableName = cfg.table;
    const sheet = ss.getSheetByName(sheetName);

    if (!sheet || sheet.getLastRow() <= 1) {
      log.push(sheetName + ' → 空白，略過');
      result[tableName] = [];
      return;
    }

    const data = sheet.getDataRange().getDisplayValues();
    const sheetHeaders = data.shift().map(function(h){ return String(h).trim(); });

    // 若有 colMap，把中文 header 轉成英文欄位名
    const colMap = cfg.colMap || null;

    const rows = data.map(function(row) {
      const obj = {};
      sheetHeaders.forEach(function(h, i) {
        if (!h) return;
        // 決定 key：colMap 有的就用英文名，否則保留原名（英文 header 的工作表）
        let key = h;
        if (colMap) {
          // 反查：找 colMap 中哪個英文名對應這個中文 header
          const found = Object.keys(colMap).find(function(k){ return colMap[k] === h; });
          if (found) key = found;
        }
        const v = row[i];
        obj[key] = (v === '' || v === null || v === undefined) ? null : v;
      });
      return obj;
    }).filter(function(row) {
      // 過濾完全空白的列
      return Object.values(row).some(function(v){ return v !== null && v !== ''; });
    });

    result[tableName] = rows;
    totalRows += rows.length;
    log.push(sheetName + ' → ' + tableName + '：' + rows.length + ' 筆');
  });

  // 加上匯出 metadata
  result.__meta = {
    exportedAt: new Date().toISOString(),
    totalTables: Object.keys(result).length - 1,
    totalRows: totalRows,
    source: ss.getName(),
    log: log
  };

  const jsonStr = JSON.stringify(result, null, 2);

  // 存到 Google Drive
  const today = Utilities.formatDate(new Date(), 'Asia/Taipei', 'yyyyMMdd_HHmm');
  const fileName = 'ERP_export_' + today + '.json';
  const file = DriveApp.createFile(fileName, jsonStr, MimeType.PLAIN_TEXT);
  const fileUrl = file.getUrl();

  // 顯示結果
  const summary = log.join('\n') + '\n\n共 ' + totalRows + ' 筆資料\n\n下載網址：\n' + fileUrl;
  ui.alert('匯出完成', summary, ui.ButtonSet.OK);

  Logger.log('匯出完成：' + fileName);
  Logger.log('下載網址：' + fileUrl);
}
