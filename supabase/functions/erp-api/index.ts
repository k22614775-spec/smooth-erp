/**
 * ERP + MES 整合系統 — Supabase Edge Function
 * 對應原 Google Apps Script Code_merged.gs
 *
 * 呼叫方式：POST /functions/v1/erp-api
 * Body: { "action": "actionName", ...params }
 *
 * 使用 Supabase service_role key（在 secrets 中設定 SUPABASE_SERVICE_ROLE_KEY）
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl  = Deno.env.get("SUPABASE_URL")!;
const serviceKey   = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase     = createClient(supabaseUrl, serviceKey);

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ============================================================
// 工具函式
// ============================================================

function nowIso() { return new Date().toISOString(); }

function nowLocalStr() {
  return new Date().toLocaleString("zh-TW", { timeZone: "Asia/Taipei" });
}

/** 生成流水 ID：{prefix}{民國年}{MMDD}{流水3碼}
 *  例：D1150507001 */
async function generateId(prefix: string, table: string) {
  const d = new Date();
  const y = d.getFullYear() - 1911;
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  const datePrefix = `${prefix}${y}${mm}${dd}`;

  const { data } = await supabase
    .from(table)
    .select("id")
    .like("id", `${datePrefix}%`)
    .order("id", { ascending: false })
    .limit(1);

  let maxSeq = 0;
  if (data && data.length > 0) {
    const lastId = String(data[0].id || "");
    const seq = parseInt(lastId.substring(datePrefix.length), 10) || 0;
    if (seq > maxSeq) maxSeq = seq;
  }
  return datePrefix + String(maxSeq + 1).padStart(3, "0");
}

// ============================================================
// 路由表：action → handler
// ============================================================

async function router(action: string, body: Record<string, unknown>) {
  switch (action) {
    // ── 全量讀取 ──
    case "loadAllData":         return await loadAllData();
    // ── 訂單 ──
    case "getOrders":           return await getOrders();
    case "getPendingDispatchOrders": return await getPendingDispatchOrders();
    case "getOrderHeader":      return await getOrderHeader(body.orderId as string);
    case "getOrderItems":       return await getOrderItems(body.orderId as string);
    case "getCuttingDetails":   return await getCuttingDetails(body.orderId as string, body.orderItemNo as string);
    case "getOrderFull":        return await getOrderFull(body.orderId as string);
    case "listOrderIds":        return await listOrderIds();
    case "saveOrder":           return await saveOrder(body.payload as OrderPayload);
    case "updateOrder":         return await updateOrder(body.orderData as Record<string, unknown>);
    case "getSubItems":         return await getSubItems(body.orderId as string);
    // ── 裁切/標籤 ──
    case "saveCuttingReport":   return await saveCuttingReport(body.records as CuttingRecord[]);
    case "saveLabel":           return await saveLabel(body.label as Record<string, unknown>);
    case "getLabelsByOrder":    return await getLabelsByOrder(body.orderId as string);
    case "mergeCuttingDetails": return await mergeCuttingDetailsByZoneAndLength();
    // ── 庫存 ──
    case "getInventoryFull":    return await getInventoryFull();
    case "saveInventory":       return await saveInventory(body.payload as InventoryPayload);
    case "searchCoilStock":     return await searchCoilStock(body.filter as Record<string, unknown>);
    // ── 進貨 ──
    case "listPurchaseIds":     return await listPurchaseIds();
    case "getPurchaseFull":     return await getPurchaseFull(body.purchaseId as string);
    case "savePurchase":        return await savePurchase(body.payload as PurchasePayload);
    // ── 派工 ──
    case "createDispatchFromOrder": return await createDispatchFromOrder(body.orderId as string, body.opts as Record<string, unknown>);
    case "getDispatchHeader":   return await getDispatchHeader(body.dispatchId as string);
    case "getDispatchCoilMoves": return await getDispatchCoilMoves(body.dispatchId as string);
    case "getDispatchProduction": return await getDispatchProduction(body.dispatchId as string);
    case "getDispatchFull":     return await getDispatchFull(body.dispatchId as string);
    case "listDispatchIds":     return await listDispatchIds();
    case "checkActiveDispatch": return await checkActiveDispatch(body.machine as string);
    case "addCoilMove":         return await addCoilMove(body.dispatchId as string, body.coilMove as Record<string, unknown>);
    case "removeCoilMove":      return await removeCoilMove(body.dispatchId as string, body.moveId as string);
    case "updateCoilMoveUnloadWeight": return await updateCoilMoveUnloadWeight(body.dispatchId as string, body.moveId as string, Number(body.unloadKg));
    case "addLeftoverInbound":  return await addLeftoverInbound(body.dispatchId as string, body.leftover as Record<string, unknown>);
    case "closeDispatch":       return await closeDispatch(body.dispatchId as string, body.workHours as string);
    case "endDispatch":         return await endDispatch(body.dispatchId as string, body.opts as Record<string, unknown>);
    case "linkOrderCuttingsToDispatch": return await linkOrderCuttingsToDispatch(body.orderId as string, body.dispatchId as string);
    // ── 回報人員 ──
    case "addReporterSession":          return await addReporterSession(body.dispatchId as string, body.reporters as string, body.opts as Record<string, unknown>);
    case "pauseReporterSession":        return await pauseReporterSession(body.dispatchId as string, body.opts as Record<string, unknown>);
    case "switchReporterSession":       return await switchReporterSession(body.dispatchId as string, body.newReporters as string, body.opts as Record<string, unknown>);
    case "resumeReporterSession":       return await resumeReporterSession(body.dispatchId as string, body.reporters as string, body.opts as Record<string, unknown>);
    case "getReporterSessionsByDispatch": return await getReporterSessionsByDispatch(body.dispatchId as string);
    case "computeEffectiveWorkHours":   return await computeEffectiveWorkHours(body.dispatchId as string);
    // ── 派工回單 ──
    case "listDispatchReturnIds":       return await listDispatchReturnIds();
    case "getDispatchReturnFull":       return await getDispatchReturnFull(body.returnId as string);
    // ── 工具 ──
    case "resetSimulationData":         return await resetSimulationData();
    case "rebuildDispatchProductionSheet": return await rebuildDispatchProductionSheet(body.dispatchId as string);
    default:
      throw new Error(`未知的 action: ${action}`);
  }
}

