-- ==============================================================================
-- PROJECT 2: SCRIPT 03 - DAILY FABRIC CONSUMPTION LOG WITH FRENCH MONTHS
-- ------------------------------------------------------------------------------
-- Target: Isolate everyday factory consumption outputs (Web, Wholesale, Samples, Waste)
-- and format date dimensions with corporate French month labels.
-- ==============================================================================

DROP VIEW IF EXISTS view_daily_fabric_consumption_logs;

CREATE VIEW view_daily_fabric_consumption_logs AS
SELECT 
    date AS raw_date,
    -- 📐 Conversion chirurgicale du mois SQL textuel en Français propre
    CASE month
        WHEN 'January' THEN 'Janvier'
        WHEN 'February' THEN 'Février'
        WHEN 'March' THEN 'Mars'
        WHEN 'April' THEN 'Avril'
        WHEN 'May' THEN 'Mai'
        WHEN 'June' THEN 'Juin'
        WHEN 'July' THEN 'Juillet'
        WHEN 'August' THEN 'Août'
        WHEN 'September' THEN 'Septembre'
        WHEN 'October' THEN 'Octobre'
        WHEN 'November' THEN 'Novembre'
        WHEN 'December' THEN 'Décembre'
        ELSE month
    END AS clean_month_fr,
    year,
    TRIM(fabric_sku) AS fabric_sku,
    status AS fabric_status,
    action_type AS consumption_type,
    -- On force la valeur positive pour l'affichage de la consommation pure
    ROUND(ABS(qty_change), 2) AS meters_consumed
FROM fabric_daily_log
WHERE action_type IN ('Web orders', 'Wholesales Orders', 'Sample', 'Waste/rework')
  AND qty_change <> 0;
