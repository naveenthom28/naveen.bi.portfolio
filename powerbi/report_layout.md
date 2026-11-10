# Power BI Report Layout

Page-by-page design of the **NBank Credit Card Application Trends** report.
Every visual uses the measures in [`measures.dax`](measures.dax) and the star schema in
[`docs/data_model.md`](../docs/data_model.md).

**Global slicers (synced on every page):** Year · Month · Product · Channel · Offer Type
**Theme:** navy (`#1F3A5F`) for volume, teal (`#2A9D8F`) for rates, amber (`#E9A23B`) for highlights.

---

## 1. Landing Page — "How is the card application business doing?"

| Visual | Fields / measures |
|---|---|
| KPI cards | Total Applications · Approval Rate · Booking Rate · Booked Accounts · Avg Booked Limit |
| Column + line chart | Total Applications (columns) and Approval Rate (line) by Year-Month |
| Dynamic text card | `Trend Summary` measure |
| Small table | YoY % for applications, approval rate (pts) and booking rate (pts) |

## 2. Application Trends

| Visual | Fields / measures |
|---|---|
| Line chart | Total Applications by Month, one line per Year (seasonality overlay) |
| Column chart | Applications MoM % by Year-Month (conditional color: green up, red down) |
| Line chart | Applications YoY % by Year-Month |
| Stacked 100% column | Applications by Channel by Year (mobile shift) |

## 3. Offer Performance

| Visual | Fields / measures |
|---|---|
| Clustered bar | Approval Rate and Booking Rate by Offer Type |
| Donut | Total Applications by Offer Type |
| Table | Offer Type · Applications · Avg FICO · Approval Rate · Counteroffer Share · Booking Rate |
| Bar | Booked Accounts by Offer Name (top 10) |

## 4. FICO Analysis

| Visual | Fields / measures |
|---|---|
| Column chart | Total Applications by FICO Band (distribution) |
| Line + column | Approval Rate and Booking Rate by FICO Band |
| Matrix (heatmap) | Approval Rate by FICO Band (rows) × Product (columns) |
| Card | Share of approvals from Prime and above |

## 5. Approval & Booking Analysis

| Visual | Fields / measures |
|---|---|
| Funnel | Total Applications → Approved Applications → Booked Accounts |
| Donut | Decision mix (Approved / Counteroffer / Declined) |
| Bar | Declined Applications by Decline Reason |
| Clustered column | Booking Rate: Approved vs Counteroffer |
| Bar | Booking Rate by Channel |

## 6. Executive Summary

| Visual | Content |
|---|---|
| KPI strip | Headline KPIs with YoY change |
| Text boxes | Key findings, business observations, recommendations (see README) |
| Small multiples | Approval Rate by Offer Type over time |

---

Screenshots of each page will be saved in [`../screenshots`](../screenshots) once the report is built.
