# KPI Definitions

All KPIs are calculated from `fact_applications` (one row per credit card application).
DAX versions are in [`powerbi/measures.dax`](../powerbi/measures.dax); SQL versions are in [`sql/`](../sql).

| KPI | Definition | Formula | Why it matters to a card issuer |
|---|---|---|---|
| **Total Applications** | Credit card applications submitted in the period | `COUNT(application_id)` | Top-of-funnel demand; reflects marketing reach and brand pull |
| **Approval Rate** | Share of applications approved, including counteroffers | `(Approved + Counteroffer) / Total Applications` | Balances growth against credit risk appetite |
| **Straight Approval Rate** | Share approved at the requested credit limit | `Approved / Total Applications` | Shows how often applicants get what they asked for |
| **Counteroffer Share** | Share of approvals made at a lower limit than requested | `Counteroffer / (Approved + Counteroffer)` | Signals risk-based limit management and its effect on take-up |
| **Decline Rate** | Share of applications declined | `Declined / Total Applications` | Highlights targeting quality and lost demand |
| **Booking Rate** | Share of approved applications that became an open account | `Booked Accounts / (Approved + Counteroffer)` | Measures whether approved customers actually activate the card |
| **Application-to-Account Rate** | End-to-end conversion from application to open account | `Booked Accounts / Total Applications` | Single number for full-funnel efficiency |
| **Avg Approved Limit** | Average credit line on approved applications | `AVG(approved_limit)` where not declined | Indicates exposure per new account |
| **Avg FICO** | Average applicant credit score | `AVG(fico_score)` | Tracks the credit quality of incoming demand |
| **Applications MoM % / YoY %** | Change vs prior month / same period last year | `(Current - Prior) / Prior` | Separates real growth from seasonality |

## FICO bands used

| Band | Score range |
|---|---|
| Deep Subprime | 300-579 |
| Subprime | 580-619 |
| Near Prime | 620-659 |
| Prime | 660-719 |
| Prime Plus | 720-779 |
| Super Prime | 780-850 |

These are common industry-style credit tiers chosen for this fictional project.

## Offer types

| Offer type | Meaning |
|---|---|
| **Pre-Select** | Prospect was pre-screened and mailed a firm offer of credit |
| **ITA** (Invitation to Apply) | Prospect was invited to apply (email/digital) without pre-screening |
| **Partner Promo** | Application came through a co-brand or partner promotion |
| **Direct** | Customer applied on their own with no offer |

**Counteroffer** is a *decision outcome* (approved at a lower limit), not an offer type, so it is analyzed
inside every offer type on the Offer Performance page.
