# Skill: Financial Extraction

> Stage 0 — Screening | Second skill in the pipeline
> Trigger: Data Triage is complete. You have an inventory, entity map, and know which PDFs to open.
> Output: Multi-sheet Excel workbook in BPEA format, tallied and cell-commented, ready for senior review.

---

## What This Skill Does

This is the most time-consuming skill in the entire deal process. You are taking numbers from messy Indian annual report PDFs — some digital, some scanned photocopies — and building a clean, tallied financial model in the standard BPEA format. The output is a workbook with one sheet per entity per basis (standalone/consolidated), covering 3-5 fiscal years.

Real timelines for context:
- Omsairam: 6 drafts over 5 weeks (April 4 to May 8). Started from the bank's CMA Excel, went through senior review cycles, added subsidiary sheets mid-way, final version was "Draft 6 Cleared" at 2.0 MB.
- DP Jain: Single evolving file. Experienced associate built it in one pass, then enriched during a screen-share where the manager dictated questions into a Comments column.
- Casablanca: DD-stage file had 28 sheets. Included a BPEA Assumptions sheet with a capacity model.

Expect 3-6 drafts before a file gets "Cleared." This is normal.

---

## Step 1: Set Up the Workbook

### Sheet Naming Convention

One sheet per entity per basis. Use this format:

```
[ShortName]_[Basis]
```

Examples:
- `OSAPL_Stdl` — Omsairam Alloys Standalone
- `OSAPL_Consol` — Omsairam Alloys Consolidated
- `SAPL_Stdl` — Shri Alloys Standalone
- `Summary` — Consolidated group view (built last)
- `Tally_Check` — Automated tally verification sheet
- `Comments` — Open questions log

### Column Layout

Every financial sheet follows the same column structure:

| Column | Content |
|--------|---------|
| A | Line item label |
| B | Sub-category / indent level |
| C | FY2020-21 |
| D | FY2021-22 |
| E | FY2022-23 |
| F | FY2023-24 |
| G | 9M FY2024-25 (Prov.) |
| H | Comments / Questions |
| I | Source reference (page number in PDF) |

**Column H is critical.** This is where you flag uncertainties, open questions, and items for senior review. Real example from DP Jain: the manager dictated comments during a screen-share — "Check if this includes excise", "Confirm if related party loan is secured", "Why did other income spike 3x in FY23?"

**Column I is your audit trail.** When a senior asks "where did this number come from?", you point to "AR FY23, p.47, Note 23." Do this from Draft 1. You will thank yourself later.

---

## Step 2: The BPEA P&L Format

This is the standard Profit & Loss structure. Every entity sheet follows this layout. Approximately 295 rows in a full template, but the core structure is below.

### Revenue

```
REVENUE FROM OPERATIONS
  Revenue from Sale of Products
    - Manufactured Goods
    - Traded Goods
  Revenue from Sale of Services
  Other Operating Revenue
    - Scrap Sales
    - Export Incentives (MEIS/RoDTEP)
    - Job Work Income
TOTAL REVENUE FROM OPERATIONS

Other Income
  - Interest Income
  - Dividend Income
  - Profit on Sale of Assets/Investments
  - Foreign Exchange Gain
  - Miscellaneous Income
TOTAL OTHER INCOME

TOTAL INCOME
```

### Expenses — Cost of Goods

```
COST OF MATERIALS CONSUMED
  Opening Stock of Raw Materials
  Add: Purchases
  Less: Closing Stock of Raw Materials
  = Raw Material Consumed

PURCHASE OF STOCK-IN-TRADE (Traded Goods)

CHANGES IN INVENTORIES
  Opening Stock (FG + WIP)
  Less: Closing Stock (FG + WIP)
  = Increase/(Decrease) in Inventories

STORES, SPARES & CONSUMABLES
```

**Critical note on Indian P&L structure**: Under Ind-AS / Schedule III, "Changes in Inventories" is an expense line, not netted against revenue. An increase in inventory (closing > opening) shows as a negative expense (i.e., reduces total expenses). This confuses people. Get the sign right.

### Expenses — Operating

