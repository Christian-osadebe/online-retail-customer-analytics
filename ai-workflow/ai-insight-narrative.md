# AI-Drafted, Human-Verified: Insight Narrative — Online Retail

> **Label: AI-drafted, human-verified.** Drafted by an AI assistant under a strict
> "use only these verified figures" instruction (see `PROMPT_LOG.md`, Prompt 2).
> Every number below was re-checked against the project's executed outputs
> (`python/analysis.py`; README verified figures). One invented
> attribute (a customer's nationality) was caught and removed during iteration.
>
> **Canonical engine: Python.** All figures below are Python outputs unless marked
> (SQL). Revenue is net (cancellations included as negatives); RFM and cohort
> figures use completed sales only.

---

A year of invoice data — **541,909 line items, 25,900 invoices, 4,339 customers**
from December 2010 to December 2011 — shows a UK gift retailer that is, in
practice, a domestic wholesaler with a thin export layer. The **UK is 91.43% of
transactions**; only Germany (1.75%), France (1.58%) and EIRE (1.51%) clear 1%
individually. Six countries clear £130,000 in revenue — the UK at **£8,187,806**,
then the Netherlands (£284,662), EIRE (£263,277), Germany (£221,698), France
(£197,404) and Australia (£137,077).

Value is concentrated in a few hands. Customer **14646 alone spent £279,489.02**,
and the single biggest "product" by revenue is **DOT (DOTCOM POSTAGE) at
£206,245.48** — delivery fees are a revenue line in their own right. The buying
rhythm is wholesale, not consumer: **Thursday (103,857 transactions)** is the
busiest day, weekends are quiet, and the annual peak lands in **November (84,711)** —
pre-Christmas stocking — ahead of December 2011 (**25,525**, a partial month ending Dec 9), with **February (27,707)** as
the trough.

Operations are healthy but leaky in one place. Returns are negligible — the highest rate among major markets is Australia at
**5.88% (74 of 1,259)**, with the UK at 1.59% and France at 1.74% — but
**24.93% of line items have no CustomerID**, and **133,600** of those are UK
transactions. A quarter of domestic sales cannot be tied to a customer for
retention marketing.

RFM segmentation (4,339 customers with completed purchases) sharpens the
retention picture: **557 Champions** are the core to protect, **25
"Cannot Lose Them"** customers average **£2,123** in spend but haven't ordered in
**~231 days** — the highest-value win-back targets in the base — and **618 At
Risk** customers (ordering ~3 times historically, ~149 days since last purchase)
are the broad win-back pool. Cohort behavior is wholesale-typical: the December
2010 cohort of **885 customers** holds **~35–40%** monthly activity with a
**50.3% November spike**.

**Three prioritized recommendations:**

1. **Win back the 25 Cannot-Lose-Them customers personally** — a call or tailored
   offer costs little against £2,123 average spend each.
2. **Fix UK guest checkout** — 133,600 unattributable transactions is the single
   biggest leak in the retention engine; even a modest account-creation incentive
   feeds RFM directly.
3. **Move acquisition spend to September–November** and treat February as the
   clearance window; schedule site maintenance at **20:00 GMT**, the operating-day
   activity minimum.

---

*Verification record: all 30+ figures above traced to `python/analysis.py` and the verified project README. No new numbers introduced; no customer or product attributes invented.*
