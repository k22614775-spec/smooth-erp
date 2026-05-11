-- ================================================================
--  006_coil_tx_rls.sql
--  補上 coil_transactions 三張資料表的 RLS 及 anon 政策
--  （與其他資料表一致：ENABLE RLS + anon_all policy）
-- ================================================================

-- 1. 啟用 Row Level Security
ALTER TABLE coil_transactions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE coil_transaction_coils ENABLE ROW LEVEL SECURITY;
ALTER TABLE coil_transaction_items ENABLE ROW LEVEL SECURITY;

-- 2. 建立 anon_all 政策（允許 anon 及 service_role 全部操作）
CREATE POLICY "anon_all" ON coil_transactions
  FOR ALL TO anon, service_role USING (true) WITH CHECK (true);

CREATE POLICY "anon_all" ON coil_transaction_coils
  FOR ALL TO anon, service_role USING (true) WITH CHECK (true);

CREATE POLICY "anon_all" ON coil_transaction_items
  FOR ALL TO anon, service_role USING (true) WITH CHECK (true);

-- 3. 確保 anon 有 table-level 權限
GRANT ALL ON coil_transactions      TO anon, authenticated;
GRANT ALL ON coil_transaction_coils TO anon, authenticated;
GRANT ALL ON coil_transaction_items TO anon, authenticated;

-- 4. 通知 PostgREST 重新載入 schema cache
NOTIFY pgrst, 'reload schema';

-- ✅ 完成