// ============================================================
// Types
// ============================================================
interface OrderPayload  { order: Record<string, unknown>; items?: Record<string, unknown>[]; cuttings?: Record<string, unknown>[]; }
interface CuttingRecord { id?: string; orderId?: string; dispatchId?: string; startTime?: string; finishTime?: string; [key: string]: unknown; }
interface InventoryPayload { inventory?: unknown[]; warehouseStock?: unknown[]; batchDetail?: unknown[]; }
interface PurchasePayload  { purchase: Record<string, unknown>; items?: Record<string, unknown>[]; batches?: Record<string, unknown>[]; }

// ============================================================
// 1. 全量讀取
// ============================================================
async function loadAllData() {
  const [machines, orders, orderItems, cuttingDetails, inventory,
         warehouseStock, batchDetail, purchases, purchaseItems, purchaseBatch, labels] = await Promise.all([
    supabase.from("machines").select("*").then(r => r.data || []),
    supabase.from("orders").select("*").then(r => r.data || []),
    supabase.from("order_items").select("*").then(r => r.data || []),
    supabase.from("cutting_details").select("*").then(r => r.data || []),
    supabase.from("inventory").select("*").then(r => r.data || []),
    supabase.from("warehouse_stock").select("*").then(r => r.data || []),
    supabase.from("batch_detail").select("*").then(r => r.data || []),
    supabase.from("purchases").select("*").then(r => r.data || []),
    supabase.from("purchase_items").select("*").then(r => r.data || []),
    supabase.from("purchase_batch").select("*").then(r => r.data || []),
    supabase.from("labels").select("*").then(r => r.data || []),
  ]);
  return { machines, orders, orderItems, cuttingDetails, inventory, warehouseStock, batchDetail, purchases, purchaseItems, purchaseBatch, labels };
}

// ============================================================
// 2. 訂單系列
// ============================================================
async function getOrders() {
  const [ordersRes, itemsRes, dispatchesRes] = await Promise.all([
    supabase.from("orders").select("*"),
    supabase.from("order_items").select("*"),
    supabase.from("dispatch_orders").select("id, orderId, status"),
  ]);
  const orders   = ordersRes.data || [];
  const items    = itemsRes.data || [];
  const dispatches = dispatchesRes.data || [];

  const orderMap: Record<string, Record<string, unknown>> = {};
  orders.forEach((o: Record<string, unknown>) => { orderMap[String(o.id)] = o; });

  const dispatchByOrder: Record<string, Record<string, unknown>[]> = {};
  dispatches.forEach((d: Record<string, unknown>) => {
    if (!d.orderId) return;
    const oid = String(d.orderId);
    if (!dispatchByOrder[oid]) dispatchByOrder[oid] = [];
    dispatchByOrder[oid].push(d);
  });

  return items.map((it: Record<string, unknown>) => {
    const o  = orderMap[String(it.orderId)] || {};
    const ds = dispatchByOrder[String(it.orderId)] || [];
    const dispatched = ds.some(d => String(d.status || "") !== "");
    const dispatchId = ds.length ? ds[0].id : "";
    return {
      id:            `${it.orderId}-${it.itemNo || ""}`,
      orderId:       it.orderId,
      itemNo:        it.itemNo,
      customerShort: o.customerShort || "",
      site:          o.site || "",
      weighNo:       o.weighNo || "",
      machine:       it.machine,
      model:         it.model,
      spec:          it.spec,
      qty:           it.qty,
      totalLen:      it.totalFeet,
      totalWeight:   it.totalQty,
      date:          it.deliveryDate || o.date,
      remark:        o.remark || "",
      unit:          it.unit,
      baseMaterialModel: it.baseMaterialModel,
      manufacturingMethod: it.method,
      materialNo:    it.materialNo,
      factory:       it.factory,
      status:        dispatched ? "已派工" : (String(o.status || "待派工")),
      hasDispatch:   dispatched,
      dispatchId:    dispatchId,
    };
  });
}

async function getPendingDispatchOrders() {
  const all = await getOrders();
  return all.filter((r: Record<string, unknown>) => !r.hasDispatch);
}

async function getOrderHeader(orderId: string) {
  if (!orderId) return null;
  const { data } = await supabase.from("orders").select("*").eq("id", orderId).single();
  return data || null;
}

async function getOrderItems(orderId: string) {
  if (!orderId) return [];
  const { data } = await supabase.from("order_items").select("*").eq("orderId", orderId).order("itemNo");
  return data || [];
}

async function getCuttingDetails(orderId: string, orderItemNo: string) {
  if (!orderId) return [];
  let q = supabase.from("cutting_details").select("*").eq("orderId", orderId);
  if (orderItemNo) q = q.eq("orderItemNo", orderItemNo);
  const { data } = await q;
  return consolidateCuttings(data || []);
}

async function getOrderFull(orderId: string) {
  if (!orderId) return null;
  const [header, items, cuttings, labelsData] = await Promise.all([
    getOrderHeader(orderId),
    getOrderItems(orderId),
    getCuttingDetails(orderId, ""),
    getLabelsByOrder(orderId),
  ]);
  return { header, items, cuttings, labels: labelsData };
}

