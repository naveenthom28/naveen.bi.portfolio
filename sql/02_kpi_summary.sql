-- =============================================================================
-- Landing page + Application Trends: headline KPIs and monthly trend
-- =============================================================================

-- 1. Headline KPIs for the whole period
SELECT
    COUNT(*)                                                        AS total_applications,
    SUM(CASE WHEN decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END) AS approved_applications,
    ROUND(100.0 * SUM(CASE WHEN decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                            AS approval_rate_pct,
    SUM(booked_flag)                                                AS booked_accounts,
    ROUND(100.0 * SUM(booked_flag)
          / NULLIF(SUM(CASE WHEN decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END), 0), 1)
                                                                    AS booking_rate_pct,
    ROUND(AVG(CASE WHEN booked_flag = 1 THEN approved_limit END), 0) AS avg_limit_booked
FROM fact_applications;


-- 2. Monthly trend with month-over-month and year-over-year change
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', application_date)                       AS app_month,
        COUNT(*)                                                    AS applications,
        SUM(CASE WHEN decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END) AS approved,
        SUM(booked_flag)                                            AS booked
    FROM fact_applications
    GROUP BY 1
)
SELECT
    app_month,
    applications,
    ROUND(100.0 * approved / applications, 1)                       AS approval_rate_pct,
    ROUND(100.0 * booked / NULLIF(approved, 0), 1)                  AS booking_rate_pct,
    ROUND(100.0 * (applications - LAG(applications, 1)  OVER (ORDER BY app_month))
          / LAG(applications, 1)  OVER (ORDER BY app_month), 1)      AS mom_change_pct,
    ROUND(100.0 * (applications - LAG(applications, 12) OVER (ORDER BY app_month))
          / LAG(applications, 12) OVER (ORDER BY app_month), 1)      AS yoy_change_pct
FROM monthly
ORDER BY app_month;


-- 3. Seasonality: average applications by calendar month across both years
SELECT
    EXTRACT(MONTH FROM application_date)                            AS month_num,
    COUNT(*) / COUNT(DISTINCT EXTRACT(YEAR FROM application_date))  AS avg_applications
FROM fact_applications
GROUP BY 1
ORDER BY 1;
