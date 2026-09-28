-- ==============================================================================
-- PROJECT 2: SCRIPT 07 - FINISHED CLOTHES DAILY DESTOCKING LEDGER (STRICT MAPPING)
-- ------------------------------------------------------------------------------
-- Target: Isolate and clean everyday outbound apparel transactions by filtering
-- strictly on 'Destocking' actions to track fulfillment velocity.
-- Baseline Reference Date Anchor: September 15, 2026
-- ==============================================================================

DROP VIEW IF EXISTS view_daily_finished_clothes_destocking_ledger;

CREATE VIEW view_daily_finished_clothes_destocking_ledger AS
SELECT 
    fcdl.date AS transaction_date,
    
    -- 📐 Extraction dynamique du mois en français à partir de la colonne date
    CASE strftime('%m', fcdl.date)
        WHEN '01' THEN 'Janvier'
        WHEN '02' THEN 'Février'
        WHEN '03' THEN 'Mars'
        WHEN '04' THEN 'Avril'
        WHEN '05' THEN 'Mai'
        WHEN '06' THEN 'Juin'
        WHEN '07' THEN 'Juillet'
        WHEN '08' THEN 'Août'
        WHEN '09' THEN 'Septembre'
        WHEN '10' THEN 'Octobre'
        WHEN '11' THEN 'Novembre'
        WHEN '12' THEN 'Décembre'
        ELSE strftime('%m', fcdl.date)
    END AS clean_month_fr,
    
    -- 📐 Extraction dynamique de l'année à partir de la colonne date
    CAST(strftime('%Y', fcdl.date) AS INTEGER) AS year,
    
    UPPER(TRIM(fcdl.product_sku)) AS product_sku,
    fci.product_name,
    fci.product_type,
    fci.fabric_sku,
    fci.size AS product_size,
    fci.height AS product_height_cm,
    
    -- PHYSICAL WAREHOUSE ORIGIN BIN MAPPING
    fci.appartment,
    fci.room AS storage_room,
    fci.box AS container_box_id,
    fci.product_quality,
    
    -- OUTBOUND TRANSACTION METRICS (STRICTLY ISOLATING DESTOCKING FLOWS)
    fcdl.action_type AS transaction_type,
    ROUND(ABS(fcdl.qty), 0) AS units_shipped

FROM finished_clothes_daily_log fcdl
-- Jointure sécurisée basée sur les SKUs nettoyés
LEFT JOIN Finished_Clothes_Inventory fci 
       ON UPPER(TRIM(fcdl.product_sku)) = UPPER(TRIM(fci.product_sku))
-- Filtre insensible à la casse sur l'action de destockage
WHERE LOWER(TRIM(fcdl.action_type)) = 'destocking'
  AND fcdl.qty IS NOT NULL
  AND fcdl.qty <> 0;