async function listOrderIds() {
  const { data } = await supabase.from("orders").select("id, date, customerName, customerShort, status").order("id", { ascending: false });
  return data || [];
}

async function saveOrder(payload: OrderPayload) {
  if (!payload?.order?.id) throw new Error("saveOrder 需要 order.id");
  const now = nowIso();
  payload.order.updatedAt = now;
  if (!payload.order.createdAt) payload.order.createdAt = now;
  if (!payload.order.status) payload.order.status = "待派工";

  const { error: oe } = await supabase.from("orders").upsert(payload.order, { onConflict: "id" });
  if (oe) throw oe;

  if (Array.isArray(payload.items)) {
    await supabase.from("order_items").delete().eq("orderId", payload.order.id);
    const rows = payload.items.map(it => ({
      ...it,
      orderId: payload.order.id,
      id: it.id || `${payload.order.id}-${it.itemNo || ""}`,
    }));
    if (rows.length) { const { error } = await supabase.from("order_items").upsert(rows); if (error) throw error; }
  }

  if (Array.isArray(payload.cuttings)) {
    await supabase.from("cutting_details").delete().eq("orderId", payload.order.id);
    const rows = payload.cuttings.map(c => ({
      ...c,
      orderId: payload.order.id,
      id: c.id || `c${Date.now()}${Math.floor(Math.random() * 1000)}`,
    }));
    if (rows.length) { const { error } = await supabase.from("cutting_details").upsert(rows); if (error) throw error; }
  }

  return { ok: true, id: payload.order.id };
}

async function updateOrder(orderData: Record<string, unknown>) {
  if (!orderData?.id) throw new Error("updateOrder 需要 id");
  const parts = String(orderData.id).split("-");
  const oid   = parts[0];
  const itemNo = parts[1] || orderData.itemNo;

  const fieldMap: Record<string, string> = {
    machine: "machine", model: "model", spec: "spec",
    qty: "qty", totalLen: "totalFeet", totalWeight: "totalQty",
    unit: "unit", baseMaterialModel: "baseMaterialModel",
    manufacturingMethod: "method", materialNo: "materialNo", factory: "factory",
  };
  const itemUpdate: Record<string, unknown> = {};
  for (const [src, dst] of Object.entries(fieldMap)) {
    if (orderData[src] !== undefined) itemUpdate[dst] = orderData[src];
  }
  if (Object.keys(itemUpdate).length) {
    let q = supabase.from("order_items").update(itemUpdate).eq("orderId", oid);
    if (itemNo) q = q.eq("itemNo", itemNo);
    await q;
  }

  const orderUpdate: Record<string, unknown> = { updatedAt: nowIso() };
  for (const f of ["customerShort", "site", "weighNo", "remark"]) {
    if (orderData[f] !== undefined) orderUpdate[f] = orderData[f];
  }
  await supabase.from("orders").update(orderUpdate).eq("id", oid);

  return { updated: true, id: orderData.id };
}

async function getSubItems(orderId: string) {
  if (!orderId) return [];
  const parts = String(orderId).split("-");
  const oid   = parts[0];
  const itemNo = parts[1] || null;
  let q = supabase.from("cutting_details").select("*").eq("orderId", oid);
  if (itemNo) q = q.eq("orderItemNo", itemNo);
  const { data } = await q;
  const merged = consolidateCuttings(data || []);
  return merged.map((r: Record<string, unknown>) => ({
    id: r.id, orderId: r.orderId, zone: r.zone, bundle: r.bundle,
    length: r.feet, qty: r.qty, totalLen: r.totalFeet, kg: r.kg,
    unfinish: r.mesUnfinish || r.topUnfinish,
    orderItemNo: r.orderItemNo, lengthMm: r.lengthMm,
    topUnfinish: r.topUnfinish, topDone: r.topDone,
    bottomUnfinish: r.bottomUnfinish, bottomDone: r.bottomDone, remark: r.remark,
  }));
}

