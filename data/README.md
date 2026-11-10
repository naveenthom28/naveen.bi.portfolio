# Sample Data

**NBank is a fictional bank. All data is randomly generated** by [`generate_data.py`](generate_data.py)
(seeded, so results are repeatable). No real customer, company or system data is used.

- **Period:** January 2024 – December 2025 (24 months)
- **Volume:** 60,000 credit card applications
- **Built-in patterns:** seasonality (January low, March and November–December peaks), ~9% volume
  growth in 2025, a shift from Online and Branch to Mobile, and approval odds driven by credit score
  and offer type

`sample_applications.csv` holds the first 50 rows so you can preview the data on GitHub.
Run the generator to create the full tables:

```bash
pip install pandas numpy
python data/generate_data.py
```

## fact_applications (one row per application)

| Column | Type | Description |
|---|---|---|
| application_id | text | Unique application ID (`APP100000`…) |
| application_date | date | Date the application was submitted |
| customer_id | text | Fictional applicant ID |
| age_group | text | 18-24, 25-34, 35-44, 45-54, 55-64, 65+ |
| product_id | int | Card product → `dim_product` |
| channel_id | int | Application channel → `dim_channel` |
| offer_id | int | Marketing offer → `dim_offer` |
| fico_score | int | Credit score at application (300-850) |
| fico_band_id | int | Credit tier → `dim_fico_band` |
| requested_limit | int | Credit line requested ($) |
| decision | text | Approved, Counteroffer (approved at a lower limit) or Declined |
| decision_date | date | Date of the credit decision |
| approved_limit | int | Credit line granted ($, 0 if declined) |
| decline_reason | text | Sample decline reason (blank if not declined) |
| booked_flag | int | 1 = applicant opened the account |
| booked_date | date | Date the account was opened |

## Dimension tables

| Table | Rows | Key columns |
|---|---|---|
| dim_offer | 12 | offer_id, offer_name, offer_type, offer_medium |
| dim_product | 4 | product_id, product_name, annual_fee |
| dim_channel | 4 | channel_id, channel_name |
| dim_fico_band | 6 | fico_band_id, fico_band, score_range, min_score, max_score |
