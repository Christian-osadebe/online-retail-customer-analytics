# AI-Drafted, Human-Verified: EDA Hypotheses — Online Retail

> **Label: AI-drafted, human-verified.** The hypotheses below were drafted by an AI
> assistant from a summary of verified project outputs (see `PROMPT_LOG.md` for the
> exact prompts and iterations). Every hypothesis was then tested against the real
> data by executing the project's own code (`python/analysis.py`)
> plus targeted pandas checks. Statuses are the *verification results*, not AI guesses.

> **Canonical engine: Python.** All figures below are Python outputs unless marked (SQL).

### H1 — Geographic concentration
**Hypothesis:** With over 85% of all transactions coming from the UK, the business is essentially domestic.
**Check:** share of transactions by country.
**Result: CONFIRMED.** UK = **91.43%** of transactions. Only Germany (1.75%),
France (1.58%) and EIRE (1.51%) individually exceed 1%.

### H2 — Wholesale value concentration
**Hypothesis:**Revenue is heavily concentrated among a few wholesale‑type customers, with the top buyer far above the median.
**Check:** top-customer spend; top-10 customers' share of completed-sales revenue.
**Result: CONFIRMED.** Customer **14646** alone accounts for **£279,489.02**. The top
10 customers (of 4,339) capture **17.3%** of completed-sales revenue (£8,911,408 total).
*Note: the data does not identify what kind of buyer 14646 is — no attributes were
invented.*

### H3 — Returns are negligible
**Hypothesis:**With credit notes below 2%, returns don’t impact margin.
**Check:** share of invoice numbers starting with `C`.
**Result: CONFIRMED.** **1.71%** of line items are cancellations. The highest rate among major markets
is Australia at **5.88%** (74 cancelled of 1,259); the UK sits at 1.59%, France at 1.74%.

### H4 — Weekend transaction peak (consumer-retail pattern)
**Hypothesis:** Weekend transaction volume exceeds the weekday average, as in
typical consumer retail.
**Check:** mean(Sat, Sun) vs mean(Mon–Fri) transaction counts.
**Result: REFUTED.** **Thursday (103,857)** is the busiest day, followed by Tuesday
(101,808); weekends are the quietest. **Interpretation:** the buyer base behaves
like wholesale (weekday) purchasers, not weekend consumers — adopt a B2B operating rhythm for marketing and staffing.

### H5 — December is the peak month
**Hypothesis:** December (Christmas) is the highest-volume month.
**Check:** transaction counts by month.
**Result: REFUTED as stated → NUANCED.** **November (84,711)** beats October (60,742) and December 2011 (**25,525**, a partial
month ending Dec 9); February is the trough (27,707). **Interpretation:**
the peak is *pre*-Christmas stocking in November — acquisition spend belongs in
September–November, not December.

### H6 — Guest-checkout data gap is a UK problem
**Hypothesis:** The 24.93% of rows with no CustomerID are concentrated in the UK,
so one market's checkout flow is the fix target.
**Check:** missing-CustomerID counts by country.
**Result: CONFIRMED.** **133,600** of the 135,080 rows with no CustomerID are UK
transactions (EIRE is next at 711). A quarter of UK sales can't be remarketed.

### H7 — Midday peak, overnight dead
**Hypothesis:** Transactions peak midday and fall to near zero overnight, giving a
clean overnight maintenance window.
**Check:** transaction counts by hour (GMT).
**Result: NUANCED.** Midday peak confirmed — **12:00 is busiest (78,709)**. But the
raw minimum at 06:00 (n=41) is a **data-boundary artifact** (the dataset starts
2010-12-01 07:56), not a real window. Within genuine operating hours, activity
bottoms out at **20:00 GMT** (871 transactions) — that is the defensible
maintenance window. *This correction is documented in `PROMPT_LOG.md` as an example
of an AI-suggested claim that verification caught.*

---

### Conclusion
Seven AI hypotheses: 3 confirmed, 2 refuted, 2 nuanced — the refutations produced the best insights. Value came from the verify‑everything loop.