// ── 裁切合併（前端 API / Edge 共用）──
function consolidateCuttings(rows: Record<string, unknown>[]) {
  const map: Record<string, Record<string, unknown>> = {};
  const order: string[] = [];
  rows.forEach(c => {
    const feet = +parseFloat(String(c.feet || c.length || 0)).toFixed(2);
    const k = `${c.orderItemNo || "0010"}|${feet.toFixed(2)}`;
    if (!map[k]) {
      map[k] = {
        id: `m-${c.orderId || ""}-${k}`, orderId: c.orderId || "",
        orderItemNo: c.orderItemNo || "0010", zoneSet: {} as Record<string, boolean>,
        bundleSet: {} as Record<string, boolean>, feet, lengthMm: parseFloat(String(c.lengthMm || feet * 303)) || 0,
        qty: 0, totalFeet: 0, kg: 0,
        topUnfinish: 0, topDone: 0, bottomUnfinish: 0, bottomDone: 0, mesUnfinish: 0,
        remark: c.remark || "", startTime: "", finishTime: "", reporter: "", closed: 0, dispatchId: c.dispatchId || "",
      };
      order.push(k);
    }
    const m = map[k];
    if (c.zone) (m.zoneSet as Record<string, boolean>)[String(c.zone)] = true;
    if (c.bundle != null && c.bundle !== "") (m.bundleSet as Record<string, boolean>)[String(c.bundle)] = true;
    m.qty           = (Number(m.qty) || 0) + (parseInt(String(c.qty || 0), 10) || 0);
    m.totalFeet     = (Number(m.totalFeet) || 0) + (parseFloat(String(c.totalFeet || 0)) || 0);
    m.kg            = (Number(m.kg) || 0) + (parseFloat(String(c.kg || 0)) || 0);
    m.topUnfinish   = (Number(m.topUnfinish) || 0) + (parseInt(String(c.topUnfinish || 0), 10) || 0);
    m.topDone       = (Number(m.topDone) || 0) + (parseInt(String(c.topDone || 0), 10) || 0);
    m.bottomUnfinish = (Number(m.bottomUnfinish) || 0) + (parseInt(String(c.bottomUnfinish || 0), 10) || 0);
    m.bottomDone    = (Number(m.bottomDone) || 0) + (parseInt(String(c.bottomDone || 0), 10) || 0);
    m.mesUnfinish   = (Number(m.mesUnfinish) || 0) + (parseInt(String(c.mesUnfinish || c.qty || 0), 10) || 0);
    if (c.startTime && (!m.startTime || String(c.startTime) < String(m.startTime))) m.startTime = c.startTime;
    if (c.finishTime && (!m.finishTime || String(c.finishTime) > String(m.finishTime))) m.finishTime = c.finishTime;
    if (c.reporter && !m.reporter) m.reporter = c.reporter;
    if (c.closed) m.closed = 1;
    if (c.dispatchId && !m.dispatchId) m.dispatchId = c.dispatchId;
  });
  return order.map(k => {
    const m = map[k];
    m.zone   = Object.keys(m.zoneSet as Record<string, boolean>).sort().join("、");
    m.bundle = Object.keys(m.bundleSet as Record<string, boolean>).sort().join(",") || "0";
    m.totalFeet = +Number(m.totalFeet).toFixed(2);
    m.kg        = +Number(m.kg).toFixed(2);
    delete m.zoneSet; delete m.bundleSet;
    return m;
  });
}

// ============================================================
// 3. 裁切 / 標籤
// ============================================================
async function saveCuttingReport(records: CuttingRecord[]) {
  if (!records?.length) return { saved: 0 };
  const nowIsoStr = nowIso();

  for (const r of records) {
    if (!r.id) r.id = `m${Date.now()}${Math.floor(Math.random() * 1000)}`;
    if (r.startTime || r.finishTime) r.reportedAt = r.reportedAt || nowIsoStr;
    await supabase.from("cutting_details").upsert(r, { onConflict: "id" });
  }

  // 自動結案：同 dispatchId 下所有裁切行都有 finishTime
  const dids = [...new Set(records.map(r => r.dispatchId).filter(Boolean))];
  const closed: string[] = [];
  for (const did of dids) {
    const { data: rows } = await supabase.from("cutting_details").select("finishTime, dispatchId").eq("dispatchId", did!);
    if (rows && rows.length && rows.every(r => r.finishTime)) {
      await closeDispatch(did!, "");
      closed.push(did!);
    }
  }
  return { saved: records.length, closedDispatches: closed };
}

async function saveLabel(label: Record<string, unknown>) {
  if (!label.id) label.id = `L${Date.now()}`;
  if (!label.createTime) label.createTime = nowLocalStr();
  const { error } = await supabase.from("labels").upsert(label, { onConflict: "id" });
  if (error) throw error;
  return label.id;
}

async function getLabelsByOrder(orderId: string) {
  if (!orderId) return [];
  const { data } = await supabase.from("labels").select("*").eq("orderId", orderId);
  return data || [];
}

async function mergeCuttingDetailsByZoneAndLength() {
  const { data: before } = await supabase.from("cutting_details").select("*");
  if (!before?.length) return { before: 0, after: 0, removed: 0, message: "裁切細項為空" };

  const map: Record<string, Record<string, unknown>> = {};
  const order: string[] = [];
  before.forEach((c: Record<string, unknown>) => {
    const feet = +parseFloat(String(c.feet || 0)).toFixed(2);
    const k    = `${c.orderId}|${c.orderItemNo || "0010"}|${c.zone || ""}|${feet.toFixed(2)}`;
    if (!map[k]) {
      map[k] = { ...c, qty: 0, totalFeet: 0, kg: 0, topUnfinish: 0, topDone: 0, bottomUnfinish: 0, bottomDone: 0, mesUnfinish: 0 };
      map[k].id = `m-${c.orderId}-${c.orderItemNo}-${c.zone}-${feet}`;
      map[k].bundleSet = {};
      map[k].remarkSet = {};
      order.push(k);
    }
    const m = map[k];
    if (c.bundle) (m.bundleSet as Record<string, boolean>)[String(c.bundle)] = true;
    if (c.remark) (m.remarkSet as Record<string, boolean>)[String(c.remark)] = true;
    for (const f of ["qty", "totalFeet", "kg", "topUnfinish", "topDone", "bottomUnfinish", "bottomDone", "mesUnfinish"]) {
      m[f] = (Number(m[f]) || 0) + (Number(c[f]) || 0);
    }
  });

  const merged = order.map(k => {
    const m = map[k];
    m.bundle = Object.keys(m.bundleSet as Record<string, boolean>).join(",") || "0";
    m.remark = Object.keys(m.remarkSet as Record<string, boolean>).filter(Boolean).join(",");
    delete m.bundleSet; delete m.remarkSet;
    return m;
  });

  await supabase.from("cutting_details").delete().neq("id", "__none__");
  if (merged.length) await supabase.from("cutting_details").insert(merged);

  return { before: before.length, after: merged.length, removed: before.length - merged.length, message: `合併完成，${before.length} → ${merged.length} 筆` };
}

