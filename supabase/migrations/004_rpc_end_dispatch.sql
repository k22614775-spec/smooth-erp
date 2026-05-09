-- ============================================================
--  RPC: end_dispatch  (完整乾淨版)
--  在 Supabase SQL Editor 執行此腳本一次即可
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
  -- 0. 基本驗證
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

  -- 1. 套用鋼捲下架磅重
  FOR v_move IN SELECT * FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id LOOP
    v_unload_kg := (p_coil_unload_weights ->> v_move.id)::NUMERIC;
    IF v_unload_kg IS NOT NULL THEN
      v_load_kg   := COALESCE(v_move."loadWeight", v_move.total, 0);
      v_deduct_kg := CASE
        WHEN v_load_kg > 0 THEN GREATEST(0, v_load_kg - v_unload_kg)
        ELSE COALESCE(v_move.total, 0) END;
      UPDATE dispatch_coil_moves SET "unloadWeight" = v_unload_kg, qty = v_deduct_kg
      WHERE id = v_move.id;
    END IF;
  END LOOP;

  -- 2a. 投入量
  SELECT COALESCE(SUM(COALESCE("loadWeight", total, 0)), 0) INTO v_total_in
    FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id;

  -- 2b. 下架磅重合計
  SELECT COALESCE(SUM(COALESCE("unloadWeight", 0)), 0) INTO v_coil_unload_kg
    FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id;

  -- 2c. 餘料入庫
  SELECT COALESCE(SUM(COALESCE(total, qty, 0)), 0) INTO v_leftover_kg
    FROM stock_moves
    WHERE "refType" = 'LEFTOVER' AND "refId" = p_dispatch_id AND "moveType" = 'IN';

  -- 2d. 退回量 & 損耗率
  v_total_deduct_kg := v_coil_unload_kg + v_leftover_kg;
  v_loss_rate := CASE
    WHEN v_total_in > 0 THEN ROUND(v_total_deduct_kg / v_total_in * 100, 2)
    ELSE 0 END;

  -- 2e. 關閉 active sessions + 計算工時（必須在 INSERT dispatch_returns 前）
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

  -- 3. 建立派工回單頭
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

  -- 4. 建立扣庫明細 + stock_moves OUT 產線倉
  FOR v_move IN SELECT * FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id LOOP
    v_dd_id := 'DD' || v_epoch::TEXT || v_deduct_count::TEXT;

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
      v_move.qty, v_move.total, COALESCE(v_move.unit,'KG'),
      v_move."originalRollNo", v_move.spec,
      v_move."materialNo", v_move."costBasis", v_move."materialPrice",
      v_move.factory, v_move.formula, v_move."unitWeight",
      v_move.color, v_move.paint, v_move.coating, v_move.strength,
      v_move."furnaceNo", v_move."dispatchSeq", v_now
    ) ON CONFLICT DO NOTHING;

    -- stock_moves：OUT 從產線倉（已消耗量）
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
      v_move.qty, v_move.total, COALESCE(v_move.unit,'KG'),
      COALESCE(v_move."originalRollNo",''), p_operator,
      '派工結束扣庫（產線倉），派工單 ' || p_dispatch_id
    ) ON CONFLICT DO NOTHING;

    v_deduct_count := v_deduct_count + 1;
  END LOOP;

  -- 4b. 入庫明細（優先 labels，無則用 dispatch_production）
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

  -- 5. 結案派工單
  UPDATE dispatch_orders
    SET status = 'closed', "workHours" = v_auto_wh,
        "finishTime" = v_finish_time_str, "updatedAt" = v_now
  WHERE id = p_dispatch_id;

  -- 5b. 回填 reporter returnId
  UPDATE dispatch_return_reporters
    SET "returnId" = v_return_id
  WHERE "dispatchId" = p_dispatch_id
    AND ("returnId" IS NULL OR "returnId" = '');

  -- 6. 回傳
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
