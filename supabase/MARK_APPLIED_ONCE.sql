-- 一次性設定：標記既有 migration 為「已套用」，避免 Actions 重跑 001~020
CREATE TABLE IF NOT EXISTS _applied_migrations (name TEXT PRIMARY KEY, applied_at TIMESTAMPTZ DEFAULT now());
INSERT INTO _applied_migrations(name) VALUES
  ('001_schema.sql'),
  ('002_seed_data.sql'),
  ('003_fix_column_names.sql'),
  ('004_rpc_end_dispatch.sql'),
  ('005_coil_transactions.sql'),
  ('006_coil_tx_rls.sql'),
  ('007_label_report.sql'),
  ('008_pricing_type.sql'),
  ('009_pricing_tables.sql'),
  ('010_pricing_header.sql'),
  ('011_pricing_category_extras.sql'),
  ('012_pricing_versioning.sql'),
  ('013_order_price_audit.sql'),
  ('014_inventory_pricing_seed.sql'),
  ('015_restore_demo_order_items.sql'),
  ('016_order_items_legacy_fields.sql'),
  ('017_restore_demo_cuttings.sql'),
  ('018_itemno_padding.sql'),
  ('019_method_labels.sql'),
  ('020_machine_method.sql')
ON CONFLICT DO NOTHING;
