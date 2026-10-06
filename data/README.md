# Data

## Online_Retail.csv (45.6 MB)

The well-known **UCI Online Retail** dataset (Chen et al., donated to the UCI
Machine Learning Repository): every line item of every invoice issued by a
UK-based online gift retailer between **December 2010 and December 2011**.

* **541,909 rows**, 8 columns
* One row = one product line on one invoice

| Column | Type | Description |
|---|---|---|
| InvoiceNo | text | Invoice number; a leading `C` marks a cancelled (credit-note) transaction |
| StockCode | text | Product (item) code |
| Description | text | Product name |
| Quantity | numeric | Units on this line (negative for returns) |
| InvoiceDate | timestamp | Invoice date/time, e.g. `12/1/2010 8:26` (month/day/year hour:minute, GMT) |
| UnitPrice | numeric | Price per unit in GBP (£) |
| CustomerID | integer | Customer identifier; missing for ~25% of rows (guest checkouts) |
| Country | text | Customer's country |

### Notes for this project

* A few `Description` values contain a latin-1 pound sign (£, byte 0xA3), so the
  load scripts read the file with latin-1 encoding and convert to UTF-8.
* Currency throughout this project is **GBP (£)**.
* Source: https://archive.ics.uci.edu/dataset/352/online+retail
