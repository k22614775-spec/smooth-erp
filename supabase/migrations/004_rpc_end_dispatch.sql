-- ============================================================
--  RPC: end_dispatch
--  將 endDispatch 的多表異動封裝為單一 PostgreSQL 事務
--  前端只需一次呼叫，資料庫端保證原子性（BEGIN...COMMIT）
--
--  呼叫方式（前端）：
--    POST /rest/v1/rpc/end_dispatch
--    Body: {
--      "p_dispatch_id": "D1150509001",
--      "p_operator": "A01;A02",
--      "p_coil_unload_weights": {"CM123": 150, "CM456": 200},
--      "p_finish_time": "2026/05/09 17:30:00",   -- 可選
--      "p_remark": "",                             -- 可選
--      "p_dispatch_remark": "",                    -- 可選
--      "p_work_hours": "08:30:00"                  -- 可選
--    }
--
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
SECURITY DEFINER   -- 允許 anon key 呼叫（繞過 RLS，函式本身有邏輯保護）
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
  v_unload_kg         NUMERIC;
  v_load_kg           NUMERIC;
  v_deduct_kg         NUMERIC;
  v_dd_id             TEXT;
  -- 4b. 入庫明細相關
  v_prod              RECORD;
  v_lbl               RECORD;
  v_item_id           TEXT;
  v_item_cnt          INT         := 0;
  v_label_cnt         INT         := 0;
  v_epoch             BIGINT;
  -- 工時計算
  v_auto_wh           TEXT        := '';
  v_total_work_secs   NUMERIC     := 0;