```
EMPLOYEE BENEFIT EXPENSES
  Salaries & Wages
  Contribution to PF & ESI
  Staff Welfare
  Gratuity / Leave Encashment
  ESOP Cost (if applicable)

COMMISSION & BROKERAGE

OTHER EXPENSES (break this down from Notes to Accounts)
  Power & Fuel
  Rent
  Repairs & Maintenance
    - Plant & Machinery
    - Building
    - Others
  Insurance
  Rates & Taxes
  Legal & Professional Fees
  Auditor's Remuneration
  CSR Expenditure
  Bad Debts / Provision for Doubtful Debts
  Freight & Forwarding
  Travelling & Conveyance
  Communication
  Printing & Stationery
  Security
  Miscellaneous Expenses
TOTAL OTHER EXPENSES
```

### Profitability Metrics

```
GROSS PROFIT = Total Revenue from Operations - (RM Consumed + Traded Goods Purchase + Inventory Changes + Stores & Spares)
GROSS PROFIT MARGIN (%) = GP / Revenue from Operations

EBITDA = Gross Profit - (Employee Costs + Commission + Other Expenses)
EBITDA MARGIN (%) = EBITDA / Revenue from Operations

DEPRECIATION & AMORTIZATION
  - Depreciation on Tangible Assets
  - Amortization of Intangible Assets

EBIT = EBITDA - Depreciation

FINANCE COSTS
  Interest on Term Loans (Bank)
  Interest on Working Capital (Bank)
  Interest on Unsecured Loans / Related Party
  Interest on NCDs / Bonds
  [If BPEA is already a lender: Interest on BPEA NCDs — separate line]
  Processing Fees & Other Borrowing Costs
  Bank Charges
TOTAL FINANCE COSTS

PROFIT BEFORE EXCEPTIONAL ITEMS AND TAX = EBIT + Other Income - Finance Costs

EXCEPTIONAL ITEMS (list each — these are one-time)

PROFIT BEFORE TAX (PBT)

TAX EXPENSE
  Current Tax
  Deferred Tax
  MAT Credit (if applicable)
TOTAL TAX

PROFIT AFTER TAX (PAT)

OTHER COMPREHENSIVE INCOME (OCI)
  - Remeasurement of Defined Benefit Plans
  - Fair Value Changes on Equity Instruments
TOTAL COMPREHENSIVE INCOME
```

---

## Step 3: The BPEA Balance Sheet Format

### Assets

```
NON-CURRENT ASSETS
  Property, Plant & Equipment (Net Block)
    [Break down by asset class from notes: Land, Building, Plant & Machinery, etc.]
  Capital Work-in-Progress (CWIP)
  Right-of-Use Assets (Ind-AS 116)
  Intangible Assets
  Intangible Assets under Development
  Investments
    - In Subsidiaries / Associates
    - Other Investments
  Loans (Non-Current)
  Other Non-Current Financial Assets
  Deferred Tax Assets (Net)
  Other Non-Current Assets
    - Capital Advances
    - Prepaid Expenses (> 1 year)
TOTAL NON-CURRENT ASSETS

CURRENT ASSETS
  Inventories
    - Raw Materials
    - Work-in-Progress
    - Finished Goods
    - Stores & Spares
    - Stock-in-Trade
  Trade Receivables (Debtors)
    [Note: check ageing schedule in notes — critical for credit analysis]
  Cash and Cash Equivalents
    - Cash on Hand
    - Balances with Banks (Current Accounts)
    - Fixed Deposits (< 3 months)
  Bank Balances other than Cash (FDs > 3 months, margin money, earmarked)
  Loans (Current)
  Other Current Financial Assets
  Current Tax Assets (Advance Tax / TDS receivable)
  Other Current Assets
    - Advances to Suppliers
    - Prepaid Expenses
    - Balance with Revenue Authorities (GST Input Credit, Excise, Customs)
TOTAL CURRENT ASSETS

TOTAL ASSETS
```

### Liabilities

