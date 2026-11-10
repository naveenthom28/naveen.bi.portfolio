-- =============================================================================
-- Offer Performance page: applications, approvals, counteroffers and bookings
-- by marketing offer type
-- =============================================================================

SELECT
    o.offer_type,
    COUNT(*)                                                        AS applications,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)              AS share_of_apps_pct,
    ROUND(AVG(f.fico_score), 0)                                     AS avg_fico,
    ROUND(100.0 * SUM(CASE WHEN f.decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                            AS approval_rate_pct,
    ROUND(100.0 * SUM(CASE WHEN f.decision = 'Counteroffer' THEN 1 ELSE 0 END)
          / NULLIF(SUM(CASE WHEN f.decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END), 0), 1)
                                                                    AS counteroffer_share_pct,
    ROUND(100.0 * SUM(f.booked_flag)
          / NULLIF(SUM(CASE WHEN f.decision IN ('Approved', 'Counteroffer') THEN 1 ELSE 0 END), 0), 1)
                                                                    AS booking_rate_pct,
    SUM(f.booked_flag)                                              AS booked_accounts
FROM fact_applications f
JOIN dim_offer o ON o.offer_id = f.offer_id
GROUP BY o.offer_type
ORDER BY applications DESC;


-- Top individual offers by booked accounts
SELECT
    o.offer_name,
    o.offer_type,
    COUNT(*)                                                        AS applications,
    SUM(f.booked_flag)                                              AS booked_accounts,
    RANK() OVER (ORDER BY SUM(f.booked_flag) DESC)                  AS booking_rank
FROM fact_applications f
JOIN dim_offer o ON o.offer_id = f.offer_id
WHERE o.offer_type <> 'Direct'
GROUP BY o.offer_name, o.offer_type
ORDER BY booking_rank;
