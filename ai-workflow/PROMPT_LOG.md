# PROMPT_LOG.md — Online Retail Customer Analytics

**Project:** Online Retail Customer Analytics (UCI Online Retail dataset, 541,909 rows)
**Purpose of this log:** a complete record of the AI-assisted workflow used to
produce the files in this `ai-workflow/` folder. This log documents the workflow behind the AI skills listed in SKILLS_DEMONSTRATED.md: every prompt is shown, every iteration is shown, and every AI-generated number was checked against executed code before it was allowed to stay.

**How the workflow ran (human-in-the-loop):**
1. **Draft with AI** — prompts below asked the AI to generate hypotheses, narratives,
   and Excel formulas from a *summary* of the verified project outputs (never from raw
   data the AI couldn't see).
2. **Verify against executed code** — every figure was checked by re-running the
   project's own Python analysis (`python/analysis.py`) and small pandas checks, and
   cross-checked with the verified README figures.
3. **Correct and label** — anything the AI got wrong or hedged was fixed; corrected
   items are marked CONFIRMED / REFUTED / NUANCED in `ai-eda-hypotheses.md`, and all
   AI-drafted files carry the "AI-drafted, human-verified" label.
4. **Reuse** — the prompt templates at the bottom are reusable for any new dataset,
   with the verification checklist as the mandatory human-oversight gate.

---

## Prompt 1 — Generate EDA hypotheses

**Prompt used:**

> I have a verified analysis of the UCI Online Retail dataset (Dec 2010–Dec 2011,
> 541,909 invoice line items, 25,900 invoices, 4,372 customers, GBP). Verified facts:
> UK = 91.43% of transactions; top customer 14646 spent £279,489.02; 24.93% of rows
> have no CustomerID (133,600 of them in the UK); France return rate 1.74%
> (149/8,557); Thursday busiest weekday (103,857); November busiest month (84,711);
> February trough (27,707); top product DOT (postage) £206,245.50.
>
> Draft 7 testable EDA hypotheses a retail analyst would check next, phrased as
> falsifiable statements (e.g. "H4: ..."). For each, state the exact check that
> would confirm or refute it (metric + computation). Do NOT invent any numbers —
> mark every number you are unsure of as [TO VERIFY]. Keep each hypothesis to 3
> lines max.

**What the AI returned:** 7 hypotheses, most mapped cleanly to computable checks.
Two needed iteration (see below).

**Iteration 1 — pushed back on a vague hypothesis.** The AI's first H4 read:
"Weekend sales follow a typical consumer-retail pattern." I replied:

> Too vague to falsify. Rewrite H4 as a directional claim about weekday vs
> weekend transaction counts with the exact comparison to run, and add what a
> refutation would imply about the customer base (wholesale vs consumer).

Revised H4: *"Weekend transaction volume exceeds the weekday average
(consumer-retail pattern); check: mean(Sat,Sun) vs mean(Mon–Fri) transaction
counts."* — This was then **refuted** by the data (weekends are quiet;
Thursday leads), which correctly implies a wholesale buyer base.

**Iteration 2 — challenged the "December peak" assumption.** The AI's first H5
assumed December peaks (Christmas). I replied:

> Don't assume — the verified data says November (84,711) beat December
> (68,006). Rewrite H5 to explain that gap as the thing to investigate
> (pre-Christmas stocking vs December lull), not as a confirmation.

**Verification performed:**

| Hypothesis | Check run | Result |
|---|---|---|
| H1 UK concentration >85% | `analysis.py` output: UK 91.43% of transactions | CONFIRMED |
| H2 wholesale concentration | top customer £279,489.02 (README); pandas: top-10 customers = 17.3% of completed-sales revenue (£8,911,408 total) | CONFIRMED |
| H3 cancellations <2% | pandas: 1.71% of line items are credit notes; France 149/8,557 = 1.74% | CONFIRMED |
| H4 weekend > weekday | `analysis.py`: Thursday 103,857 top; weekends quietest | REFUTED → wholesale-pattern conclusion |
| H5 December peak month | `analysis.py`: Nov 84,711 > Oct 60,742 > Dec 2011 25,525 (partial month) | REFUTED as stated → NUANCED (Nov pre-Christmas stocking peak) |
| H6 missing IDs concentrated in UK | `analysis.py`: 133,600 of 135,080 missing IDs are UK | CONFIRMED |
| H7 midday peak / overnight dead | pandas hourly counts: busiest 12:00 (78,709); operating-hours trough at 20:00 GMT (871 transactions) | NUANCED — 06:00 (n=41) is a boundary artifact, not a real maintenance window |

**Correction the log must record:** the AI's first draft of H7 said "overnight
(00:00–06:00) is the quiet window — schedule maintenance then." Verification
showed 06:00's n=41 is a data-boundary artifact (dataset starts 2010-12-01
07:56). The honest, defensible window is **20:00 GMT** within operating
hours (871 transactions; corrected from 19:00 during QA review). This is exactly the kind of AI hallucination-risk the verification step
exists to catch.

---

## Prompt 2 — Draft the insight narrative

**Prompt used:**

