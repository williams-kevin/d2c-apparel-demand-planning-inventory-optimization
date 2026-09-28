-- ==============================================================================
-- PROJECT 2: SCRIPT 06 - FINISHED CLOTHES INVENTORY POSITION & QUALITY AUDIT
-- ==============================================================================

DROP VIEW IF EXISTS view_finished_clothes_stock_audit;

CREATE VIEW view_finished_clothes_stock_audit AS
WITH transactional_flux AS (
    SELECT 
        LOWER(TRIM(product_sku)) AS clean_product_sku,
        SUM(
            CASE 
                WHEN LOWER(TRIM(action_type)) IN ('storage', 'inbound', 'stocking') THEN qty 
                WHEN LOWER(TRIM(action_type)) IN ('destocking', 'outbound', 'shipping', 'sale') THEN -qty 
                ELSE 0 
            END
        ) AS net_transactional_qty
    FROM finished_clothes_daily_log
    GROUP BY LOWER(TRIM(product_sku))
)
SELECT 
    TRIM(fci.product_sku) AS product_sku,
    fci.product_model,
    fci.product_name,
    fci.product_type,
    fci.fabric_sku,                          -- Corrected from fabric_name
    fci.stock_category,
    fci.size AS product_size,
    fci.height AS product_height_cm,
    
    -- PHYSICAL WAREHOUSE MAPPING
    fci.appartment,
    fci.room AS storage_room,
    fci.box AS container_box_id,
    
    -- INVENTORY QUALITY SEGMENTATION
    fci.product_quality,
    CASE 
        WHEN LOWER(TRIM(COALESCE(fci.product_quality, ''))) = 'first' THEN '✨ Premium (1st Quality)'
        WHEN LOWER(TRIM(COALESCE(fci.product_quality, ''))) = 'second' THEN '🔄 Repaired/Rework (2nd Quality Sale)'
        ELSE fci.product_quality
    END AS product_quality_segment,
    
    -- VOLUMETRIC POSITIONS (ON-HAND UNITS)
    COALESCE(fci.oh, 0) AS physical_stock_on_hand,
    COALESCE(tf.net_transactional_qty, 0) AS recent_flux_volume,
    
    -- TOTAL AVAILABLE UNIFIED UNITS FOR SALE
    ROUND(COALESCE(fci.oh, 0) + COALESCE(tf.net_transactional_qty, 0), 0) AS total_available_for_sale_units

FROM Finished_Clothes_Inventory fci
LEFT JOIN transactional_flux tf 
       ON LOWER(TRIM(fci.product_sku)) = tf.clean_product_sku;