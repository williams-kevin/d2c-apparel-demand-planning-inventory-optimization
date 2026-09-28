-- ==============================================================================
-- PROJECT 2: SCRIPT 04 - GLOBAL FABRIC INVENTORY BALANCE & ABSORPTION RATIOS
-- ------------------------------------------------------------------------------
-- Target: Calculate global consumption, total inventory ecosystem, and compute
-- stock absorption ratios with and without multimodal transit metrics.
-- ==============================================================================

DROP VIEW IF EXISTS view_global_fabric_inventory_balance;

CREATE VIEW view_global_fabric_inventory_balance AS
WITH aggregated_fabric_stock AS (
    SELECT 
        TRIM(fabric_sku) AS fabric_sku,
        -- 📐 Consolidation préalable du stock physique (ATS) par SKU unique
        SUM(COALESCE(ats, 0.0)) AS current_ats_stock
    FROM fabric_stock
    GROUP BY TRIM(fabric_sku)
),
fabric_aggregates AS (
    SELECT 
        TRIM(fabric_sku) AS fabric_sku,
        -- 📐 1. Global Consumption Level: Web orders + Wholesale orders
        SUM(qty_change) AS global_consumption_level
    FROM fabric_daily_log
    WHERE action_type IN ('Web orders', 'Wholesales Orders')
      AND qty_change > 0
    GROUP BY TRIM(fabric_sku)
),
logistics_aggregates AS (
    SELECT 
        TRIM(fabric_sku) AS fabric_sku,
        -- 📐 2. In-Transit Inventory Level: Procurement Tracker
        SUM(total_meters_orderered) AS in_transit_stock_level
    FROM Procurement_Tracker
    WHERE "expected_delivery_(eta)" >= '2026-09-15'
    GROUP BY TRIM(fabric_sku)
)
SELECT 
    afs.fabric_sku,
    
    -- CORE MATRIX VOLUMES (METERS)
    ROUND(COALESCE(fa.global_consumption_level, 0.0), 2) AS global_consumption_level,
    ROUND(afs.current_ats_stock, 2) AS current_ats_stock,
    COALESCE(la.in_transit_stock_level, 0.0) AS in_transit_stock_level,

    -- 📐 FORMULA 1: TOTAL ECOSYSTEM COVERAGE WITH IN-TRANSIT MATRICES
    -- (Global Consumption + ATS + Stock In-Transit)
    ROUND(
        COALESCE(fa.global_consumption_level, 0.0) + 
        ROUND(afs.current_ats_stock, 2) + 
        COALESCE(la.in_transit_stock_level, 0.0), 
        2
    ) AS total_ecosystem_with_transit,

    -- 📐 FORMULA 2: ASSET RUN BUFFER WITHOUT IN-TRANSIT METRIC
    -- (Global Consumption + ATS)
    ROUND(
        COALESCE(fa.global_consumption_level, 0.0) + 
        ROUND(afs.current_ats_stock, 2), 
        2
    ) AS total_ecosystem_without_transit,

    -- 📐 FORMULA 3: GLOBAL ABSORPTION RATIO WITH IN-TRANSIT STOCK (%)
    -- Global Consumption / (ATS + Global Consumption + Stock In-Transit)
    CASE 
        WHEN (COALESCE(fa.global_consumption_level, 0.0) + ROUND(afs.current_ats_stock, 2) + COALESCE(la.in_transit_stock_level, 0.0)) = 0.0 THEN 0.0
        ELSE ROUND(
            (COALESCE(fa.global_consumption_level, 0.0) / 
            (COALESCE(fa.global_consumption_level, 0.0) + ROUND(afs.current_ats_stock, 2) + COALESCE(la.in_transit_stock_level, 0.0))) * 100.0, 
            2
        )
    END AS absorption_ratio_with_transit_pct,

    -- 📐 FORMULA 4: GLOBAL ABSORPTION RATIO WITHOUT IN-TRANSIT STOCK (%)
    -- Global Consumption / (ATS + Global Consumption)
    CASE 
        WHEN (COALESCE(fa.global_consumption_level, 0.0) + ROUND(afs.current_ats_stock, 2)) = 0.0 THEN 0.0
        ELSE ROUND(
            (COALESCE(fa.global_consumption_level, 0.0) / 
            (COALESCE(fa.global_consumption_level, 0.0) + ROUND(afs.current_ats_stock, 2))) * 100.0, 
            2
        )
    END AS absorption_ratio_without_transit_pct

FROM aggregated_fabric_stock afs
LEFT JOIN fabric_aggregates fa ON afs.fabric_sku = fa.fabric_sku
LEFT JOIN logistics_aggregates la ON afs.fabric_sku = la.fabric_sku;