// ============================================================
// 4. 庫存
// ============================================================
async function getInventoryFull() {
  const [invRes, stockRes, batchRes] = await Promise.all([
    supabase.from("inventory").select("*"),
    supabase.from("warehouse_stock").select("*"),
    supabase.from("batch_detail").select("*"),
  ]);
  return {
    inventory:      invRes.data || [],
    warehouseStock: stockRes.data || [],
    batchDetail:    batchRes.data || [],
  };
}

async function saveInventory(payload: InventoryPayload) {
  if (Array.isArray(payload.inventory)) {
    await supabase.from("inventory").delete().neq("id", 0);
    if (payload.inventory.length) await supabase.from("inventory").insert(payload.inventory);
  }
  if (Array.isArray(payload.warehouseStock)) {
    await supabase.from("warehouse_stock").delete().neq("id", 0);
    if (payload.warehouseStock.length) await supabase.from("warehouse_stock").insert(payload.warehouseStock);
  }
  if (Array.isArray(payload.batchDetail)) {
    await supabase.from("batch_detail").delete().neq("id", 0);
    if (payload.batchDetail.length) await supabase.from("batch_detail").insert(payload.batchDetail);
  }
  return { ok: true };
}

async function searchCoilStock(filter: Record<string, unknown>) {
  let q = supabase.from("batch_detail").select("*");
  if (filter.model)     q = q.ilike("model", `%${filter.model}%`);
  if (filter.batchNo)   q = q.eq("batchNo", filter.batchNo);
  if (filter.warehouse) q = q.eq("warehouseNo", filter.warehouse);
  const { data } = await q.order("id");
  return data || [];
}

// ============================================================
// 5. 進貨
// ============================================================
async function listPurchaseIds() {
  const { data } = await supabase.from("purchases").select("id, date, vendorName, grandTotal").order("id", { ascending: false });
  return data || [];
}

async function getPurchaseFull(purchaseId: string) {
  if (!purchaseId) return null;
  const [header, items, batches] = await Promise.all([
    supabase.from("purchases").select("*").eq("id", purchaseId).single(),
    supabase.from("purchase_items").select("*").eq("purchaseId", purchaseId).order("itemNo"),
    supabase.from("purchase_batch").select("*").eq("purchaseId", purchaseId),
  ]);
  return { header: header.data, items: items.data || [], batches: batches.data || [] };
}

async function savePurchase(payload: PurchasePayload) {
  if (!payload?.purchase?.id) throw new Error("savePurchase 需要 purchase.id");
  const pid = String(payload.purchase.id);

  // 寫入進貨主檔
  const { error: pe } = await supabase.from("purchases").upsert(payload.purchase, { onConflict: "id" });
  if (pe) throw pe;

  // 細項
  if (Array.isArray(payload.items)) {
    await supabase.from("purchase_items").delete().eq("purchaseId", pid);
    const rows = payload.items.map((it, idx) => ({
      ...it, purchaseId: pid,
      id: String(it.id || `${pid}-${String(idx + 1).padStart(4, "0")}`),
    }));
    if (rows.length) { const { error } = await supabase.from("purchase_items").insert(rows); if (error) throw error; }
  }

  // 批號
  if (Array.isArray(payload.batches)) {
    await supabase.from("purchase_batch").delete().eq("purchaseId", pid);
    const rows = payload.batches.map((b, idx) => ({
      ...b, purchaseId: pid,
      id: String(b.id || `${pid}-B${String(idx + 1).padStart(3, "0")}`),
    }));
    if (rows.length) { const { error } = await supabase.from("purchase_batch").insert(rows); if (error) throw error; }

    // 同步更新庫存：先反沖既有進貨庫存，再打入新進貨
    await _reversePurchaseStockMoves(pid);
    await _applyPurchaseToStock(pid, payload.purchase, payload.items || [], payload.batches);
  }

  return { ok: true, id: pid };
}

async function _reversePurchaseStockMoves(purchaseId: string) {
  // 刪除該進貨對應的 stock_moves，並從 warehouse_stock / batch_detail 中扣回
  const { data: moves } = await supabase.from("stock_moves").select("*").eq("refId", purchaseId).eq("refType", "PURCHASE");
  if (!moves?.length) return;
  for (const m of moves) {
    // 從 warehouse_stock 扣掉原來的入庫量
    await supabase.from("warehouse_stock").update({
      qty:   supabase.rpc("decrement_numeric", { x: m.qty,   table_name: "warehouse_stock", id_col: "id" }),
      total: supabase.rpc("decrement_numeric", { x: m.total, table_name: "warehouse_stock", id_col: "id" }),
    }).eq("model", m.model).eq("warehouseNo", m.warehouse).catch(() => {});
    // 移除對應 batch_detail
    await supabase.from("batch_detail").delete().eq("batchNo", m.batchNo).eq("model", m.model);
    await supabase.from("stock_moves").delete().eq("id", m.id);
  }
}