```
EQUITY
  Share Capital
    - Authorized
    - Issued, Subscribed & Paid-Up
    [Note: number of shares, face value, any preferential shares]
  Other Equity / Reserves & Surplus
    - Securities Premium
    - General Reserve
    - Retained Earnings
    - OCI Reserve
  Non-Controlling Interest (Consolidated only)
TOTAL EQUITY

NON-CURRENT LIABILITIES
  Long-Term Borrowings
    - Term Loans from Banks (Secured)
    - NCDs / Bonds
    - Unsecured Loans from Directors / Related Parties
    - Vehicle Loans / Equipment Finance
    [Break out each facility if possible — lender, amount, rate, maturity]
  Lease Liabilities (Non-Current)
  Other Non-Current Financial Liabilities
  Provisions (Non-Current)
    - Gratuity
    - Leave Encashment
  Deferred Tax Liabilities (Net)
  Other Non-Current Liabilities
TOTAL NON-CURRENT LIABILITIES

CURRENT LIABILITIES
  Short-Term Borrowings
    - Working Capital Loans / Cash Credit from Banks
    - Short-Term Loans from Related Parties
    - Current Maturities of Long-Term Debt (CMLTD)
    [IMPORTANT: CMLTD may be classified under "Other Current Financial Liabilities" under Ind-AS.
     Wherever the company puts it, always break it out separately in your model.]
  Trade Payables (Creditors)
    - Due to Micro & Small Enterprises (MSME)
    - Due to Others
  Lease Liabilities (Current)
  Other Current Financial Liabilities
    - Interest Accrued but Not Due
    - Unclaimed Dividends
    - CMLTD (if classified here)
  Other Current Liabilities
    - Advance from Customers
    - Statutory Dues (GST, TDS, PF, ESI payable)
  Provisions (Current)
    - Provision for Employee Benefits
    - Provision for Tax
TOTAL CURRENT LIABILITIES

TOTAL LIABILITIES

TOTAL EQUITY AND LIABILITIES
```

**The fundamental check**: Total Assets = Total Equity + Total Liabilities. Every year. No exceptions. If this doesn't balance, something is wrong with your extraction.

---

## Step 4: Cash Flow Statement

```
A. CASH FLOW FROM OPERATING ACTIVITIES
   Net Profit Before Tax (must match PBT from P&L)
   Adjustments for:
     + Depreciation & Amortization (must match P&L)
     + Finance Costs (must match P&L)
     - Interest Income
     - Dividend Income
     +/- (Profit)/Loss on Sale of Assets
     +/- Unrealized Foreign Exchange (Gain)/Loss
     + Provision for Doubtful Debts
     + Bad Debts Written Off
   Operating Profit Before Working Capital Changes

   Working Capital Adjustments:
     +/- (Increase)/Decrease in Trade Receivables
     +/- (Increase)/Decrease in Inventories
     +/- (Increase)/Decrease in Other Current Assets
     +/- Increase/(Decrease) in Trade Payables
     +/- Increase/(Decrease) in Other Current Liabilities
     +/- Increase/(Decrease) in Provisions
   Cash Generated from Operations

   Less: Direct Taxes Paid (net of refunds)
   NET CASH FROM OPERATING ACTIVITIES (A)

B. CASH FLOW FROM INVESTING ACTIVITIES
   - Purchase of PPE / CWIP
   + Proceeds from Sale of PPE
   - Purchase of Investments
   + Proceeds from Sale of Investments
   - Fixed Deposits Placed
   + Fixed Deposits Matured
   + Interest Received
   + Dividends Received
   NET CASH FROM INVESTING ACTIVITIES (B)

C. CASH FLOW FROM FINANCING ACTIVITIES
   + Proceeds from Issuance of Share Capital
   + Proceeds from Long-Term Borrowings
   - Repayment of Long-Term Borrowings
   + Net Increase/(Decrease) in Short-Term Borrowings
   - Repayment of Lease Liabilities
   - Interest Paid (Finance Costs)
   - Dividends Paid
   - Dividend Distribution Tax (pre-FY21)
   NET CASH FROM FINANCING ACTIVITIES (C)

NET INCREASE/(DECREASE) IN CASH = A + B + C

OPENING CASH AND CASH EQUIVALENTS
CLOSING CASH AND CASH EQUIVALENTS
```

---

## Step 5: Notes-to-Accounts Enrichment

The face of the P&L and BS gives you summary numbers. The real intelligence is in the notes. For each major line item, go into the notes and break it down.

### Priority Notes to Extract

