-- ============================================================
-- 007_label_report.sql
-- 條碼標籤報工模組 - 跨訂單派工支援
-- ============================================================
-- 變更：
--   1. labels 表新增 dispatchId 欄位（標籤被哪張派工/報工單處理）
--   2. labels 表新增索引 idx_labels_dispatchId
--   3. 改造 end_dispatch RPC：
--      - 當派工的 orderId 為空時（=條碼標籤報工的跨訂單派工）
--        改用 labels.dispatchId = p_dispatch_id 來抓 dispatch_return_items
--      - 維持原有 CutApp 行為（dispatch.orderId 不為空時走原邏輯）
-- ============================================================

-- 1. labels 加 dispatchId 欄位（冪等）
ALTER TABLE labels ADD COLUMN IF NOT EXISTS "dispatchId" TEXT;
CREATE INDEX IF NOT EXISTS idx_labels_dispatchId ON labels ("dispatchId");

-- 2. PostgREST schema reload，確保前端立刻能查到新欄位
NOTIFY pgrst, 'reload schema';

-- 3. 改造 end_dispatch RPC
CREATE OR REPLACE FUNCTION end_dispatch(
  p_dispatch_id        TEXT,
  p_operator           TEXT    DEFAULT '',
  p_finish_time        TEXT    DEFAULT NULL,
  p_remark             TEXT    DEFAULT '',
  p_dispatch_remark    TEXT    DEFAULT '',
  p_work_hours         TEXT    DEFAULT '',
  p_coil_unload_weights JSONB  DEFAULT '{}'::JSONB
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_dispatch          RECORD;
  v_return_id         TEXT;
  v_now               TIMESTAMPTZ := NOW();
  v_date_str          TEXT        := TO_CHAR(NOW() AT TIME ZONE 'Asia/Taipei', 'YYYY/MM/DD');
  v_finish_time_str   TEXT;
  v_total_in          NUMERIC     := 0;
  v_coil_unload_kg    NUMERIC     := 0;
  v_leftover_kg       NUMERIC     := 0;
  v_total_deduct_kg   NUMERIC     := 0;
  v_loss_rate         NUMERIC     := 0;
  v_deduct_count      INT         := 0;
  v_move              RECORD;
  v_sm_id             TEXT;
  v_unload_kg         NUMERIC;
  v_load_kg           NUMERIC;
  v_deduct_kg         NUMERIC;
  v_dd_id             TEXT;
  v_prod              RECORD;
  v_lbl               RECORD;
  v_lo_sm             RECORD;
  v_item_id           TEXT;
  v_item_cnt          INT         := 0;
  v_label_cnt         INT         := 0;
  v_epoch             BIGINT;
  v_auto_wh           TEXT        := '';
  v_total_work_secs   NUMERIC     := 0;
  v_use_label_dispatch BOOLEAN    := FALSE;  -- 新增：判斷是否走「跨訂單標籤報工」分支
BEGIN
  SELECT * INTO v_dispatch FROM dispatch_orders WHERE id = p_dispatch_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', '找不到派工單: ' || p_dispatch_id);
  END IF;
  IF v_dispatch.status = 'closed' THEN
    RETURN jsonb_build_object('ok', false, 'error', '派工單已結案: ' || p_dispatch_id);
  END IF;

  -- 新增分支判斷：orderId 為空 → 走「條碼標籤報工」邏輯，用 labels.dispatchId 抓 items
  v_use_label_dispatch := (v_dispatch."orderId" IS NULL OR v_dispatch."orderId" = '');

  v_return_id       := 'R' || p_dispatch_id;
  v_finish_time_str := COALESCE(p_finish_time,
    TO_CHAR(NOW() AT TIME ZONE 'Asia/Taipei', 'YYYY/MM/DD HH24:MI:SS'));
  v_epoch           := EXTRACT(EPOCH FROM v_now)::BIGINT;

  -- [Fix C] 只更新下架磅重，不覆蓋 qty
  FOR v_move IN SELECT * FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id LOOP
    v_unload_kg := (p_coil_unload_weights ->> v_move.id)::NUMERIC;
    IF v_unload_kg IS NOT NULL THEN
      UPDATE dispatch_coil_moves SET "unloadWeight" = v_unload_kg
      WHERE id = v_move.id;
    END IF;
  END LOOP;

  SELECT COALESCE(SUM(COALESCE("loadWeight", total, 0)), 0) INTO v_total_in
    FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id;

  SELECT COALESCE(SUM(COALESCE("unloadWeight", 0)), 0) INTO v_coil_unload_kg
    FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id;

  SELECT COALESCE(SUM(COALESCE(total, qty, 0)), 0) INTO v_leftover_kg
    FROM stock_moves
    WHERE "refType" = 'LEFTOVER' AND "refId" = p_dispatch_id AND "moveType" = 'IN';

  v_total_deduct_kg := v_coil_unload_kg + v_leftover_kg;
  v_loss_rate := CASE
    WHEN v_total_in > 0 THEN ROUND(v_total_deduct_kg / v_total_in * 100, 2)
    ELSE 0 END;

  UPDATE dispatch_return_reporters
    SET status = 'closed', "endTime" = v_finish_time_str, "updatedAt" = v_now
  WHERE "dispatchId" = p_dispatch_id AND status = 'active';

  SELECT COALESCE(SUM(
    CASE WHEN status <> 'paused' AND "startTime" IS NOT NULL AND "endTime" IS NOT NULL
         THEN GREATEST(0, EXTRACT(EPOCH FROM (
                TO_TIMESTAMP("endTime", 'YYYY/MM/DD HH24:MI:SS') -
                TO_TIMESTAMP("startTime", 'YYYY/MM/DD HH24:MI:SS'))))
         ELSE 0 END), 0)
    INTO v_total_work_secs
    FROM dispatch_return_reporters WHERE "dispatchId" = p_dispatch_id;

  v_auto_wh := CASE
    WHEN v_total_work_secs > 0 THEN
      LPAD(FLOOR(v_total_work_secs/3600)::TEXT,2,'0')||':'||
      LPAD(FLOOR((v_total_work_secs%3600)/60)::TEXT,2,'0')||':'||
      LPAD(FLOOR(v_total_work_secs%60)::TEXT,2,'0')
    ELSE COALESCE(NULLIF(p_work_hours,''),'00:00:00') END;

  INSERT INTO dispatch_returns (
    id, "dispatchId", date, "docCategory",
    "orderId", "partnerCode", "partnerName",
    operator, machine, "finishTime",
    "totalIn", "totalDeduct", "lossRate",
    remark, "dispatchRemark", "effectiveWorkHours",
    status, "createdAt", "updatedAt"
  ) VALUES (
    v_return_id, p_dispatch_id, v_date_str, '回單',
    COALESCE(v_dispatch."orderId",''), v_dispatch."partnerCode", v_dispatch."partnerName",
    p_operator, v_dispatch.machine, v_finish_time_str,
    v_total_in, v_total_deduct_kg, v_loss_rate,
    p_remark, p_dispatch_remark, v_auto_wh,
    'closed', v_now, v_now
  )
  ON CONFLICT (id) DO UPDATE SET
    "totalIn"            = EXCLUDED."totalIn",
    "totalDeduct"        = EXCLUDED."totalDeduct",
    "lossRate"           = EXCLUDED."lossRate",
    "finishTime"         = EXCLUDED."finishTime",
    "effectiveWorkHours" = EXCLUDED."effectiveWorkHours",
    "updatedAt"          = v_now;

  -- [Fix A] 以 consumedKg 扣産線倉，section C 補扣産線倉歸回量
  FOR v_move IN SELECT * FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id LOOP
    v_dd_id := 'DD' || v_epoch::TEXT || v_deduct_count::TEXT;

    v_load_kg   := COALESCE(v_move."loadWeight", v_move.total, 0);
    v_unload_kg := COALESCE(v_move."unloadWeight", 0);
    v_deduct_kg := GREATEST(0, v_load_kg - v_unload_kg);

    INSERT INTO dispatch_return_deduct (
      id, "returnId", "dispatchId", "coilMoveId",
      model, "batchNo", warehouse, location,
      qty, total, unit, "originalRollNo",
      spec, "materialNo", "costBasis", "materialPrice",
      factory, formula, "unitWeight",
      color, paint, coating, strength, "furnaceNo", "dispatchSeq",
      "createdAt"
    ) VALUES (
      v_dd_id, v_return_id, p_dispatch_id, v_move.id,
      v_move.model, v_move."outBatchNo",
      COALESCE(v_move."inWarehouse",'產線倉'),
      COALESCE(v_move."inLocation",''),
      v_move.qty, v_deduct_kg, COALESCE(v_move.unit,'KG'),
      v_move."originalRollNo", v_move.spec,
      v_move."materialNo", v_move."costBasis", v_move."materialPrice",
      v_move.factory, v_move.formula, v_move."unitWeight",
      v_move.color, v_move.paint, v_move.coating, v_move.strength,
      v_move."furnaceNo", v_move."dispatchSeq", v_now
    ) ON CONFLICT DO NOTHING;

    v_sm_id := 'SM_DD_' || v_epoch::TEXT || v_deduct_count::TEXT;
    INSERT INTO stock_moves (
      id, "moveDate", "moveType", "refType", "refId",
      model, "batchNo", warehouse, location,
      qty, total, unit, "originalRollNo", operator, remark
    ) VALUES (
      v_sm_id, v_date_str, 'OUT', 'DISPATCH_END', v_return_id,
      v_move.model, v_move."outBatchNo",
      COALESCE(v_move."inWarehouse",'產線倉'),
      COALESCE(v_move."inLocation",''),
      v_move.qty, v_deduct_kg, COALESCE(v_move.unit,'KG'),
      COALESCE(v_move."originalRollNo",''), p_operator,
      '派工結束消耗扣庫（產線倉），派工單 ' || p_dispatch_id
    ) ON CONFLICT DO NOTHING;

    UPDATE warehouse_stock
      SET qty   = GREATEST(0, qty   - v_move.qty),
          total = GREATEST(0, total - v_deduct_kg),
          "moveDate" = v_date_str
    WHERE model = v_move.model
      AND "warehouseNo" = COALESCE(v_move."inWarehouse", '產線倉');

    UPDATE batch_detail
      SET qty   = GREATEST(0, qty   - v_move.qty),
          total = GREATEST(0, total - v_deduct_kg)
    WHERE model = v_move.model
      AND "warehouseNo" = COALESCE(v_move."inWarehouse", '產線倉')
      AND "batchNo" = COALESCE(v_move."outBatchNo", '');

    -- (C) 若有下架剩料，歸回鋼捲倉，並同步從産線倉扣除歸回量
    IF v_unload_kg > 0 THEN
      INSERT INTO stock_moves (
        id, "moveDate", "moveType", "refType", "refId",
        model, "batchNo", warehouse, location,
        qty, total, unit, "originalRollNo", operator, remark
      ) VALUES (
        'SM_RET_' || v_epoch::TEXT || v_deduct_count::TEXT,
        v_date_str, 'IN', 'DISPATCH_RETURN', v_return_id,
        v_move.model, COALESCE(v_move."outBatchNo",''),
        COALESCE(v_move."outWarehouse",'鋼捲倉'),
        COALESCE(v_move."outLocation",''),
        0, v_unload_kg, COALESCE(v_move.unit,'KG'),
        COALESCE(v_move."originalRollNo",''), p_operator,
        '派工剩料歸回鋼捲倉，回單 ' || v_return_id
      ) ON CONFLICT DO NOTHING;

      UPDATE warehouse_stock
        SET total = total + v_unload_kg,
            "moveDate" = v_date_str
      WHERE model = v_move.model
        AND "warehouseNo" = COALESCE(v_move."outWarehouse",'鋼捲倉');

      UPDATE batch_detail
        SET total = total + v_unload_kg
      WHERE model = v_move.model
        AND "warehouseNo" = COALESCE(v_move."outWarehouse",'鋼捲倉')
        AND "batchNo" = COALESCE(v_move."outBatchNo",'');

      INSERT INTO stock_moves (
        id, "moveDate", "moveType", "refType", "refId",
        model, "batchNo", warehouse, location,
        qty, total, unit, "originalRollNo", operator, remark
      ) VALUES (
        'SM_RET_OUT_' || v_epoch::TEXT || v_deduct_count::TEXT,
        v_date_str, 'OUT', 'DISPATCH_RETURN', v_return_id,
        v_move.model, COALESCE(v_move."outBatchNo",''),
        COALESCE(v_move."inWarehouse",'產線倉'),
        COALESCE(v_move."inLocation",''),
        0, v_unload_kg, COALESCE(v_move.unit,'KG'),
        COALESCE(v_move."originalRollNo",''), p_operator,
        '派工剩料從産線倉歸回鋼捲倉（重量調撥），回單 ' || v_return_id
      ) ON CONFLICT DO NOTHING;

      UPDATE warehouse_stock
        SET total = GREATEST(0, total - v_unload_kg),
            "moveDate" = v_date_str
      WHERE model = v_move.model
        AND "warehouseNo" = COALESCE(v_move."inWarehouse",'產線倉');

      UPDATE batch_detail
        SET total = GREATEST(0, total - v_unload_kg)
      WHERE model = v_move.model
        AND "warehouseNo" = COALESCE(v_move."inWarehouse",'產線倉')
        AND "batchNo" = COALESCE(v_move."outBatchNo",'');
    END IF;

    v_deduct_count := v_deduct_count + 1;
  END LOOP;

  v_item_cnt  := 0;
  v_label_cnt := 0;

  -- ★ 分支：條碼標籤報工（跨訂單）用 labels.dispatchId 抓
  --   原 CutApp 行為（dispatch.orderId 非空）用 labels.orderId = dispatch.orderId 抓
  IF v_use_label_dispatch THEN
    FOR v_lbl IN SELECT * FROM labels WHERE "dispatchId" = p_dispatch_id LOOP
      v_item_id := 'DRI' || v_epoch::TEXT || v_item_cnt::TEXT;
      INSERT INTO dispatch_return_items (
        id, "returnId", "dispatchId", "labelId", "labelNo",
        "orderId", "orderItemNo", machine, model, spec,
        qty, "totalLen", "totalWeight", unit,
        "startTime", "endTime", operator, remark
      ) VALUES (
        v_item_id, v_return_id, p_dispatch_id,
        v_lbl.id, v_lbl."labelNo",
        v_lbl."orderId", v_lbl."orderItemNo",
        COALESCE(v_lbl.machine, v_dispatch.machine), v_lbl.model, v_lbl.spec,
        v_lbl.qty, v_lbl."totalLen", v_lbl."totalWeight", v_lbl.unit,
        v_lbl."startTime", v_lbl."endTime", v_lbl.operator, v_lbl.remark
      ) ON CONFLICT DO NOTHING;
      v_item_cnt  := v_item_cnt  + 1;
      v_label_cnt := v_label_cnt + 1;
    END LOOP;
  ELSE
    FOR v_lbl IN SELECT * FROM labels WHERE "orderId" = v_dispatch."orderId" LOOP
      v_item_id := 'DRI' || v_epoch::TEXT || v_item_cnt::TEXT;
      INSERT INTO dispatch_return_items (
        id, "returnId", "dispatchId", "labelId", "labelNo",
        "orderId", "orderItemNo", machine, model, spec,
        qty, "totalLen", "totalWeight", unit,
        "startTime", "endTime", operator, remark
      ) VALUES (
        v_item_id, v_return_id, p_dispatch_id,
        v_lbl.id, v_lbl."labelNo",
        v_lbl."orderId", v_lbl."orderItemNo",
        v_lbl.machine, v_lbl.model, v_lbl.spec,
        v_lbl.qty, v_lbl."totalLen", v_lbl."totalWeight", v_lbl.unit,
        v_lbl."startTime", v_lbl."endTime", v_lbl.operator, v_lbl.remark
      ) ON CONFLICT DO NOTHING;
      v_item_cnt  := v_item_cnt  + 1;
      v_label_cnt := v_label_cnt + 1;
    END LOOP;

    -- 若沒有 labels，從 dispatch_production 抓（既有 CutApp 邏輯）
    IF v_label_cnt = 0 THEN
      FOR v_prod IN SELECT * FROM dispatch_production WHERE "dispatchId" = p_dispatch_id LOOP
        v_item_id := 'DRI' || v_epoch::TEXT || v_item_cnt::TEXT;
        INSERT INTO dispatch_return_items (
          id, "returnId", "dispatchId",
          "orderId", "orderItemNo", model, spec,
          qty, "totalLen", "totalWeight",
          "topDone", "bottomDone",
          "startTime", "endTime", operator,
          closed, "deliveryDate", "customerCode",
          "materialNo", factory, size,
          color, paint, coating, strength, category
        ) VALUES (
          v_item_id, v_return_id, p_dispatch_id,
          v_prod."orderId", v_prod."orderItemNo",
          v_prod.model, v_prod.spec,
          v_prod.qty,
          COALESCE(v_prod."totalFeet",0), COALESCE(v_prod.kg,0),
          COALESCE(v_prod."topDone",0), COALESCE(v_prod."bottomDone",0),
          v_prod."startTime", v_prod."finishTime",
          v_prod.reporter,
          COALESCE(v_prod.closed,0),
          v_prod."deliveryDate", v_prod."customerCode",
          v_prod."materialNo", v_prod.factory, v_prod.size,
          v_prod.color, v_prod.paint, v_prod.coating, v_prod.strength, v_prod.category
        ) ON CONFLICT DO NOTHING;
        v_item_cnt := v_item_cnt + 1;
      END LOOP;
    END IF;
  END IF;

  -- [Fix E] 餘料入庫明細：讀 stock_moves LEFTOVER 記錄，補入 dispatch_return_items
  SELECT * INTO v_lo_sm FROM stock_moves
  WHERE "refType" = 'LEFTOVER' AND "refId" = p_dispatch_id AND "moveType" = 'IN'
  ORDER BY id LIMIT 1;

  IF FOUND THEN
    INSERT INTO dispatch_return_items (
      id, "returnId", "dispatchId",
      "orderId", "orderItemNo",
      model, spec,
      qty, "totalLen", "totalWeight", unit,
      "startTime", "endTime", operator,
      remark, "inLocation", "inBatchNo", "originalRollNo"
    ) VALUES (
      'DRI_LO_' || v_epoch::TEXT,
      v_return_id, p_dispatch_id,
      COALESCE(v_dispatch."orderId",''), '',
      v_lo_sm.model, v_lo_sm.spec,
      COALESCE(v_lo_sm.qty,0), 0, COALESCE(v_lo_sm.total,0),
      COALESCE(v_lo_sm.unit,'KG'),
      v_finish_time_str, v_finish_time_str, p_operator,
      '剩料入庫（' || COALESCE(v_lo_sm.remark,'') || '）',
      COALESCE(v_lo_sm.location,''), COALESCE(v_lo_sm."batchNo",''),
      COALESCE(v_lo_sm."originalRollNo",'')
    ) ON CONFLICT (id) DO UPDATE SET
      "returnId" = EXCLUDED."returnId",
      "totalWeight" = EXCLUDED."totalWeight",
      remark = EXCLUDED.remark;
    v_item_cnt := v_item_cnt + 1;
  END IF;

  -- 結案派工
  UPDATE dispatch_orders
    SET status = 'closed',
        "finishTime" = v_finish_time_str,
        "workHours"  = v_auto_wh,
        "updatedAt"  = v_now
  WHERE id = p_dispatch_id;

  RETURN jsonb_build_object(
    'ok',           true,
    'returnId',     v_return_id,
    'itemCount',    v_item_cnt,
    'deductCount',  v_deduct_count,
    'totalIn',      v_total_in,
    'totalDeduct',  v_total_deduct_kg,
    'lossRate',     v_loss_rate,
    'workHours',    v_auto_wh,
    'useLabelDispatch', v_use_label_dispatch
  );
END;
$$;

NOTIFY pgrst, 'reload schema';