async function _applyPurchaseToStock(
  purchaseId: string,
  purchase: Record<string, unknown>,
  items: Record<string, unknown>[],
  batches: Record<string, unknown>[]
) {
  const now = nowIso();
  const purchaseDate = String(purchase.date || now);

  for (const batch of batches) {
    const itemNo = String(batch.purchaseItemNo || "");
    const item   = items.find(it => String(it.itemNo) === itemNo) || {};
    const model  = String(item.model || batch.model || "");
    const warehouse = String(item.warehouse || "");
    const qty    = Number(batch.qty || 0);
    const total  = Number(batch.total || 0);
    const price  = Number(item.price || 0);

    if (!model) continue;

    // 更新 warehouse_stock（upsert by model + warehouseNo）
    const { data: existing } = await supabase
      .from("warehouse_stock")
      .select("id, qty, total, amount")
      .eq("model", model)
      .eq("warehouseNo", warehouse)
      .single();

    if (existing) {
      await supabase.from("warehouse_stock").update({
        qty:     Number(existing.qty)    + qty,
        total:   Number(existing.total)  + total,
        amount:  Number(existing.amount) + (price * total),
        moveDate: purchaseDate,
      }).eq("id", existing.id);
    } else {
      await supabase.from("warehouse_stock").insert({
        model, warehouseNo: warehouse, qty, total, price, amount: price * total, moveDate: purchaseDate,
      });
    }

    // 寫入 batch_detail
    await supabase.from("batch_detail").upsert({
      model, warehouseNo: warehouse,
      location:      String(batch.location || ""),
      batchNo:       String(batch.batchNo || ""),
      qty, total,
      originalRollNo: String(batch.originalRollNo || ""),
      vendor:        String(purchase.vendorName || ""),
      thickness:     Number(batch.thickness || 0),
      width:         Number(batch.width || 0),
      density:       Number(batch.density || 0),
      lengthM:       Number(batch.lengthM || 0),
      innerRing:     String(batch.innerRing || ""),
      coilDirection: String(batch.coilDirection || ""),
      price,
      detailRemark:  String(batch.detailRemark || ""),
    }, { onConflict: "batchNo,model" });

    // 寫入 stock_moves
    const moveId = `SM${Date.now()}${Math.floor(Math.random() * 100)}`;
    await supabase.from("stock_moves").insert({
      id: moveId, moveDate: purchaseDate, moveType: "IN", refType: "PURCHASE", refId: purchaseId,
      model, batchNo: String(batch.batchNo || ""), warehouse, location: String(batch.location || ""),
      qty, total, unit: String(item.unit || ""), unitWeight: Number(batch.density || 0),
      originalRollNo: String(batch.originalRollNo || ""), operator: String(purchase.operator || ""),
    });
  }
}

// ============================================================
// 6. 派工系列
// ============================================================
async function createDispatchFromOrder(orderId: string, opts: Record<string, unknown>) {
  if (!orderId) throw new Error("createDispatchFromOrder 需要 orderId");
  const newId = await generateId("D", "dispatch_orders");
  const now   = nowIso();
  const orderHeader = await getOrderHeader(orderId);

  const dispatch = {
    id: newId,
    date: String(opts.date || new Date().toLocaleDateString("zh-TW")),
    docCategory: "派工",
    docType: String(opts.docType || ""),
    source:  String(opts.source || ""),
    orderId,
    partnerCode: String(orderHeader?.customerCode || ""),
    partnerName: String(orderHeader?.customerName || ""),
    operator:    String(opts.operator || ""),
    machine:     String(opts.machine || ""),
    phase:       String(opts.phase || ""),
    receiveTime: now,
    status: "active",
    createdAt: now,
    updatedAt: now,
    estimatedPickQty: Number(opts.estimatedPickQty || 0),
    estimatedInQty:   Number(opts.estimatedInQty || 0),
    remark: String(opts.remark || ""),
    dispatchRemark: String(opts.dispatchRemark || ""),
  };

  const { error } = await supabase.from("dispatch_orders").insert(dispatch);
  if (error) throw error;

  // 把 orderId 下的裁切細項綁到這張派工單
  if (opts.linkCuttings !== false) {
    await supabase.from("cutting_details").update({ dispatchId: newId }).eq("orderId", orderId);
  }

  // 更新訂單狀態
  await supabase.from("orders").update({ status: "已派工", dispatchId: newId, updatedAt: now }).eq("id", orderId);

  return { ok: true, dispatchId: newId };
}

async function getDispatchHeader(dispatchId: string) {
  if (!dispatchId) return null;
  const { data } = await supabase.from("dispatch_orders").select("*").eq("id", dispatchId).single();
  return data || null;
}

async function getDispatchCoilMoves(dispatchId: string) {
  if (!dispatchId) return [];
  const { data } = await supabase.from("dispatch_coil_moves").select("*").eq("dispatchId", dispatchId).order("itemNo");
  return (data || []).map((r: Record<string, unknown>) => ({
    ...r, moveId: r.id, coilNo: r.coilNo || r.model || "",
    rollNo: r.originalRollNo || "", batchNo: r.outBatchNo || r.batchNo || "",
    srcWarehouse: r.outWarehouse || r.outLocation || "", srcLocation: r.outLocation || "",
  }));
}

async function getDispatchProduction(dispatchId: string) {
  if (!dispatchId) return [];
  const { data } = await supabase.from("dispatch_production").select("*").eq("dispatchId", dispatchId);
  return data || [];
}

async function getDispatchFull(dispatchId: string) {
  if (!dispatchId) return null;
  const [header, coilMoves, production] = await Promise.all([
    getDispatchHeader(dispatchId),
    getDispatchCoilMoves(dispatchId),
    getDispatchProduction(dispatchId),
  ]);
  return { header, coilMoves, production };
}

async function listDispatchIds() {
  const { data } = await supabase.from("dispatch_orders").select("id, date, orderId, machine, phase, status").order("id", { ascending: false });
  return data || [];
}

async function checkActiveDispatch(machine: string) {
  if (!machine) return null;
  const { data } = await supabase.from("dispatch_orders").select("*").eq("machine", machine).eq("status", "active").limit(1);
  return data?.[0] || null;
}

