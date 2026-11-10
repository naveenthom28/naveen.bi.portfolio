-- =============================================================================
-- FICO Analysis page: how credit quality drives approval and booking
-- =============================================================================

SELECT
    b.fico_band_id,
    b.fico_band,
    b.score_range,
    COUNT(*)                                                        AS applications,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)              AS share_of_apps_pct,
    ROUND(100.0 * SUM(CASE WHEN f.decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                            AS approval_rate_pct,
    ROUND(100.0 * SUM(f.booked_flag)
          / NULLIF(SUM(CASE WHEN f.decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END), 0), 1)
                                                                    AS booking_rate_pct,
    ROUND(AVG(CASE WHEN f.booked_flag = 1 THEN f.approved_limit END), 0) AS avg_booked_limit
FROM fact_applications f
JOIN dim_fico_band b ON b.fico_band_id = f.fico_band_id
GROUP BY b.fico_band_id, b.fico_band, b.score_range
ORDER BY b.fico_band_id;


-- Approval rate by FICO band and product (matrix visual)
SELECT
    b.fico_band,
    p.product_name,
    ROUND(100.0 * SUM(CASE WHEN f.decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                            AS approval_rate_pct
FROM fact_applications f
JOIN dim_fico_band b ON b.fico_band_id = f.fico_band_id
JOIN dim_product   p ON p.product_id   = f.product_id
GROUP BY b.fico_band_id, b.fico_band, p.product_name
ORDER BY b.fico_band_id, p.product_name;
