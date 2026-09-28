-- ==============================================================================
-- PROJECT 2: DEMAND PLANNING & INVENTORY HEALTH PREDICTIVE ENGINE (DEDUPLICATED)
-- ------------------------------------------------------------------------------
-- Target: Build the master staging engine for fabrics, calculate precise daily 
-- consumption run rates, and project accurate Out-Of-Stock (OOS) timelines.
-- Baseline Reference Date Anchor: September 15, 2026
-- ==============================================================================

DROP VIEW IF EXISTS view_demand_planning_matrix;

CREATE VIEW view_demand_planning_matrix AS
WITH aggregated_fabric_stock AS (
    SELECT 
        TRIM(fabric_sku) AS fabric_sku,
        -- 📐 Consolidation de tout le stock disponible (ATS) par SKU unique
        SUM(COALESCE(ats, 0.0)) AS total_ats_meters
    FROM fabric_stock
    GROUP BY TRIM(fabric_sku)
),
fabric_consumption_run_rate AS (
    SELECT 
        TRIM(fabric_sku) AS fabric_sku,
        -- 📐 1. Aggregate global e-commerce demand (Shopify) and wholesale B2B business units
        SUM(qty_change) AS total_meters_consumed,
        
        -- 📐 2. Compute accurate average daily burn rate based on active historical footprint (243 days from Jan to Aug)
        ROUND(SUM(qty_change) / 243.0, 4) AS daily_consumption_run_rate
    FROM fabric_daily_log
    WHERE action_type IN ('Web orders', 'Wholesales Orders')
      AND qty_change > 0
    GROUP BY TRIM(fabric_sku)
),
logistics_in_transit AS (
    SELECT 
        TRIM(fabric_sku) AS fabric_sku,
        -- 📐 3. Nom exact de la colonne brute : total_meters_orderered
        SUM(total_meters_orderered) AS total_meters_in_transit,
        MIN(NULLIF("expected_delivery_(eta)", '')) AS next_delivery_eta
    FROM Procurement_Tracker
    WHERE ("expected_delivery_(eta)" >= '2026-09-15' OR "expected_delivery_(eta)" IS NULL OR "expected_delivery_(eta)" = '')
    GROUP BY TRIM(fabric_sku)
)
SELECT 
    afs.fabric_sku,
    
    -- INVENTORY TRACKING LEDGER CORE DIMENSIONS
    ROUND(afs.total_ats_meters, 2) AS current_ats_meters,
    COALESCE(lit.total_meters_in_transit, 0.0) AS meters_in_transit,
    lit.next_delivery_eta,
    COALESCE(crr.daily_consumption_run_rate, 0.0) AS avg_daily_burn_rate_meters,

    -- 📐 4. COMPUTE FORECASTED DAYS OF INVENTORY (DOI) TIMELINE COVERS ON CUMULATED ATS
    CASE 
        WHEN COALESCE(crr.daily_consumption_run_rate, 0.0) = 0.0 THEN 9999 -- Zero consumption implies infinite inventory safety buffer
        ELSE ROUND(afs.total_ats_meters / crr.daily_consumption_run_rate, 1)
    END AS days_of_inventory_doi,

    -- 📐 5. MATHEMATICAL ENGINE TO PROJECT ESTIMATED OUT-OF-STOCK (OOS) TIMESTAMPS FROM THE SEP 15, 2026 ANCHOR
    CASE 
        WHEN afs.total_ats_meters <= 0.0 THEN 'OUT OF STOCK (OOS)'
        WHEN COALESCE(crr.daily_consumption_run_rate, 0.0) = 0.0 THEN 'No Active Demand Service'
        ELSE DATE('2026-09-15', '+' || CAST(ROUND(afs.total_ats_meters / crr.daily_consumption_run_rate, 0) AS INTEGER) || ' days')
    END AS prospective_oos_date,

    -- 🎯 6. CHIRURGICAL INVENTORY HEALTH SEGMENTATION LAYER FOR CUSTOMER SERVICE ALERTING PIPELINES
    CASE 
        WHEN afs.total_ats_meters <= 0.0 THEN '🔴 ALERT: CRITICAL STOCKOUT'
        WHEN COALESCE(crr.daily_consumption_run_rate, 0.0) = 0.0 THEN '🟢 Healthy (No Active Demand)'
        WHEN (afs.total_ats_meters / crr.daily_consumption_run_rate) <= 30.0 AND COALESCE(lit.total_meters_in_transit, 0.0) = 0 THEN '🚨 CRITICAL: Stockout Risk < 30 Days'
        WHEN (afs.total_ats_meters / crr.daily_consumption_run_rate) <= 30.0 AND lit.total_meters_in_transit > 0 THEN '⚠️ WARNING: Buffer Breach (Supply in Transit)'
        WHEN (afs.total_ats_meters / crr.daily_consumption_run_rate) BETWEEN 30.1 AND 90.0 THEN '🟡 Safe Buffer'
        ELSE '🟢 Healthy (High Coverage)'
    END AS inventory_health_status

FROM aggregated_fabric_stock afs
LEFT JOIN fabric_consumption_run_rate crr ON afs.fabric_sku = crr.fabric_sku
LEFT JOIN logistics_in_transit lit ON afs.fabric_sku = lit.fabric_sku;