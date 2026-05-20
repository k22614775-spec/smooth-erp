-- ============================================================

-- ============================================================

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
  v_item_id           TEXT;
  v_item_cnt          INT         := 0;
  v_label_cnt         INT         := 0;
  v_epoch             BIGINT;
  v_auto_wh           TEXT        := '';
  v_total_work_secs   NUMERIC     := 0;
BEGIN
  SELECT * INTO v_dispatch FROM dispatch_orders WHERE id = p_dispatch_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', '找不到派工單: ' || p_dispatch_id);
  END IF;
  IF v_dispatch.status = 'closed' THEN
    RETURN jsonb_build_object('ok', false, 'error', '派工單已結案: ' || p_dispatch_id);
  END IF;

  v_return_id       := 'R' || p_dispatch_id;
  v_finish_time_str := COALESCE(p_finish_time,
    TO_CHAR(NOW() AT TIME ZONE 'Asia/Taipei', 'YYYY/MM/DD HH24:MI:SS'));
  v_epoch           := EXTRACT(EPOCH FROM v_now)::BIGINT;

  -- [Fix C] 只更新下架磅重，不覆蓋 qty（qty 保留原件數 = 1件，避免顯示混亂）
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
    v_dispatch."orderId", v_dispatch."partnerCode", v_dispatch."partnerName",
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

  -- [Fix A] 第二迴圈：以 consumedKg 扣産線倉，section C 補扣産線倉歸回量
  FOR v_move IN SELECT * FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id LOOP
    v_dd_id := 'DD' || v_epoch::TEXT || v_deduct_count::TEXT;

    -- [Fix A] 計算實際消耗量 = 上架磅重 − 下架磅重
    v_load_kg   := COALESCE(v_move."loadWeight", v_move.total, 0);
    v_unload_kg := COALESCE(v_move."unloadWeight", 0);
    v_deduct_kg := GREATEST(0, v_load_kg - v_unload_kg);  -- consumedKg，例如 6000-5000=1000

    -- dispatch_return_deduct：qty=原件數(1)，total=consumedKg(1000)
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

    -- stock_moves OUT：産線倉消耗量離開
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

    -- (A) warehouse_stock：産線倉扣減消耗量（件數 -1，重量 -consumedKg）
    UPDATE warehouse_stock
      SET qty   = GREATEST(0, qty   - v_move.qty),
          total = GREATEST(0, total - v_deduct_kg),
          "moveDate" = v_date_str
    WHERE model = v_move.model
      AND "warehouseNo" = COALESCE(v_move."inWarehouse", '產線倉');

    -- (B) batch_detail：産線倉批號扣減消耗量
    UPDATE batch_detail
      SET qty   = GREATEST(0, qty   - v_move.qty),
          total = GREATEST(0, total - v_deduct_kg)
    WHERE model = v_move.model
      AND "warehouseNo" = COALESCE(v_move."inWarehouse", '產線倉')
      AND "batchNo" = COALESCE(v_move."outBatchNo", '');

    -- (C) 若有下架剩料，歸回鋼捲倉，並同步從産線倉扣除歸回量
    IF v_unload_kg > 0 THEN
      -- (C-1) stock_moves IN：鋼捲倉歸回剩料
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

      -- (C-1) warehouse_stock：鋼捲倉歸回剩料重量
      UPDATE warehouse_stock
        SET total = total + v_unload_kg,
            "moveDate" = v_date_str
      WHERE model = v_move.model
        AND "warehouseNo" = COALESCE(v_move."outWarehouse",'鋼捲倉');

      -- (C-1) batch_detail：鋼捲倉批號歸回
      UPDATE batch_detail
        SET total = total + v_unload_kg
      WHERE model = v_move.model
        AND "warehouseNo" = COALESCE(v_move."outWarehouse",'鋼捲倉')
        AND "batchNo" = COALESCE(v_move."outBatchNo",'');

      -- [Fix B] (C-2) stock_moves OUT：産線倉扣除歸回量（重量調撥，件數不動）
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

      -- [Fix B] (C-2) warehouse_stock：産線倉扣除歸回量（weight only）
      UPDATE warehouse_stock
        SET total = GREATEST(0, total - v_unload_kg),
            "moveDate" = v_date_str
      WHERE model = v_move.model
        AND "warehouseNo" = COALESCE(v_move."inWarehouse",'產線倉');

      -- [Fix B] (C-2) batch_detail：産線倉批號扣除歸回量
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

  UPDATE dispatch_orders
    SET status = 'closed', "workHours" = v_auto_wh,
        "finishTime" = v_finish_time_str, "updatedAt" = v_now
  WHERE id = p_dispatch_id;

  UPDATE dispatch_return_reporters
    SET "returnId" = v_return_id
  WHERE "dispatchId" = p_dispatch_id
    AND ("returnId" IS NULL OR "returnId" = '');

  RETURN jsonb_build_object(
    'ok', true, 'returnId', v_return_id,
    'deductCount', v_deduct_count,
    'totalIn', v_total_in, 'totalDeduct', v_total_deduct_kg,
    'lossRate', v_loss_rate, 'workHours', v_auto_wh
  );

EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('ok', false, 'error', SQLERRM, 'detail', SQLSTATE);
END;
$$;

GRANT EXECUTE ON FUNCTION end_dispatch TO anon, authenticated, service_role;
