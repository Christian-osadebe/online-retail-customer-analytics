# AI-Drafted, Human-Verified: Excel KPI Pack — Online Retail

> **Label: AI-drafted, human-verified (logic check).** Formulas drafted by an AI assistant
> (see PROMPT_LOG.md, Prompt 3), logic‑checked against verified Python outputs. The ‘Must equal’ line is the human‑oversight gate — paste real data and the
> cell must match.

> **Canonical engine: Python.** All 'Must equal' targets below are Python outputs;
> the one SQL figure is tagged (SQL).

Assumes the CSV is loaded into an Excel Table named `Retail` with columns
`InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice,
CustomerID, Country`, plus a helper column `TxnValue = [@Quantity]*[@UnitPrice]`
and `IsCancelled = LEFT([@InvoiceNo],1)="C"`.

### KPI 1 — Return (cancellation) rate
```excel
=COUNTIF(Retail[IsCancelled],TRUE)/ROWS(Retail)
```
Format as %. **Must equal 1.71%.**

### KPI 2 — UK share of transactions
```excel
=COUNTIF(Retail[Country],"United Kingdom")/ROWS(Retail)
```
Format as %. **Must equal 91.43%.**

### KPI 3 — Missing-CustomerID (guest checkout) rate
```excel
=COUNTBLANK(Retail[CustomerID])/ROWS(Retail)
```
Format as %. **Must equal 24.93%.**

### KPI 4 — Revenue by country (top export markets)
```excel
=SUMIFS(Retail[TxnValue],Retail[Country],"Netherlands")
```
Repeat per country. **Must equal:** Netherlands £284,662; EIRE £263,277;
Germany £221,698; France £197,404; Australia £137,077 (rounded to nearest £).

### KPI 5 — RFM band sketch (nested logic)
Recency in days lives in a customer summary table (`Cust` with `RecencyDays`,
`Frequency`, `Monetary`). Example band formula:
```excel
=XLOOKUP(TRUE,
  (Cust[RecencyDays]<=7)*(Cust[Frequency]>=10),
  "Champion",
  XLOOKUP(TRUE,(Cust[RecencyDays]>=200)*(Cust[Monetary]>=4000),
  "Cannot Lose Them","Other"))
```
**Validation:** the "Champion" count produced by the full rule set must be
reconcilable with (SQL: **569 Champions**); exact quintile
boundaries differ between NTILE implementations, so expect small shifts and
document them (see project README note on tie-breaking).

### KPI narration template (fill the [brackets] from verified outputs)
> This [month/quarter], [COUNTRY] drove [X]% of transactions and £[Y] revenue.
> Returns held at [Z]%, [above/below] the [T]% tolerance. Guest checkout was
> [W]% of rows ([N] unattributable transactions), [up/down] [P] pts vs last
> period. The top customer contributed £[V]; RFM shows [C] Champions and
> [R] At-Risk customers entering the win-back pool. Recommended action: [one
> sentence tied to the largest moving KPI].

*Validation rule for the template: every bracket must be filled from an
executed output (Python/SQL/cell above) — never from memory, never invented.
The [T]% tolerance is set by stakeholder policy, not by the data — record its source when filling.*