| Line Item | What to Pull from Notes | Why It Matters |
|-----------|------------------------|----------------|
| **Revenue** | Product-wise / segment-wise breakup | Concentration risk. Is 80% revenue from one product? |
| **Trade Receivables** | Ageing schedule (< 6 months, 6-12 months, > 1 year) | Collection efficiency. Old receivables = potential write-offs. |
| **Inventories** | Breakup by type (RM, WIP, FG). Any write-downs? | Working capital cycle. Obsolescence risk. |
| **Borrowings** | Lender-wise detail: bank name, facility type, outstanding, rate, security, maturity | Full debt picture. Refinancing risk. Covenant headroom. |
| **Related Party Transactions** | Loans given/received, sales/purchases with group entities, remuneration to KMP | Fund diversion risk. Transfer pricing risk. Promoter governance signal. |
| **Contingent Liabilities** | Tax demands, legal cases, guarantees given | Off-balance-sheet risk. A Rs 50 Cr tax demand can kill a deal. |
| **Other Expenses** | Full breakup (power, rent, legal, freight, etc.) | Operating efficiency. Any unusual items hiding here? |
| **Fixed Assets** | Gross block movement (additions, disposals, revaluation) by asset class | Capex history. Asset quality. |
| **Auditor's Qualifications** | Any qualifications, emphasis of matter, CARO remarks | Red flags. A qualified opinion on inventory or receivables is serious. |

### How to Record Enrichment

In your financial sheet, below each summary line, add indented sub-lines pulled from notes. Color-code them (e.g., light blue background) so it's clear these are note-level details, not face-of-accounts numbers.

In Column I (Source), note: "Note 23, p.47" for traceability.

---

## Step 6: Unit Normalization

Indian financials come in different units. You must normalize everything to **Rupees in Crores** (the standard for BPEA models).

### Detection

Look for the unit declaration. It's usually:
- On the face of the financial statement, top-right: "Rs. in Lakhs" or "Amount in Rs."
- In the header row of each page
- In the notes preamble
- Sometimes DIFFERENT units in different sections of the same annual report (rare but it happens)

### Conversion

| Source Unit | Multiply by | To Get Crores |
|-------------|-------------|---------------|
| Absolute Rupees | / 10,000,000 | Crores |
| Thousands | / 10,000 | Crores |
| Lakhs | / 100 | Crores |
| Crores | x 1 | Crores |
| Millions | / 10 | Crores (approx) |

### Indian Number Formatting

This is the single most common source of data entry errors.

Indian system: **1,00,00,000** = 1 Crore (ten million)
Western system: **10,000,000** = same number

The comma pattern is: first comma after 3 digits from right, then every 2 digits after that.

| Number | Indian Format | What It Is |
|--------|--------------|------------|
| 10,000 | 10,000 | Ten thousand |
| 1,00,000 | 1,00,000 | One lakh |
| 10,00,000 | 10,00,000 | Ten lakhs |
| 1,00,00,000 | 1,00,00,000 | One crore |
| 10,00,00,000 | 10,00,00,000 | Ten crores |

**Danger zone**: When a scanned PDF OCR-s a number, it may drop commas or misplace them. Always sanity-check: if Revenue was Rs 500 Cr last year, it shouldn't be Rs 5,000 Cr this year (unless they acquired something massive). Cross-reference with GSTR if available.

---

## Step 7: The Extraction Process — PDF to Excel

### For Digital PDFs (Text-Selectable)

1. Open the Annual Report PDF.
2. Navigate to the Standalone Financial Statements section (usually starts after Director's Report and Auditor's Report, around page 30-60).
3. Find the Statement of Profit and Loss. Copy numbers year by year into your workbook.
4. Find the Balance Sheet. Same process.
5. Find the Cash Flow Statement. Same process.
6. Go through each Note to Accounts referenced in the face statements. Extract breakdowns.

**Tips:**
- Copy one column (one year) at a time. Don't try to copy the whole table — formatting breaks.
- Indian annual reports always show current year + previous year side by side. Use the previous year as a cross-check: the FY22 column in the FY23 annual report should match the FY22 column in the FY22 annual report. If they don't, there's been a restatement — flag it.
- Watch for reclassifications between years. A line item might move from "Other Expenses" to a separate line in the next year. The total should still match.