async function addCoilMove(dispatchId: string, coilMove: Record<string, unknown>) {
  if (!dispatchId) throw new Error("addCoilMove 需要 dispatchId");
  const newId = `CM${Date.now()}${Math.floor(Math.random() * 100)}`;
  const row = {
    ...coilMove, id: newId, dispatchId,
    createTime: nowLocalStr(),
  };
  const { error } = await supabase.from("dispatch_coil_moves").insert(row);
  if (error) throw error;

  // 從 batch_detail 扣庫
  if (coilMove.outBatchNo && coilMove.model) {
    await supabase.from("batch_detail")
      .update({
        qty:   supabase.rpc as unknown as number,
        total: supabase.rpc as unknown as number,
      })
      .eq("batchNo", coilMove.outBatchNo)
      .eq("model", coilMove.model);
    // 簡化版：直接用 raw SQL via rpc，或前端處理
  }

  return { ok: true, id: newId };
}

async function removeCoilMove(dispatchId: string, moveId: string) {
  const { error } = await supabase.from("dispatch_coil_moves").delete().eq("id", moveId).eq("dispatchId", dispatchId);
  if (error) throw error;
  return { ok: true };
}

async function updateCoilMoveUnloadWeight(dispatchId: string, moveId: string, unloadKg: number) {
  const { data } = await supabase.from("dispatch_coil_moves").select("loadWeight, qty").eq("id", moveId).single();
  if (!data) throw new Error("找不到 coilMove: " + moveId);
  const loadKg   = Number(data.loadWeight) || 0;
  const deductKg = loadKg > 0 ? Math.max(0, loadKg - unloadKg) : Number(data.qty);
  const { error } = await supabase.from("dispatch_coil_moves").update({ unloadWeight: unloadKg, qty: deductKg }).eq("id", moveId);
  if (error) throw error;
  return { ok: true, deductKg };
}

async function addLeftoverInbound(dispatchId: string, leftover: Record<string, unknown>) {
  const moveId = `LO${Date.now()}`;
  await supabase.from("stock_moves").insert({
    id: moveId, moveDate: new Date().toLocaleDateString("zh-TW"),
    moveType: "IN", refType: "LEFTOVER", refId: dispatchId,
    model: leftover.model, warehouse: leftover.inWarehouse, location: leftover.inLocation,
    qty: leftover.qty, total: leftover.total || leftover.weight, unit: leftover.unit,
    batchNo: leftover.batchNo, operator: leftover.operator, remark: leftover.remark,
  });
  return { ok: true };
}

async function closeDispatch(dispatchId: string, workHours: string) {
  if (!dispatchId) return { ok: false };
  const { error } = await supabase.from("dispatch_orders").update({
    status: "closed", workHours: workHours || "00:00:00", finishTime: nowLocalStr(), updatedAt: nowIso(),
  }).eq("id", dispatchId);
  if (error) throw error;
  return { ok: true };
}

async function endDispatch(dispatchId: string, opts: Record<string, unknown>) {
  if (!dispatchId) throw new Error("endDispatch 需要 dispatchId");

  // 1. 取派工單
  const dispatchHeader = await getDispatchHeader(dispatchId);
  if (!dispatchHeader) throw new Error(`找不到派工單: ${dispatchId}`);

  // 2. 生成回單 ID
  const returnId = `R${dispatchId}`;
  const now = nowIso();

  // 3. 取鋼捲上架明細
  const coilMoves = await getDispatchCoilMoves(dispatchId);

  // 4. 計算損耗率、總數
  const totalIn     = coilMoves.reduce((s: number, m: Record<string, unknown>) => s + (Number(m.qty) || 0), 0);
  const unloadTotal = Number(opts.unloadWeight || 0);
  const lossRate    = totalIn > 0 ? +((totalIn - unloadTotal) / totalIn * 100).toFixed(2) : 0;

  // 5. 建立派工回單
  const dispatchReturn = {
    id: returnId,
    dispatchId,
    date: new Date().toLocaleDateString("zh-TW"),
    docCategory: "回單",
    orderId: dispatchHeader.orderId,
    partnerCode: dispatchHeader.partnerCode,
    partnerName: dispatchHeader.partnerName,
    operator: dispatchHeader.operator,
    machine: dispatchHeader.machine,
    finishTime: String(opts.finishTime || nowLocalStr()),
    totalIn, totalDeduct: unloadTotal, lossRate,
    remark: String(opts.remark || ""),
    dispatchRemark: String(opts.dispatchRemark || ""),
    effectiveWorkHours: String(opts.workHours || ""),
    status: "closed",
    createdAt: now, updatedAt: now,
  };
  const { error: re } = await supabase.from("dispatch_returns").upsert(dispatchReturn, { onConflict: "id" });
  if (re) throw re;

  // 6. 建立派工回單扣庫明細
  for (const move of coilMoves) {
    const deductId = `DD${Date.now()}${Math.floor(Math.random() * 100)}`;
    await supabase.from("dispatch_return_deduct").insert({
      id: deductId, returnId, dispatchId,
      coilMoveId: move.id, model: move.model, batchNo: move.outBatchNo,
      warehouse: move.inWarehouse, location: move.inLocation,
      qty: move.qty, total: move.total, unit: move.unit,
      originalRollNo: move.originalRollNo, createdAt: now,
    });
    // 從產線倉扣庫
    await supabase.from("stock_moves").insert({
      id: `SM_DD_${deductId}`, moveDate: now.substring(0, 10),
      moveType: "OUT", refType: "DISPATCH_END", refId: returnId,
      model: move.model, batchNo: move.outBatchNo,
      warehouse: move.inWarehouse, location: move.inLocation,
      qty: move.qty, total: move.total, unit: move.unit,
    });
  }

  // 7. 結案派工單
  await closeDispatch(dispatchId, String(opts.workHours || ""));

  return { ok: true, returnId };
}

