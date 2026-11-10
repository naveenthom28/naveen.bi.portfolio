"""
Generate the fictional NBank credit card application dataset.

NBank is a made-up bank. Every row is randomly generated; no real customer,
company or system data is used. The script is seeded, so it always produces
the same numbers that appear in the README.

Output (CSV, in this folder):
    fact_applications.csv   one row per credit card application
    dim_offer.csv           marketing offers (Pre-Select, ITA, Partner Promo, Direct)
    dim_product.csv         card products
    dim_channel.csv         application channels
    dim_fico_band.csv       credit score segments
    sample_applications.csv first 50 applications (small preview for GitHub)

Run:
    pip install pandas numpy
    python data/generate_data.py
"""

import os
from datetime import date, timedelta

import numpy as np
import pandas as pd

SEED = 2024
N_APPS = 60_000
START, END = date(2024, 1, 1), date(2025, 12, 31)
OUT = os.path.dirname(os.path.abspath(__file__))

rng = np.random.default_rng(SEED)

# ---------------------------------------------------------------- dimensions
dim_product = pd.DataFrame({
    "product_id": [1, 2, 3, 4],
    "product_name": ["Cashback", "Rewards", "Travel", "Secured"],
    "annual_fee": [0, 0, 95, 0],
})

dim_channel = pd.DataFrame({
    "channel_id": [1, 2, 3, 4],
    "channel_name": ["Online", "Mobile", "Branch", "Phone"],
})

dim_fico_band = pd.DataFrame({
    "fico_band_id": [1, 2, 3, 4, 5, 6],
    "fico_band": ["Deep Subprime", "Subprime", "Near Prime", "Prime", "Prime Plus", "Super Prime"],
    "score_range": ["300-579", "580-619", "620-659", "660-719", "720-779", "780-850"],
    "min_score": [300, 580, 620, 660, 720, 780],
    "max_score": [579, 619, 659, 719, 779, 850],
})

offers = []
oid = 100
for offer_type, medium, count in [
    ("Pre-Select", "Direct Mail", 4),
    ("ITA", "Email", 4),
    ("Partner Promo", "Partner Site", 3),
    ("Direct", "Organic", 1),
]:
    for i in range(1, count + 1):
        oid += 1
        name = f"{offer_type} Offer {i}" if offer_type != "Direct" else "No Offer (Direct)"
        offers.append((oid, name, offer_type, medium))
dim_offer = pd.DataFrame(offers, columns=["offer_id", "offer_name", "offer_type", "offer_medium"])

# ---------------------------------------------------------------- dates with seasonality
days = pd.date_range(START, END, freq="D")
month_weight = {1: 0.82, 2: 0.92, 3: 1.08, 4: 1.06, 5: 0.98, 6: 0.95,
                7: 0.93, 8: 1.00, 9: 1.02, 10: 1.07, 11: 1.15, 12: 1.10}
w = np.array([month_weight[d.month] for d in days])
w = w * np.where(days.year == 2025, 1.09, 1.0)          # ~9% volume growth in 2025
w = w * np.where(days.dayofweek >= 5, 0.75, 1.0)          # quieter weekends
app_dates = rng.choice(days, size=N_APPS, p=w / w.sum())
app_dates = pd.to_datetime(np.sort(app_dates))

# ---------------------------------------------------------------- applicant attributes
year = app_dates.year.values

offer_type = rng.choice(["Pre-Select", "ITA", "Partner Promo", "Direct"],
                        size=N_APPS, p=[0.24, 0.18, 0.13, 0.45])

def pick_offer(t):
    ids = dim_offer.loc[dim_offer.offer_type == t, "offer_id"].values
    return rng.choice(ids)
offer_id = np.array([pick_offer(t) for t in offer_type])

# mobile share grows from 2024 to 2025
p_ch_2024 = [0.46, 0.30, 0.16, 0.08]
p_ch_2025 = [0.42, 0.38, 0.13, 0.07]
channel_id = np.where(
    year == 2024,
    rng.choice([1, 2, 3, 4], size=N_APPS, p=p_ch_2024),
    rng.choice([1, 2, 3, 4], size=N_APPS, p=p_ch_2025),
)

fico = rng.normal(690, 62, N_APPS)
fico += np.where(offer_type == "Pre-Select", 32, 0)      # pre-screened prospects score higher
fico += np.where(offer_type == "Partner Promo", 10, 0)
fico = np.clip(np.round(fico), 300, 850).astype(int)

product_id = np.where(
    fico < 600, rng.choice([4, 1], size=N_APPS, p=[0.7, 0.3]),
    rng.choice([1, 2, 3, 4], size=N_APPS, p=[0.42, 0.33, 0.20, 0.05]),
)

