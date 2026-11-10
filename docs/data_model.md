# Data Model

A simple **star schema**: one fact table of applications surrounded by small dimension tables.
Power BI uses single-direction, one-to-many relationships from each dimension to the fact table,
plus a DAX date table (`DimDate`) related on `application_date`.

```mermaid
erDiagram
    DIM_DATE      ||--o{ FACT_APPLICATIONS : "application_date"
    DIM_OFFER     ||--o{ FACT_APPLICATIONS : "offer_id"
    DIM_PRODUCT   ||--o{ FACT_APPLICATIONS : "product_id"
    DIM_CHANNEL   ||--o{ FACT_APPLICATIONS : "channel_id"
    DIM_FICO_BAND ||--o{ FACT_APPLICATIONS : "fico_band_id"

    FACT_APPLICATIONS {
        string  application_id PK
        date    application_date FK
        string  customer_id
        string  age_group
        int     product_id FK
        int     channel_id FK
        int     offer_id FK
        int     fico_score
        int     fico_band_id FK
        int     requested_limit
        string  decision "Approved / Counteroffer / Declined"
        date    decision_date
        int     approved_limit
        string  decline_reason
        int     booked_flag "1 = account opened"
        date    booked_date
    }
    DIM_DATE {
        date   Date PK
        int    Year
        int    Month_Number
        string Year_Month
        string Quarter
    }
    DIM_OFFER {
        int    offer_id PK
        string offer_name
        string offer_type "Pre-Select / ITA / Partner Promo / Direct"
        string offer_medium
    }
    DIM_PRODUCT {
        int    product_id PK
        string product_name "Cashback / Rewards / Travel / Secured"
        int    annual_fee
    }
    DIM_CHANNEL {
        int    channel_id PK
        string channel_name "Online / Mobile / Branch / Phone"
    }
    DIM_FICO_BAND {
        int    fico_band_id PK
        string fico_band
        string score_range
        int    min_score
        int    max_score
    }
```

## Design choices

- **Grain:** one row per application keeps every KPI additive and easy to slice.
- **Decision and booking on the same row:** the funnel (submitted → approved → booked) can be
  built with simple measures, no extra joins.
- **Dimensions are tiny and descriptive:** report filters show business-friendly names.
- **Date table in DAX:** enables month-over-month, year-over-year and rolling averages.