async function linkOrderCuttingsToDispatch(orderId: string, dispatchId: string) {
  const { error } = await supabase.from("cutting_details").update({ dispatchId }).eq("orderId", orderId);
  if (error) throw error;
  return { ok: true };
}

// ============================================================
// 7. 回報人員
// ============================================================
async function addReporterSession(dispatchId: string, reporters: string, opts: Record<string, unknown>) {
  const id = `RS${Date.now()}`;
  const now = nowIso();
  await supabase.from("dispatch_return_reporters").insert({
    id, dispatchId, reporters, machine: opts.machine || "",
    startTime: String(opts.startTime || nowLocalStr()),
    status: "active", createdAt: now, updatedAt: now,
  });
  return { ok: true, id };
}

async function pauseReporterSession(dispatchId: string, opts: Record<string, unknown>) {
  const endTime = String(opts.endTime || nowLocalStr());
  await supabase.from("dispatch_return_reporters")
    .update({ status: "paused", endTime, updatedAt: nowIso() })
    .eq("dispatchId", dispatchId).eq("status", "active");
  return { ok: true };
}

async function switchReporterSession(dispatchId: string, newReporters: string, opts: Record<string, unknown>) {
  await pauseReporterSession(dispatchId, opts);
  return await addReporterSession(dispatchId, newReporters, opts);
}

async function resumeReporterSession(dispatchId: string, reporters: string, opts: Record<string, unknown>) {
  return await addReporterSession(dispatchId, reporters, opts);
}

async function getReporterSessionsByDispatch(dispatchId: string) {
  const { data } = await supabase.from("dispatch_return_reporters").select("*").eq("dispatchId", dispatchId).order("createdAt");
  return data || [];
}

async function computeEffectiveWorkHours(dispatchId: string) {
  const sessions = await getReporterSessionsByDispatch(dispatchId);
  let totalSecs = 0;
  for (const s of sessions) {
    if (s.startTime && s.endTime) {
      const start = new Date(s.startTime).getTime();
      const end   = new Date(s.endTime).getTime();
      if (!isNaN(start) && !isNaN(end)) totalSecs += Math.max(0, (end - start) / 1000);
    }
  }
  const hh = Math.floor(totalSecs / 3600);
  const mm = Math.floor((totalSecs % 3600) / 60);
  const ss = Math.floor(totalSecs % 60);
  const result = `${String(hh).padStart(2,"0")}:${String(mm).padStart(2,"0")}:${String(ss).padStart(2,"0")}`;
  return { workHours: result };
}

// ============================================================
// 8. 派工回單
// ============================================================
async function listDispatchReturnIds() {
  const { data } = await supabase.from("dispatch_returns").select("id, date, dispatchId, machine, status").order("id", { ascending: false });
  return data || [];
}

async function getDispatchReturnFull(returnId: string) {
  if (!returnId) return null;
  const [header, items, deducts] = await Promise.all([
    supabase.from("dispatch_returns").select("*").eq("id", returnId).single(),
    supabase.from("dispatch_return_items").select("*").eq("returnId", returnId),
    supabase.from("dispatch_return_deduct").select("*").eq("returnId", returnId),
  ]);
  return { header: header.data, items: items.data || [], deducts: deducts.data || [] };
}

// ============================================================
// 9. 工具
// ============================================================
async function resetSimulationData() {
  const tables = ["labels", "dispatch_return_reporters", "dispatch_return_deduct",
                  "dispatch_return_items", "dispatch_returns", "dispatch_coil_moves",
                  "dispatch_production", "dispatch_orders"];
  for (const t of tables) {
    await supabase.from(t).delete().neq("id", "__none__");
  }
  // 還原庫存移動（只留進貨類）
  await supabase.from("stock_moves").delete().not("refType", "in", '("PURCHASE","PURCHASE_REVERSE")');
  // 還原訂單狀態
  await supabase.from("orders").update({ status: "待派工", dispatchId: "" }).eq("status", "已派工");
  // 還原裁切細項
  await supabase.from("cutting_details").update({
    dispatchId: "", dispatchSeq: "", topDone: 0, bottomDone: 0,
    closed: 0, startTime: "", finishTime: "", reporter: "", reportedAt: "",
    processNo: "", inboundNo: "", inLocation: "", inBatchNo: "",
  }).neq("id", "__none__");
  return { ok: true };
}

async function rebuildDispatchProductionSheet(dispatchId: string) {
  // 從 cutting_details 同步到 dispatch_production
  let q = supabase.from("cutting_details").select("*");
  if (dispatchId) q = q.eq("dispatchId", dispatchId);
  const { data: cuttings } = await q;
  if (!cuttings?.length) return { ok: true };

  for (const c of cuttings) {
    await supabase.from("dispatch_production").upsert({
      id: c.id, dispatchId: c.dispatchId, orderId: c.orderId,
      orderItemNo: c.orderItemNo, zone: c.zone, bundle: c.bundle,
      feet: c.feet, lengthMm: c.lengthMm, qty: c.qty,
      totalFeet: c.totalFeet, kg: c.kg,
      topUnfinish: c.topUnfinish, topDone: c.topDone,
      bottomUnfinish: c.bottomUnfinish, bottomDone: c.bottomDone,
      startTime: c.startTime, finishTime: c.finishTime,
      reporter: c.reporter, closed: c.closed,
    }, { onConflict: "id" });
  }
  return { ok: true };
}

// ============================================================
// HTTP 入口
// ============================================================
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = await req.json() as Record<string, unknown>;
    const action = String(body.action || "");
    if (!action) throw new Error("請提供 action 參數");

    const result = await router(action, body);
    return new Response(JSON.stringify({ ok: true, data: result }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ ok: false, error: msg }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