age_group = rng.choice(["18-24", "25-34", "35-44", "45-54", "55-64", "65+"],
                       size=N_APPS, p=[0.12, 0.27, 0.23, 0.17, 0.13, 0.08])

requested_limit = rng.choice([1000, 2500, 5000, 7500, 10000, 15000, 20000, 25000], size=N_APPS,
                             p=[0.08, 0.14, 0.22, 0.16, 0.18, 0.11, 0.07, 0.04])
requested_limit = np.where(product_id == 4, np.minimum(requested_limit, 2500), requested_limit)

# ---------------------------------------------------------------- underwriting decision
z = (fico - 655) / 28.0
z += np.where(offer_type == "Pre-Select", 0.55, 0)
z += np.where(offer_type == "ITA", 0.15, 0)
z += np.where(product_id == 4, 0.8, 0)                   # secured cards approve more easily
p_approve_any = 1 / (1 + np.exp(-z))
approved_any = rng.random(N_APPS) < p_approve_any

# counteroffers: approved, but at a lower limit than requested (more common in the middle bands)
p_counter = np.clip(0.30 - np.abs(fico - 665) / 400, 0.04, 0.30)
counter = approved_any & (rng.random(N_APPS) < p_counter) & (requested_limit > 1000)
decision = np.where(~approved_any, "Declined", np.where(counter, "Counteroffer", "Approved"))

approved_limit = np.where(decision == "Approved", requested_limit,
                  np.where(decision == "Counteroffer", (requested_limit * rng.uniform(0.4, 0.7, N_APPS) // 500 * 500).clip(500), 0)).astype(int)

reasons = ["Credit score below threshold", "High debt-to-income", "Recent delinquency",
           "Insufficient credit history", "Unable to verify income", "Too many recent inquiries"]
reason_p_low = [0.38, 0.18, 0.20, 0.12, 0.06, 0.06]
reason_p_mid = [0.10, 0.34, 0.12, 0.14, 0.14, 0.16]
decline_reason = np.where(
    decision != "Declined", "",
    np.where(fico < 620, rng.choice(reasons, size=N_APPS, p=reason_p_low),
             rng.choice(reasons, size=N_APPS, p=reason_p_mid)),
)

decision_days = np.clip(rng.gamma(1.6, 1.4, N_APPS).round(), 0, 14).astype(int)
decision_date = app_dates + pd.to_timedelta(decision_days, unit="D")

# ---------------------------------------------------------------- booking (account opened)
p_book = np.where(decision == "Approved", 0.80, np.where(decision == "Counteroffer", 0.52, 0.0))
p_book += np.where(offer_type == "Partner Promo", 0.07, 0)
p_book += np.where(offer_type == "Pre-Select", 0.03, 0)
p_book -= np.where(channel_id == 4, 0.05, 0)
p_book = np.where(decision == "Declined", 0.0, p_book)          # declined apps can never book
booked = rng.random(N_APPS) < np.clip(p_book, 0, 0.97)
book_days = rng.integers(1, 15, N_APPS)
booked_date = pd.Series(np.where(booked, (decision_date + pd.to_timedelta(book_days, unit="D")).strftime("%Y-%m-%d"), ""))

fico_band_id = np.searchsorted(dim_fico_band.min_score.values, fico, side="right")

fact = pd.DataFrame({
    "application_id": [f"APP{100000 + i}" for i in range(N_APPS)],
    "application_date": app_dates.strftime("%Y-%m-%d"),
    "customer_id": [f"C{n:07d}" for n in rng.choice(9_000_000, N_APPS, replace=False)],
    "age_group": age_group,
    "product_id": product_id,
    "channel_id": channel_id,
    "offer_id": offer_id,
    "fico_score": fico,
    "fico_band_id": fico_band_id,
    "requested_limit": requested_limit,
    "decision": decision,
    "decision_date": decision_date.strftime("%Y-%m-%d"),
    "approved_limit": approved_limit,
    "decline_reason": decline_reason,
    "booked_flag": booked.astype(int),
    "booked_date": booked_date,
})

for name, df in [("fact_applications", fact), ("dim_offer", dim_offer), ("dim_product", dim_product),
                 ("dim_channel", dim_channel), ("dim_fico_band", dim_fico_band)]:
    df.to_csv(os.path.join(OUT, f"{name}.csv"), index=False)
fact.head(50).to_csv(os.path.join(OUT, "sample_applications.csv"), index=False)

print(f"Wrote {len(fact):,} applications to {OUT}")