BEGIN
  -- ── 0. 基本驗證 ──────────────────────────────────────────
  SELECT * INTO v_dispatch
    FROM dispatch_orders WHERE id = p_dispatch_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', '找不到派工單: ' || p_dispatch_id);
  END IF;

  IF v_dispatch.status = 'closed' THEN
    RETURN jsonb_build_object('ok', false, 'error', '派工單已結案: ' || p_dispatch_id);
  END IF;

  v_return_id       := 'R' || p_dispatch_id;
  v_finish_time_str := COALESCE(
    p_finish_time,
    TO_CHAR(NOW() AT TIME ZONE 'Asia/Taipei', 'YYYY/MM/DD HH24:MI:SS')
  );

  -- ── 1. 套用鋼捲下架磅重（coilUnloadWeights）──────────────
  FOR v_move IN
    SELECT * FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id
  LOOP
    v_unload_kg := (p_coil_unload_weights ->> v_move.id)::NUMERIC;
    IF v_unload_kg IS NOT NULL THEN
      v_load_kg   := COALESCE(v_move."loadWeight", v_move.total, 0);
      v_deduct_kg := CASE
        WHEN v_load_kg > 0 THEN GREATEST(0, v_load_kg - v_unload_kg)
        ELSE COALESCE(v_move.total, 0)
      END;
      UPDATE dispatch_coil_moves
        SET "unloadWeight" = v_unload_kg,
            qty            = v_deduct_kg
      WHERE id = v_move.id;
    END IF;
  END LOOP;

  -- ── 2. 計算合計重量 ──────────────────────────────────────
  -- 2a. 投入量：上架磅重合計
  SELECT COALESCE(SUM(COALESCE("loadWeight", total, 0)), 0)
    INTO v_total_in
    FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id;

  -- 2b. 鋼捲下架磅重合計（已更新的 unloadWeight）
  SELECT COALESCE(SUM(COALESCE("unloadWeight", 0)), 0)
    INTO v_coil_unload_kg
    FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id;

  -- 2c. 餘料入庫量（stock_moves LEFTOVER）
  SELECT COALESCE(SUM(COALESCE(total, qty, 0)), 0)
    INTO v_leftover_kg
    FROM stock_moves
    WHERE "refType" = 'LEFTOVER'
      AND "refId"   = p_dispatch_id
      AND "moveType" = 'IN';

  -- 2d. 合計退回量 & 損耗率
  v_total_deduct_kg := v_coil_unload_kg + v_leftover_kg;
  v_loss_rate := CASE
    WHEN v_total_in > 0 THEN ROUND(v_total_deduct_kg / v_total_in * 100, 2)
    ELSE 0
  END;

  -- ── 2e. 提前計算工時（必須在 INSERT dispatch_returns 前完成）──────
  -- 先關閉仍在 active 的 reporter session
  UPDATE dispatch_return_reporters
    SET status      = 'closed',
        "endTime"   = v_finish_time_str,
        "updatedAt" = v_now
  WHERE "dispatchId" = p_dispatch_id
    AND status = 'active';

  -- 計算非 paused sessions 的有效秒數
  SELECT COALESCE(SUM(
      CASE WHEN status <> 'paused'
               AND "startTime" IS NOT NULL
               AND "endTime"   IS NOT NULL
           THEN GREATEST(0,
                  EXTRACT(EPOCH FROM (
                    TO_TIMESTAMP("endTime",   'YYYY/MM/DD HH24:MI:SS') -
                    TO_TIMESTAMP("startTime", 'YYYY/MM/DD HH24:MI:SS')
                  )))
           ELSE 0
      END
    ), 0)
    INTO v_total_work_secs
    FROM dispatch_return_reporters
    WHERE "dispatchId" = p_dispatch_id;

  -- 格式化 HH:MM:SS
  v_auto_wh := CASE
    WHEN v_total_work_secs > 0 THEN
      LPAD(FLOOR(v_total_work_secs / 3600)::TEXT, 2, '0') || ':' ||
      LPAD(FLOOR((v_total_work_secs % 3600) / 60)::TEXT, 2, '0') || ':' ||
      LPAD(FLOOR(v_total_work_secs % 60)::TEXT, 2, '0')
    ELSE COALESCE(NULLIF(p_work_hours, ''), '00:00:00')
  END;

  -- ── 3. 建立派工回單頭 ────────────────────────────────────
  INSERT INTO dispatch_returns (
    id, "dispatchId", date, "docCategory",
    "orderId", "partnerCode", "partnerName",
    operator, machine,
    "finishTime", "totalIn", "totalDeduct", "lossRate",
    remark, "dispatchRemark", "effectiveWorkHours",
    status, "createdAt", "updatedAt"
  ) VALUES (
    v_return_id,
    p_dispatch_id,
    v_date_str,
    '回單',
    v_dispatch."orderId",
    v_dispatch."partnerCode",
    v_dispatch."partnerName",
    p_operator,
    v_dispatch.machine,
    v_finish_time_str,
    v_total_in,
    v_total_deduct_kg,
    v_loss_rate,
    p_remark,
    p_dispatch_remark,
    v_auto_wh,   -- 已在 Step 2e 計算完成的有效工時
    'closed',
    v_now,
    v_now
  )
  ON CONFLICT (id) DO UPDATE SET
    "totalIn"             = EXCLUDED."totalIn",
    "totalDeduct"         = EXCLUDED."totalDeduct",
    "lossRate"            = EXCLUDED."lossRate",
    "finishTime"          = EXCLUDED."finishTime",
    "effectiveWorkHours"  = EXCLUDED."effectiveWorkHours",
    "workHours"           = v_auto_wh,
    "updatedAt"           = v_now;

  -- ── 4. 建立扣庫明細 ──────────────────────────────────────
  FOR v_move IN
    SELECT * FROM dispatch_coil_moves WHERE "dispatchId" = p_dispatch_id
  LOOP
    v_dd_id := 'DD' || EXTRACT(EPOCH FROM v_now)::BIGINT::TEXT
                     || v_deduct_count::TEXT;

    INSERT INTO dispatch_return_deduct (
      id, "returnId", "dispatchId", "coilMoveId",
      model, "batchNo", warehouse, location,
      qty, total, unit, "originalRollNo",
      spec, "materialNo", "costBasis", "materialPrice",
      factory, formula, "unitWeight",
      color, paint, coating, strength,
      "furnaceNo", "dispatchSeq",
      "createdAt"
    ) VALUES (
      v_dd_id,
      v_return_id,
      p_dispatch_id,
      v_move.id,
      v_move.model,
      v_move."outBatchNo",
      v_move."inWarehouse",
      v_move."inLocation",
      v_move.qty,
      v_move.total,
      v_move.unit,
      v_move."originalRollNo",
      v_move.spec,
      v_move."materialNo",
      v_move."costBasis",
      v_move."materialPrice",
      v_move.factory,
      v_move.formula,
      v_move."unitWeight",
      v_move.color,
      v_move.paint,
      v_move.coating,
      v_move.strength,
      v_move."furnaceNo",
      v_move."dispatchSeq",
      v_now
    )
    ON CONFLICT DO NOTHING;

    v_deduct_count := v_deduct_count + 1;
  END LOOP;

  -- ── 4b. 建立入庫明細（dispatch_return_items）─────────────
  --   優先從 labels（MES 已報工標籤）建立
  --   若無標籤則從 dispatch_production（計劃入庫）建立，確保明細不空白
  v_item_cnt  := 0;
  v_label_cnt := 0;
  v_epoch     := EXTRACT(EPOCH FROM v_now)::BIGINT;

  -- Step A：從 labels 建立（labels 表無 dispatchId，以 orderId 查詢）
  FOR v_lbl IN
    SELECT * FROM labels WHERE "orderId" = v_dispatch."orderId"
  LOOP
    v_item_id := 'DRI' || v_epoch::TEXT || v_item_cnt::TEXT;
    INSERT INTO dispatch_return_items (
      id, "returnId", "dispatchId",
      "labelId", "labelNo",
      "orderId", "orderItemNo",
      machine, model, spec,
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

  -- Step B：無標籤時，從 dispatch_production 建立
  IF v_label_cnt = 0 THEN
    FOR v_prod IN
      SELECT * FROM dispatch_production WHERE "dispatchId" = p_dispatch_id
    LOOP
      v_item_id := 'DRI' || v_epoch::TEXT || v_item_cnt::TEXT;
      -- dispatch_return_items 用 endTime（不是 finishTime）
      INSERT INTO dispatch_return_items (
        id, "returnId", "dispatchId",
        "orderId", "orderItemNo",
        model, spec,
        qty, "totalLen", "totalWeight",
        "topDone", "bottomDone",
        "startTime", "endTime", operator,   -- reporter → operator（dispatch_return_items 無 reporter 欄）
        closed, "deliveryDate", "customerCode",
        "materialNo", factory, size,
        color, paint, coating, strength, category
      ) VALUES (
        v_item_id, v_return_id, p_dispatch_id,
        v_prod."orderId", v_prod."orderItemNo",
        v_prod.model, v_prod.spec,
        v_prod.qty,
        COALESCE(v_prod."totalFeet", 0),
        COALESCE(v_prod.kg, 0),
        COALESCE(v_prod."topDone", 0),
        COALESCE(v_prod."bottomDone", 0),
        v_prod."startTime",
        v_prod."finishTime",   -- dispatch_production.finishTime → dispatch_return_items.endTime
        v_prod.reporter,
        COALESCE(v_prod.closed, 0),
        v_prod."deliveryDate", v_prod."customerCode",
        v_prod."materialNo", v_prod.factory, v_prod.size,
        v_prod.color, v_prod.paint, v_prod.coating, v_prod.strength, v_prod.category
      ) ON CONFLICT DO NOTHING;
      v_item_cnt := v_item_cnt + 1;
    END LOOP;
  END IF;

  -- ── 5. 自動計算有效工時 + 結案派工單 ──────────────────────
  -- 5a. 關閉仍在 active 的 reporter session（寫入結束時間）
  UPDATE dispatch_return_reporters
    SET status      = 'closed',
        "endTime"   = v_finish_time_str,
        "updatedAt" = v_now
  WHERE "dispatchId" = p_dispatch_id
    AND status = 'active';

  -- 5b. 計算有效工時（非 paused sessions 的秒數合計 → HH:MM:SS）
  SELECT COALESCE(SUM(
      CASE WHEN status <> 'paused'
               AND "startTime" IS NOT NULL
               AND "endTime"   IS NOT NULL
           THEN GREATEST(0,
                  EXTRACT(EPOCH FROM (
                    TO_TIMESTAMP("endTime",   'YYYY/MM/DD HH24:MI:SS') -
                    TO_TIMESTAMP("startTime", 'YYYY/MM/DD HH24:MI:SS')
                  )))
           ELSE 0
      