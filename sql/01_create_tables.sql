-- =============================================================================
-- NBank Credit Card Application Trends - star schema
-- Fictional bank, fictional data. Standard SQL (tested in DuckDB; runs in
-- PostgreSQL, SQL Server or MySQL with minor type changes).
-- =============================================================================

CREATE TABLE dim_product (
    product_id      INTEGER PRIMARY KEY,
    product_name    VARCHAR(30),      -- Cashback, Rewards, Travel, Secured
    annual_fee      INTEGER
);

CREATE TABLE dim_channel (
    channel_id      INTEGER PRIMARY KEY,
    channel_name    VARCHAR(20)       -- Online, Mobile, Branch, Phone
);

CREATE TABLE dim_offer (
    offer_id        INTEGER PRIMARY KEY,
    offer_name      VARCHAR(50),
    offer_type      VARCHAR(20),      -- Pre-Select, ITA, Partner Promo, Direct
    offer_medium    VARCHAR(20)       -- Direct Mail, Email, Partner Site, Organic
);

CREATE TABLE dim_fico_band (
    fico_band_id    INTEGER PRIMARY KEY,
    fico_band       VARCHAR(20),      -- Deep Subprime ... Super Prime
    score_range     VARCHAR(10),
    min_score       INTEGER,
    max_score       INTEGER
);

CREATE TABLE fact_applications (
    application_id  VARCHAR(12) PRIMARY KEY,
    application_date DATE,
    customer_id     VARCHAR(10),
    age_group       VARCHAR(10),
    product_id      INTEGER REFERENCES dim_product (product_id),
    channel_id      INTEGER REFERENCES dim_channel (channel_id),
    offer_id        INTEGER REFERENCES dim_offer (offer_id),
    fico_score      INTEGER,
    fico_band_id    INTEGER REFERENCES dim_fico_band (fico_band_id),
    requested_limit INTEGER,
    decision        VARCHAR(15),      -- Approved, Counteroffer, Declined
    decision_date   DATE,
    approved_limit  INTEGER,
    decline_reason  VARCHAR(50),
    booked_flag     INTEGER,          -- 1 = account opened
    booked_date     DATE
);

-- Load the CSVs produced by data/generate_data.py with your database's bulk
-- loader (COPY in PostgreSQL / DuckDB, BULK INSERT in SQL Server,
-- LOAD DATA in MySQL). Example for DuckDB / PostgreSQL:
-- COPY dim_product       FROM 'data/dim_product.csv'       (HEADER);
-- COPY dim_channel       FROM 'data/dim_channel.csv'       (HEADER);
-- COPY dim_offer         FROM 'data/dim_offer.csv'         (HEADER);
-- COPY dim_fico_band     FROM 'data/dim_fico_band.csv'     (HEADER);
-- COPY fact_applications FROM 'data/fact_applications.csv' (HEADER);
