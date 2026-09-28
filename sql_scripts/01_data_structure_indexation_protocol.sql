-- ============================================================================
-- PROJECT 2: FABRIC DEMAND PLANNING - DATA STRUCTURE INDEXATION PROTOCOL
-- ============================================================================
-- Target: Build high-performance database indexes on foreign keys and filtered
-- columns to optimize execution time and secure downstream Looker Studio blends.
-- ============================================================================

-- 1. Optimizing fabric_daily_log for fast aggregation filtering
CREATE INDEX IF NOT EXISTS idx_fabric_daily_log_sku_action
ON fabric_daily_log (fabric_sku, action_type);

-- 2. Optimizing Procurement Tracker for chronological forecasting queries
-- (Utilisation de guillemets pour sécuriser la colonne avec parenthèses)
CREATE INDEX IF NOT EXISTS idx_procurement_tracker_sku_eta
ON "Procurement_Tracker" (fabric_sku, "expected_delivery_(eta)");

-- 3. Optimizing primary dimensions on the reference inventory table
CREATE INDEX IF NOT EXISTS idx_fabric_stock_sku
ON fabric_stock (fabric_sku);