> Using ONLY the verified figures below, draft a 400-word insight narrative for
> a retail operations manager. Figures: 541,909 line items / 25,900 invoices /
> 4,372 customers, Dec 2010–Dec 2011; UK 91.43% of transactions; six countries
> over £130k revenue (UK £8,187,806; Netherlands £284,662; EIRE £263,277;
> Germany £221,698; France £197,404; Australia £137,077); customer 14646
> £279,489.02; DOT postage £206,245.50; 24.93% missing CustomerID (133,600 UK);
> France returns 1.74% (149/8,557); Thursday 103,857 busiest; November 84,711
> peak, February 27,707 trough; RFM: 569 Champions, 28 Cannot-Lose-Them
> (avg £5,025 spend, 232 days since order), 627 At Risk; Dec-2010 cohort
> (885 customers) retains ~35–40% monthly with a 50.3% November spike.
>
> Rules: every sentence containing a number must use one of these figures
> exactly. No new numbers. No adjectives like "massive" without a figure
> attached. End with 3 prioritized recommendations. Flag any figure you had to
> guess as [UNVERIFIED].

**Iteration:** the AI's first draft wrote "customer 14646 (a Dutch wholesaler)".
I replied:

> You invented the customer's nationality — nothing in the data identifies it.
> Remove it. Never add attributes to an entity the data doesn't describe.

The AI removed it. Final narrative (`ai-insight-narrative.md`) contains zero
invented attributes; every number traces to the list above, re-checked against
the `analysis.py` re-run (all matched).

---

## Prompt 3 — Draft Excel KPI formulas

**Prompt used:**

> The retail CSV has columns: InvoiceNo, StockCode, Description, Quantity,
> InvoiceDate, UnitPrice, CustomerID, Country. Draft an Excel KPI pack:
> (1) return-rate formula, (2) UK revenue-share formula, (3) missing-CustomerID
> rate formula, (4) a nested-IF or XLOOKUP RFM-band formula sketch,
> (5) a one-paragraph KPI narration template with [placeholders] for the
> numbers. Use modern Excel functions (SUMIFS, COUNTIFS, XLOOKUP). Add a
> "validation" note per formula explaining how to check it against the Python
> outputs.

**Verification performed:** each formula was logic-checked by hand against the known-correct Python results (e.g., the return-rate formula must reproduce 1.71%; the UK-share formula must reproduce 91.43%). The validation notes state exactly which Python output each formula must match — that is the human-oversight gate for this artifact.

---

## Reusable prompt templates
**Templates designed for reuse on any new dataset**

**Template A — hypothesis generation:**
> I have a verified analysis of [DATASET]: [3–6 verified facts with numbers].
> Draft [N] falsifiable EDA hypotheses, each with the exact check (metric +
> computation) that would confirm or refute it. Do not invent numbers; mark
> unknowns [TO VERIFY].

**Template B — verified narrative:**
> Using ONLY these verified figures: [paste list]. Draft [length] for [audience].
> Every sentence with a number must use a figure from this list exactly. No new
> numbers, no invented attributes. End with [N] prioritized recommendations.

**Template C — verification checklist:**
- Every number in the AI draft traced to an executed-code output
- No invented attributes (nationality, names, causes) attached to entities
- At least one AI claim was challenged and either confirmed or corrected
- Boundary artifacts / edge cases sanity-checked (e.g., hour 06:00)
- File labeled "AI-drafted, human-verified" with the verification source named

---

## Post-hoc corrections (2026-10-06 QA review)

Corrections applied to the AI artifacts after re-verification against executed
outputs. The prompts above are preserved verbatim as the historical record;
what changed is documented here, not rewritten there.

1. **Customer count.** Prompts 1 and 2 stated 4,372 customers (the raw ID count).
   The analysis population is 4,339 customers with completed sales (33 IDs appear
   only in cancelled invoices). `ai-insight-narrative.md` now uses 4,339.

2. **RFM figures.** Prompt 2 fed the SQL RFM outputs (569 Champions, 28
   Cannot-Lose-Them, 627 At Risk). Per the project's provenance rule (one canonical
   engine per file), the narrative is standardized on the Python outputs: 557
   Champions, 25 Cannot Lose Them (avg £2,123, ~231 days), 618 At Risk (~3 orders,
   ~149 days). SQL figures remain the canonical source in `sql/` and are tagged
   (SQL) wherever they appear outside it.

3. **December aggregation.** `analysis.py` groups months by month number
   (`dt.month`), which combines Dec 2010 (42,481) and Dec 2011 (25,525) into 68,006.
   The narrative and H5 now use December 2011 alone (25,525, partial month ending
   Dec 9), verified by targeted pandas check. The one-line fix has been applied
   to `analysis.py` (year-month grouping) and the monthly chart regenerated.

4. **Return-rate leadership.** Prompt 1's facts and the narrative named France
   (1.74%) as the highest-return market. Re-verification across all countries with
   ≥1,000 transactions shows Australia highest at 5.88% (74 of 1,259).

5. **Maintenance window.** Corrected from 19:00 to **20:00 GMT** (871 transactions,
   the operating-hours minimum; 19:00 carries 3,705).