### For Scanned PDFs (Image-Only)

This is where the real pain is. Approach:

1. **Don't try to OCR the whole document.** It's faster to manually type numbers from 3-4 pages of financials than to clean up OCR output for 100 pages.
2. **Use the PDF zoom.** Scanned documents at 150-200% zoom make digits readable.
3. **Watch for common OCR/reading errors:**
   - `6` vs `8` vs `0` — In bad scans, these are frequently confused
   - `1` vs `7` — Indian handwriting and certain fonts make these ambiguous
   - `3` vs `8` — Photocopier dust creates closed loops
   - Missing decimal points — Is `12345` actually `123.45` (in lakhs, = Rs 1.23 Cr)?
   - Parentheses for negatives: `(1,234)` means negative 1,234. In scans, the parentheses may not be visible.
4. **Always cross-check against a tally.** If Revenue minus Expenses doesn't equal PBT within a rounding tolerance of Rs 1 lakh (0.01 Cr), you've misread a digit somewhere.
5. **Tables spanning multiple pages:** The column headers only appear on the first page. On subsequent pages, you're counting columns. Mark which column is which before you start typing.

### Starting from a Bank's CMA / Model File

If the investment bank sent an Excel file (like Omsairam's `MKSPL financials.xlsx`), start from it:

1. Open the bank's file. Check what format it's in (CMA format is different from BPEA format).
2. Verify the numbers in the bank's file against the actual annual report. Banks make errors too. Trust but verify.
3. Restructure into BPEA format. The bank's P&L line items won't match exactly — you'll need to reclassify.
4. This saves significant time on Draft 1 but you still need to enrich from notes.

---

## Step 8: Tally Checks

**This is the most critical step.** An untallied file is worthless. A file that tallies but has a quiet error somewhere is dangerous.

### Build a Tally Check Sheet

Create a dedicated `Tally_Check` sheet in the workbook. For each entity and each year, run these checks:

### P&L Tallies

```
Check 1: Total Revenue from Operations
  = Sum of all revenue line items
  vs. Reported Total Revenue from Operations
  Difference: [should be 0 or < 0.01 Cr rounding]

Check 2: Total Expenses
  = RM Consumed + Traded Goods + Inventory Change + Employee + Other Expenses + Depreciation + Finance Costs
  vs. Reported Total Expenses
  Difference: [should be 0]

Check 3: PBT
  = Total Income - Total Expenses +/- Exceptional Items
  vs. Reported PBT
  Difference: [should be 0]

Check 4: PAT
  = PBT - Total Tax Expense
  vs. Reported PAT
  Difference: [should be 0]
```

### Balance Sheet Tallies

```
Check 5: Total Assets
  = Total Non-Current Assets + Total Current Assets
  vs. Reported Total Assets
  Difference: [must be 0]

Check 6: Total Equity & Liabilities
  = Total Equity + Total Non-Current Liabilities + Total Current Liabilities
  vs. Reported Total Equity & Liabilities
  Difference: [must be 0]

Check 7: BS Balance
  = Total Assets - Total Equity & Liabilities
  Difference: [MUST be 0. No rounding tolerance. If this doesn't balance, something is wrong.]
```

### Cash Flow Tallies

```
Check 8: Net Cash Flow
  = Cash from Operations + Cash from Investing + Cash from Financing
  vs. Reported Net Increase/(Decrease) in Cash
  Difference: [should be 0]

Check 9: Closing Cash
  = Opening Cash + Net Cash Flow
  vs. Reported Closing Cash
  vs. Cash on BS
  Difference: [should be 0]
```

### Cross-Statement Tallies

These catch the errors that single-statement checks miss:

```
Check 10: PAT Consistency
  PAT on P&L = PAT on Cash Flow Statement (starting point for indirect method)
  [If different, one statement may include OCI and the other may not]

Check 11: Depreciation Consistency
  Depreciation on P&L = Depreciation add-back on Cash Flow = Depreciation in Fixed Asset schedule (Note)
  [These occasionally differ due to asset disposals — investigate if they don't match]

Check 12: Finance Cost Consistency
  Finance Costs on P&L = Interest Paid on Cash Flow Statement
  [Difference = change in Interest Accrued but Not Due on BS. Check.]

Check 13: Opening = Previous Closing
  Opening BS (Year N) = Closing BS (Year N-1) for every line item
  [If not, there's been a restatement or an accounting policy change. Flag prominently.]

Check 14: Reserves Movement
  Opening Reserves + PAT - Dividends +/- OCI +/- Other Adjustments = Closing Reserves
  [This catches missing dividend distributions or equity adjustments]

Check 15: Debt Movement
  Opening Debt + New Borrowings - Repayments = Closing Debt
  [Cross-check against Cash Flow financing section]
```

### What to Do When Tallies Don't Match

1. **Difference < Rs 0.01 Cr (Rs 1 lakh)**: Rounding. Add a cell comment noting "Rounding difference of Rs X" and move on.
2. **Difference of Rs 0.01 - 1 Cr**: Likely a misread digit or a missed line item. Go back to the PDF and re-check. Common cause: you missed a sub-line in a note.
3. **Difference > Rs 1 Cr**: Something structural is wrong. Either you missed an entire line item, misread units, or the company's own financials have an error (it happens — especially in provisional accounts).
4. **Balance Sheet doesn't balance**: Stop. Do not proceed. Go back and find the error. This is never acceptable.

### Tally Check Summary Table

At the top of the `Tally_Check` sheet, build a summary:

| Check | OSAPL FY21 | OSAPL FY22 | OSAPL FY23 | SAPL FY22 | SAPL FY23 |
|-------|-----------|-----------|-----------|----------|----------|
| P&L: PBT | OK | OK | 0.01 Cr diff | OK | OK |
| P&L: PAT | OK | OK | OK | OK | OK |
| BS Balance | OK | OK | OK | OK | OK |
| CF: Closing Cash | OK | OK | OK | OK | OK |
| Cross: PAT match | OK | OK | OK | OK | OK |
| Cross: Opening=Closing | OK | OK | Restatement (Note 2) | OK | OK |

Color code: Green = OK, Yellow = rounding difference noted, Red = unresolved.

**A file is not ready for senior review until every cell in this table is Green or Yellow with an explanation.**

---

## Step 9: The Iteration Cycle

Extraction is not a one-shot process. Here's the realistic lifecycle:

### Draft 1 — Rough Extraction
- Pull face-of-accounts numbers for all available years
- Run basic tallies (BS balance, PAT = PBT - Tax)
- Note obvious gaps ("FY24 not available", "Consolidated financials not in dump")
- **Time: 3-6 hours per entity depending on quality**
- **File size: ~500 KB** (numbers only, no enrichment)

### Draft 2 — Corrections + Notes Enrichment
- Fix tally breaks found in Draft 1
- Add notes-level breakdowns (revenue mix, expense detail, borrowing schedule)
- Fill in Column H (Comments) with initial questions
- **Common trigger**: Senior glances at Draft 1, flags obvious issues

### Draft 3 — New Data Incorporated
- More data arrives (Batch 2 from company, or the bank sends their model)
- Add new years / new entities
- Re-check tallies with new data
- **File size grows**: adding subsidiary sheets, more notes detail

### Draft 4 — Subsidiary Sheets Added
- Entity map may have grown (triage discovers more group companies)
- Each new entity = new sheet = new extraction cycle
- Cross-entity checks: do intercompany transactions eliminate in consolidated?

### Draft 5 — Final Tally + Comments Resolution
- Senior review generates comments: "Check Note 14 for contingent liabilities", "Break out related party loans separately", "Why is closing cash different from bank statement balance?"
- Resolve each comment or escalate if it needs company clarification
- All tallies must be green or yellow-with-explanation

### Draft 6 — Cleared
- Senior has signed off
- "Cleared" in the filename means: tallies match, notes enriched, all entities covered, comments resolved
- This file now feeds into the Working File Builder (next stage)
- **Omsairam final file: 2.0 MB, took 5 weeks**

### File Naming Convention

```
[DealName] Financials Draft [N].xlsx
[DealName] Financials Draft [N] Cleared.xlsx
```

Examples:
- `Omsairam Financials Draft 1.xlsx`
- `Omsairam Financials Draft 4.xlsx`
- `Omsairam Financials Draft 6 Cleared.xlsx`

Keep all drafts. Don't delete intermediate versions. Version history matters when a question comes up about when a number changed.

---

## Step 10: Common Extraction Traps

### 1. Ind-AS vs Indian GAAP
Older financials (pre-FY18 for listed, varies for unlisted) may be under old Indian GAAP. Key differences:
- No Right-of-Use assets / Lease liabilities (Ind-AS 116 / old AS 19)
- No OCI section
- Deferred tax computed differently
- Revenue recognition differences
- Fixed asset revaluation treatment

If you're pulling 5-year history and the company transitioned mid-way, there will be a restatement year. The FY18 column in the FY18 annual report (Indian GAAP) may not match the FY18 column in the FY19 annual report (Ind-AS restated). Use the restated numbers.

### 2. Standalone vs Consolidated Mismatch
The standalone P&L shows dividend income from subsidiaries. The consolidated P&L eliminates this and instead consolidates the subsidiary's full P&L. EBITDA at standalone level can look artificially high if the subsidiary is paying up dividends.

### 3. Exceptional Items Buried in Line Items
Some companies don't break out exceptional items on the face. They bury a one-time gain in "Other Income" or a one-time loss in "Other Expenses." The only way to catch this is reading the notes and the Directors' Report narrative. Flag any YoY movement > 30% in a line item and investigate.

### 4. Schedule III Format Changes
MCA periodically updates Schedule III (the prescribed format for Indian financials). Recent change: MSME creditor split became mandatory. Ageing schedules for receivables and payables became mandatory from FY22. Older years won't have these — you'll need to estimate or request from the company.

### 5. Current Maturities of Long-Term Debt (CMLTD)
This is the portion of long-term debt due within 12 months. Under Ind-AS, it's often classified under "Other Current Financial Liabilities," not under "Short-Term Borrowings." Always extract it as a separate line. It's critical for debt service calculations.

### 6. The "Lac" vs "Lakh" Trap
Both mean the same thing (100,000). But in some South Indian / older documents, you'll see "Lac" instead of "Lakh." Don't treat it as a different unit.

### 7. Provisional Numbers
Current-year provisional/management accounts are usually unaudited. They may:
- Not include depreciation properly (especially smaller companies)
- Use cash-basis instead of accrual for some items
- Not include year-end provisions (gratuity, leave, deferred tax)
- Be wildly different from the final audited numbers

Flag provisional numbers clearly. Use a different font color (e.g., blue) in the workbook.

### 8. Negative Numbers Convention
Annual reports use parentheses for negatives: `(1,234)` = minus 1,234. Some use a minus sign. Some use "Dr." and "Cr." for debit/credit in certain schedules. Be consistent in your Excel: use negative numbers (not parentheses, not red font) for actual cell values, and format display separately.

---

## Handoff to Next Stage

When the file is "Cleared," it feeds into the Working File Builder. The Working File adds:

- Ratio analysis (DSCR, ICR, leverage, returns)
- Adjustments (normalizing for one-time items)
- Projections (base case, stress case)
- Debt sizing

But those are separate skills. This skill's job is done when the extraction is clean, tallied, enriched, and cleared by a senior.

---

## Quick Reference: Extraction Checklist

For each entity, confirm:

- [ ] P&L extracted for all available years, in BPEA format
- [ ] Balance Sheet extracted for all available years, in BPEA format
- [ ] Cash Flow Statement extracted for all available years
- [ ] All numbers in Crores (unit conversion applied and noted)
- [ ] Notes-to-accounts enrichment for: Revenue mix, Borrowings, Related Party, Contingent Liabilities, Other Expenses
- [ ] Column H (Comments) populated with open questions
- [ ] Column I (Source) populated with PDF page references
- [ ] P&L tallies: all green or yellow
- [ ] BS tallies: all green (no tolerance — must balance)
- [ ] CF tallies: all green or yellow
- [ ] Cross-statement tallies: all green or yellow
- [ ] Previous year cross-check (FY22 in FY23 AR = FY22 in FY22 AR)
- [ ] Restatements flagged if any
- [ ] Provisional numbers color-coded
- [ ] Tally Check sheet completed with summary table
- [ ] File named per convention with draft number
