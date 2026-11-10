-- =============================================================================
-- Approval & Booking page: decision mix, conversion funnel, decline reasons,
-- channel and age-group performance
-- =============================================================================

-- 1. Conversion funnel: submitted -> approved -> booked
SELECT 'Submitted' AS stage, 1 AS stage_order, COUNT(*) AS applications FROM fact_applications
UNION ALL
SELECT 'Approved (incl. counteroffer)', 2, COUNT(*) FROM fact_applications
WHERE decision IN ('Approved', 'Counteroffer')
UNION ALL
SELECT 'Booked (account opened)', 3, SUM(booked_flag) FROM fact_applications
ORDER BY stage_order;


-- 2. Decision mix
SELECT
    decision,
    COUNT(*)                                                        AS applications,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)              AS share_pct
FROM fact_applications
GROUP BY decision
ORDER BY applications DESC;


-- 3. Top decline reasons (sample reasons, fictional)
SELECT
    decline_reason,
    COUNT(*)                                                        AS declines,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)              AS share_of_declines_pct
FROM fact_applications
WHERE decision = 'Declined'
GROUP BY decline_reason
ORDER BY declines DESC;


-- 4. Channel performance, year over year
SELECT
    c.channel_name,
    EXTRACT(YEAR FROM f.application_date)                           AS app_year,
    COUNT(*)                                                        AS applications,
    ROUND(100.0 * SUM(CASE WHEN f.decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                            AS approval_rate_pct,
    ROUND(100.0 * SUM(f.booked_flag)
          / NULLIF(SUM(CASE WHEN f.decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END), 0), 1)
                                                                    AS booking_rate_pct
FROM fact_applications f
JOIN dim_channel c ON c.channel_id = f.channel_id
GROUP BY c.channel_name, app_year
ORDER BY c.channel_name, app_year;


-- 5. Approval rate by age group
SELECT
    age_group,
    COUNT(*)                                                        AS applications,
    ROUND(100.0 * SUM(CASE WHEN decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                            AS approval_rate_pct
FROM fact_applications
GROUP BY age_group
ORDER BY age_group;
