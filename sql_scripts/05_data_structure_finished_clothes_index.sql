-- ==============================================================================
-- PROJECT 2: FINISHED CLOTHES - DATA STRUCTURE INDEXATION PROTOCOL
-- ------------------------------------------------------------------------------
-- Target: Build structural database indexes on product SKUs, storage refs, 
-- and container IDs to accelerate inventory box queries and room mapping.
-- ==============================================================================

-- 1. Optimizing the Finished Clothes Inventory ledger
CREATE INDEX IF NOT EXISTS idx_finished_clothes_inv_sku 
ON Finished_Clothes_Inventory (product_sku);

CREATE INDEX IF NOT EXISTS idx_finished_clothes_inv_location 
ON Finished_Clothes_Inventory (room, box);

-- 2. Optimizing the Finished Clothes Daily Log transactional ledger
CREATE INDEX IF NOT EXISTS idx_finished_clothes_log_sku_action 
ON finished_clothes_daily_log (product_sku, action_type);
