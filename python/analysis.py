"""
Online Retail Customer Analytics — pandas analysis.

Mirrors SQL versions of this project:
  1. Data cleaning  (dates, transaction value, cancelled transactions,
                      missing CustomerID)
  2. Exploratory analysis (country mix, revenue by country, top customer,
                           top product, France return rate, weekday/month and
                           hourly patterns)
  3. RFM customer segmentation (Recency / Frequency / Monetary quintiles)

Run from the repository root:
    python3 python/analysis.py
Charts are written to python/charts/.
"""

import os

import matplotlib
matplotlib.use("Agg")  # headless: no display needed
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_PATH = os.path.join(ROOT, "data", "Online_Retail.csv")
CHART_DIR = os.path.join(ROOT, "python", "charts")
os.makedirs(CHART_DIR, exist_ok=True)

sns.set_theme(style="whitegrid")
plt.rcParams["figure.dpi"] = 120


# ----------------------------------------------------------------------------
# 1. Load + clean
# ----------------------------------------------------------------------------
# A few Description values contain a latin-1 pound sign, hence encoding="latin-1".
df = pd.read_csv(
    DATA_PATH,
    dtype={"InvoiceNo": str, "StockCode": str},
    encoding="latin-1",
)

# InvoiceDate like "12/1/2010 8:26" = month/day/year hour:minute (GMT).
df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"], format="%m/%d/%Y %H:%M", utc=True)

# One line-item's value in GBP.
df["TransactionValue"] = df["Quantity"] * df["UnitPrice"]

# Cancelled transactions carry an invoice number starting with "C"
# (the retailer's credit-note prefix).
df["Cancelled"] = df["InvoiceNo"].str.startswith("C")

print(f"Rows: {len(df):,} | Invoices: {df['InvoiceNo'].nunique():,} | "
      f"Date range: {df['InvoiceDate'].min().date()} to {df['InvoiceDate'].max().date()}\n"
      f"Cancelled transactions: {df['Cancelled'].sum():,}")

# ----------------------------------------------------------------------------
# 2a. Country mix — which countries drive transaction volume?
# ----------------------------------------------------------------------------
country = df["Country"].value_counts()
country_pct = (country / len(df) * 100).round(2)
big_countries = country_pct[country_pct > 1]
print("\nCountries with >1% of transactions:")
print(big_countries)

# ----------------------------------------------------------------------------
# 2b. Revenue by country — where does the money come from?
# ----------------------------------------------------------------------------
country_revenue = df.groupby("Country")["TransactionValue"].sum().sort_values(ascending=False)
big_revenue = country_revenue[country_revenue > 130_000]
print("\nCountries with revenue > £130,000:")
print(big_revenue.round(1))

# ----------------------------------------------------------------------------
# 2c. Missing-value rates
# ----------------------------------------------------------------------------
missing_pct = (df.isna().sum() / len(df) * 100).round(2)
print("\nMissing-value rates (%):")
print(missing_pct[missing_pct > 0])

# Missing CustomerID by country — the "guest checkout" pattern.
missing_cust = (
    df.loc[df["CustomerID"].isna(), "Country"].value_counts().head(9)
)
print("\nTransactions with missing CustomerID by country:")
print(missing_cust)

# ----------------------------------------------------------------------------
# 2d. Top customer and top product by total transaction value
# ----------------------------------------------------------------------------
known = df.dropna(subset=["CustomerID"])
top_customer = known.groupby("CustomerID")["TransactionValue"].sum()
cust_id, cust_value = top_customer.idxmax(), top_customer.max()
print(f"\nMost valuable customer: {cust_id:.0f} — £{cust_value:,.2f}")
print(f"Unique customers: {known['CustomerID'].nunique():,}")

top_product = df.groupby("StockCode")["TransactionValue"].sum()
prod_code, prod_value = top_product.idxmax(), top_product.max()
print(f"Top product by revenue: {prod_code} — £{prod_value:,.2f}")

# ----------------------------------------------------------------------------
# 2e. France return rate
# ----------------------------------------------------------------------------
fr = df[df["Country"] == "France"]
fr_cancelled = fr["Cancelled"].sum()
print(f"\nFrance: {len(fr):,} transactions, {fr_cancelled:,} cancelled "
      f"→ return rate {fr_cancelled / len(fr) * 100:.2f}%")

# ----------------------------------------------------------------------------
# 2f. Temporal patterns — weekday, month, hour of day
# ----------------------------------------------------------------------------
df["Weekday"] = df["InvoiceDate"].dt.strftime("%A")
df["Month"] = df["InvoiceDate"].dt.strftime('%Y-%m')
df["Hour"] = df["InvoiceDate"].dt.hour

weekday_order = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Sunday"]
weekday_counts = df["Weekday"].value_counts().reindex(weekday_order)
print("\nTransactions by weekday:")
print(weekday_counts)

month_counts = df["Month"].value_counts().sort_index()
print("\nTransactions by month:")
print(month_counts)

hour_counts = df["Hour"].value_counts().sort_index()
print("\nTransactions by hour (GMT):")
print(hour_counts)

