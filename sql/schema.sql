-- ============================================================================
-- online-retail-customer-analytics — schema + data load
-- ============================================================================
-- Run from the repository root:
--     psql -U postgres -d portfolio -f sql/schema.sql
--
-- What this script does
--   1. Drops the target table (re-runnable: a fresh run always starts clean).
--   2. Loads the raw CSV into a staging table where every column is TEXT,
--      so nothing is lost to type coercion on the way in.
--   3. Converts the US-style InvoiceDate strings (e.g. "12/1/2010 8:26")
--      to real TIMESTAMPs with TO_TIMESTAMP(..., 'MM/DD/YYYY HH24:MI')
--      and casts the remaining columns to their proper types.
--
-- Notes
--   * The CSV is saved from the repository root via the relative path
--     'data/Online_Retail.csv'.
--   * A few Description values contain a latin-1 pound sign,
--     so the copy runs with ENCODING 'latin1' and PostgreSQL converts it
--     to the database's UTF-8 on the way in.
-- ============================================================================

DROP TABLE IF EXISTS online_retail CASCADE;

-- ---------------------------------------------------------------------------
-- Staging table: everything as TEXT; parsing happens in the INSERT below.
-- ---------------------------------------------------------------------------
CREATE TABLE online_retail_stg (
    invoiceno       TEXT,
    stockcode       TEXT,
    description     TEXT,
    quantity        TEXT,
    invoicedate_raw TEXT,
    unitprice       TEXT,
    customerid      TEXT,
    country         TEXT
);

\copy online_retail_stg FROM 'data/Online_Retail.csv' WITH (FORMAT csv, HEADER true, ENCODING 'latin1')

-- ---------------------------------------------------------------------------
-- Final table: properly typed columns.
-- ---------------------------------------------------------------------------
CREATE TABLE online_retail (
    invoiceno   TEXT,
    stockcode   TEXT,
    description TEXT,
    quantity    NUMERIC,
    invoicedate TIMESTAMP,
    unitprice   NUMERIC,
    customerid  INTEGER,
    country     TEXT
);

INSERT INTO online_retail (invoiceno, stockcode, description, quantity,
                           invoicedate, unitprice, customerid, country)
SELECT
    NULLIF(TRIM(invoiceno), '')                                        AS invoiceno,
    NULLIF(TRIM(stockcode), '')                                        AS stockcode,
    NULLIF(description, '')                                            AS description,
    NULLIF(TRIM(quantity), '')::NUMERIC                                AS quantity,
    TO_TIMESTAMP(NULLIF(TRIM(invoicedate_raw), ''),
                 'MM/DD/YYYY HH24:MI')                                AS invoicedate,
    NULLIF(TRIM(unitprice), '')::NUMERIC                               AS unitprice,
    NULLIF(TRIM(customerid), '')::INTEGER                              AS customerid,
    NULLIF(TRIM(country), '')                                         AS country
FROM online_retail_stg;

DROP TABLE online_retail_stg;

-- ---------------------------------------------------------------------------
-- Sanity checks (output appears when the script runs).
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS total_rows FROM online_retail;
SELECT COUNT(*) AS missing_customerid
FROM online_retail
WHERE customerid IS NULL;
SELECT MIN(invoicedate) AS first_invoice,
       MAX(invoicedate) AS last_invoice
FROM online_retail;