# Date with the most transactions from Australia.
aus = df[df["Country"] == "Australia"]
aus_peak = aus["InvoiceDate"].dt.date.value_counts().idxmax()
print(f"\nAustralia peak transaction date: {aus_peak}")

# ----------------------------------------------------------------------------
# Charts
# ----------------------------------------------------------------------------
# 1. Germany transaction-value distribution.
fig, ax = plt.subplots(figsize=(9, 5))
ax.hist(df.loc[df["Country"] == "Germany", "TransactionValue"], bins=50, color="steelblue", edgecolor="white")
ax.set_title("Distribution of Transaction Values — Germany")
ax.set_xlabel("Transaction Value (£)")
ax.set_ylabel("Transactions")
fig.tight_layout()
fig.savefig(os.path.join(CHART_DIR, "germany_value_hist.png"))
plt.close(fig)

# 2. Hourly activity (maintenance-window chart).
fig, ax = plt.subplots(figsize=(9, 5))
ax.bar(hour_counts.index, hour_counts.values, color="steelblue")
ax.axvspan(18.5, 20.5, color="tomato", alpha=0.25, label="Suggested maintenance window")
ax.set_title("Transaction Activity by Hour of Day (GMT)")
ax.set_xlabel("Hour")
ax.set_ylabel("Transactions")
ax.legend()
fig.tight_layout()
fig.savefig(os.path.join(CHART_DIR, "hourly_activity.png"))
plt.close(fig)

# 3. Weekday transaction volume.
fig, ax = plt.subplots(figsize=(9, 5))
ax.bar(weekday_counts.index, weekday_counts.values, color="steelblue")
ax.set_title("Transaction Volume by Day of Week")
ax.set_ylabel("Transactions")
plt.setp(ax.get_xticklabels(), rotation=20, ha="right")
fig.tight_layout()
fig.savefig(os.path.join(CHART_DIR, "weekday_transactions.png"))
plt.close(fig)

# 4. Monthly transaction volume.
fig, ax = plt.subplots(figsize=(9, 5))
ax.bar(month_counts.index.astype(str), month_counts.values, color="steelblue")
ax.set_title("Transaction Volume by Month")
ax.set_xlabel("Month")
ax.set_ylabel("Transactions")
plt.setp(ax.get_xticklabels(), rotation=20, ha="right")
fig.tight_layout()
fig.savefig(os.path.join(CHART_DIR, "monthly_transactions.png"))
plt.close(fig)

# ----------------------------------------------------------------------------
# 3. RFM segmentation
#    Completed sales only (no cancellations), customers with a known ID.
#    Recency is measured against the latest invoice date in the data.
# ----------------------------------------------------------------------------
sales = df[~df["Cancelled"] & df["CustomerID"].notna() & (df["Quantity"] > 0)].copy()
max_date = sales["InvoiceDate"].max()

rfm = sales.groupby("CustomerID").agg(
    Recency=("InvoiceDate", lambda s: (max_date - s.max()).days),
    Frequency=("InvoiceNo", "nunique"),
    Monetary=("TransactionValue", "sum"),
).reset_index()

# Quintile scores: 5 = best. Recency is inverted (fewest days = 5).
rfm["R_score"] = pd.qcut(rfm["Recency"], 5, labels=[5, 4, 3, 2, 1]).astype(int)
rfm["F_score"] = pd.qcut(rfm["Frequency"].rank(method="first"), 5, labels=[1, 2, 3, 4, 5]).astype(int)
rfm["M_score"] = pd.qcut(rfm["Monetary"].rank(method="first"), 5, labels=[1, 2, 3, 4, 5]).astype(int)

def segment(row):
    r, f, m = row["R_score"], row["F_score"], row["M_score"]
    if r == 5 and f >= 4 and m >= 4:
        return "Champions"
    if r >= 4 and f >= 4:
        return "Loyal Customers"
    if r == 5 and f == 1:
        return "New Customers"
    if r >= 4 and (f <= 3 or m <= 3):
        return "Potential Loyalists"
    if r == 1 and f >= 4 and m >= 4:
        return "Cannot Lose Them"
    if r == 1 and f <= 2 and m <= 2:
        return "Lost"
    if r <= 2 and f >= 3:
        return "At Risk"
    if r <= 2 and f <= 2:
        return "Hibernating"
    return "Need Attention"

rfm["Segment"] = rfm.apply(segment, axis=1)

seg_summary = (
    rfm.groupby("Segment")
    .agg(customers=("CustomerID", "count"),
         avg_recency_days=("Recency", "mean"),
         avg_frequency=("Frequency", "mean"),
         avg_monetary_gbp=("Monetary", "mean"),
         total_monetary_gbp=("Monetary", "sum"))
    .round(2)
    .sort_values("total_monetary_gbp", ascending=False)
)
print("\nRFM segments:")
print(seg_summary)

fig, ax = plt.subplots(figsize=(10, 5))
seg_summary["customers"].sort_values().plot.barh(ax=ax, color="steelblue")
ax.set_title("Customer Count by RFM Segment")
ax.set_xlabel("Customers")
fig.tight_layout()
fig.savefig(os.path.join(CHART_DIR, "rfm_segments.png"))
plt.close(fig)

print(f"\nCharts written to {CHART_DIR}")
