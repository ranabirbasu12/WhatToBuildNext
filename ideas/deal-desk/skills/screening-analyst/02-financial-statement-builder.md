# 02 — Financial Statement Builder

## Role

You take the structured data produced by the Document Ingestion skill (01) and build a clean, formula-linked, tally-verified 3-statement financial model in the BPEA standard template format. Every number must trace back to its source. Every cell must be formula-driven. Nothing is hardcoded. The model must pass all cross-statement validation checks before it leaves your hands.

---

## Why This Matters

In private credit, the 3-statement model is the foundation of every decision. When a senior credit officer asks "what's the Debt/EBITDA?", the answer comes from this model. When the IC debates whether to approve a INR 500 Cr NCD facility, they're looking at projections built on top of this model. If Revenue is wrong by 20 Cr because someone mistyped a number from a scanned PDF, the entire analysis is compromised.

The associate currently spends 2-3 weeks building this model by hand, debugging formula errors, and getting it redlined by seniors. You produce it in minutes — but it must be perfect.

---

## BPEA Standard Template Structure

### Sheet 1: Summary Dashboard
```
COMPANY NAME
Financial Summary (INR Crores)

                              FY2020   FY2021   FY2022   FY2023   FY2024
Revenue                         XXX      XXX      XXX      XXX      XXX
EBITDA                          XXX      XXX      XXX      XXX      XXX
EBITDA Margin %                 XX%      XX%      XX%      XX%      XX%
PAT                             XXX      XXX      XXX      XXX      XXX
Total Debt                      XXX      XXX      XXX      XXX      XXX
Net Debt                        XXX      XXX      XXX      XXX      XXX
Net Worth                       XXX      XXX      XXX      XXX      XXX
D/E Ratio                       X.Xx     X.Xx     X.Xx     X.Xx     X.Xx
ISCR                            X.Xx     X.Xx     X.Xx     X.Xx     X.Xx
DSCR                            X.Xx     X.Xx     X.Xx     X.Xx     X.Xx
ROCE %                          XX%      XX%      XX%      XX%      XX%
```

### Sheet 2: Profit and Loss Statement

#### Line Item Mapping

Map ingested data to this exact structure. Each line item has a code for formula referencing.

```
STATEMENT OF PROFIT AND LOSS (INR Crores)
                                         FY2020  FY2021  FY2022  FY2023  FY2024

A. INCOME
A1   Revenue from Operations              =SUM(A1a:A1c)
A1a    Sale of Products                   [from ingestion]
A1b    Sale of Services                   [from ingestion]
A1c    Other Operating Revenue            [from ingestion]
A2   Other Income                         =SUM(A2a:A2c)
A2a    Interest Income                    [from ingestion]
A2b    Dividend Income                    [from ingestion]
A2c    Other Non-Operating Income         [from ingestion]
A3   TOTAL INCOME                         =A1+A2

B. EXPENSES
B1   Cost of Materials Consumed           [from ingestion]
B2   Purchases of Stock-in-Trade          [from ingestion]
B3   Changes in Inventories               [from ingestion — note: negative = increase]
B4   Employee Benefits Expense            [from ingestion]
B5   Finance Costs                        =SUM(B5a:B5c)
B5a    Interest on Borrowings             [from ingestion]
B5b    Other Borrowing Costs              [from ingestion]
B5c    Interest on Lease Liabilities      [from ingestion — Ind-AS 116]
B6   Depreciation and Amortisation        =SUM(B6a:B6b)
B6a    Depreciation on PPE                [from ingestion]
B6b    Amortisation of Intangibles        [from ingestion]
B6c    Depreciation on RoU Assets         [from ingestion — Ind-AS 116]
B7   Other Expenses                       [from ingestion]
B8   TOTAL EXPENSES                       =SUM(B1:B7)

C. OPERATING METRICS (DERIVED)
C1   Gross Profit                         =A1-(B1+B2+B3)
C2   Gross Margin %                       =C1/A1
C3   EBITDA (Reported)                    =A3-B8+B5+B6
C4   EBITDA Margin %                      =C3/A1
C5   Adjusted EBITDA                      =C3-[exceptional gains]+[exceptional losses]
C6   Adjusted EBITDA Margin %             =C5/A1

D. PROFIT
D1   Profit Before Exceptional Items      =A3-B8
D2   Exceptional Items (Net)              [from ingestion — detail each item below]
D2a    [Description of Item 1]            [amount]
D2b    [Description of Item 2]            [amount]
D3   Profit Before Tax (PBT)              =D1+D2
D4   Tax Expense                          =SUM(D4a:D4c)
D4a    Current Tax                        [from ingestion]
D4b    Deferred Tax                       [from ingestion]
D4c    MAT Credit Entitlement             [from ingestion]
D5   Profit After Tax (PAT)               =D3-D4
D6   PAT Margin %                         =D5/A1

E. OTHER COMPREHENSIVE INCOME (Ind-AS only)
E1   Items not reclassified to P&L        [from ingestion]
E2   Items that will be reclassified      [from ingestion]
E3   Total Comprehensive Income           =D5+E1+E2

F. PER SHARE DATA
F1   Basic EPS (Rs.)                      [from ingestion — absolute INR, not in Crores]
F2   Diluted EPS (Rs.)                    [from ingestion]
F3   Weighted Avg Shares (Lakhs)          =D5*[unit]/F1 [cross-check]
```

### Sheet 3: Balance Sheet

```
BALANCE SHEET (INR Crores)
As at:                                   31-Mar-20  31-Mar-21  31-Mar-22  31-Mar-23  31-Mar-24

EQUITY AND LIABILITIES

I. EQUITY
EQ1  Share Capital                        [from ingestion]
EQ2  Reserves and Surplus                 [from ingestion]
EQ3  Other Equity (OCI Reserve etc.)      [from ingestion — Ind-AS]
EQ4  TOTAL EQUITY (NET WORTH)             =SUM(EQ1:EQ3)

II. NON-CURRENT LIABILITIES
NL1  Long-Term Borrowings                 [from ingestion]
NL2  Lease Liabilities (Non-Current)      [from ingestion — Ind-AS 116]
NL3  Deferred Tax Liabilities (Net)       [from ingestion]
NL4  Other Non-Current Liabilities        [from ingestion]
NL5  Long-Term Provisions                 [from ingestion]
NL6  TOTAL NON-CURRENT LIABILITIES        =SUM(NL1:NL5)

III. CURRENT LIABILITIES
CL1  Short-Term Borrowings                [from ingestion]
CL2  Lease Liabilities (Current)          [from ingestion — Ind-AS 116]
CL3  Trade Payables                       =CL3a+CL3b
CL3a   Due to MSMEs                       [from ingestion]
CL3b   Due to Others                      [from ingestion]
CL4  Other Current Liabilities            [from ingestion]
CL5  Short-Term Provisions                [from ingestion]
CL6  Current Maturities of LT Debt (CMLTD) [from ingestion]
CL7  TOTAL CURRENT LIABILITIES            =SUM(CL1:CL6)

TOTAL EQUITY AND LIABILITIES              =EQ4+NL6+CL7

IV. NON-CURRENT ASSETS
NA1  Property, Plant and Equipment        [from ingestion — Net Block]
NA2  Capital Work-in-Progress             [from ingestion]
NA3  Right-of-Use Assets                  [from ingestion — Ind-AS 116]
NA4  Goodwill                             [from ingestion]
NA5  Other Intangible Assets              [from ingestion]
NA6  Intangible Assets Under Development  [from ingestion]
NA7  Non-Current Investments              [from ingestion]
NA8  Non-Current Loans and Advances       [from ingestion]
NA9  Deferred Tax Assets (Net)            [from ingestion]
NA10 Other Non-Current Assets             [from ingestion]
NA11 TOTAL NON-CURRENT ASSETS             =SUM(NA1:NA10)

V. CURRENT ASSETS
CA1  Inventories                          [from ingestion]
CA2  Trade Receivables                    [from ingestion]
CA3  Cash and Cash Equivalents            [from ingestion]
CA4  Bank Balances (Other than Cash)      [from ingestion — FDs, margin money]
CA5  Current Investments                  [from ingestion]
CA6  Current Loans and Advances           [from ingestion]
CA7  Other Current Assets                 [from ingestion]
CA8  TOTAL CURRENT ASSETS                 =SUM(CA1:CA7)

TOTAL ASSETS                              =NA11+CA8

BALANCE CHECK:                            =TOTAL ASSETS - TOTAL EQUITY AND LIABILITIES
                                          [MUST BE ZERO]
```

### Sheet 4: Cash Flow Statement

```
CASH FLOW STATEMENT (INR Crores)
For the year ended:                      FY2020  FY2021  FY2022  FY2023  FY2024

A. CASH FLOW FROM OPERATING ACTIVITIES
CF_A1  Profit Before Tax                  =D3 [from P&L]
       Adjustments for:
CF_A2    Depreciation & Amortisation      =B6 [from P&L]
CF_A3    Finance Costs                    =B5 [from P&L]
CF_A4    Interest Income                  =-A2a [from P&L]
CF_A5    (Gain)/Loss on Sale of Assets    [from ingestion]
CF_A6    Provision for Doubtful Debts     [from ingestion]
CF_A7    Unrealised Forex (Gain)/Loss     [from ingestion]
CF_A8    Other Non-Cash Adjustments       [from ingestion]
CF_A9  Operating Profit Before WC Changes =SUM(CF_A1:CF_A8)

       Working Capital Changes:
CF_A10   (Inc)/Dec in Trade Receivables   [from ingestion OR =(prior CA2 - current CA2)]
CF_A11   (Inc)/Dec in Inventories         [from ingestion OR =(prior CA1 - current CA1)]
CF_A12   (Inc)/Dec in Other Current Assets [from ingestion OR derived]
CF_A13   Inc/(Dec) in Trade Payables      [from ingestion OR =(current CL3 - prior CL3)]
CF_A14   Inc/(Dec) in Other Current Liab. [from ingestion OR derived]
CF_A15 Cash Generated from Operations     =CF_A9+SUM(CF_A10:CF_A14)
CF_A16 Income Tax Paid                    [from ingestion]
CF_A17 NET CASH FROM OPERATIONS (OCF)     =CF_A15+CF_A16

B. CASH FLOW FROM INVESTING ACTIVITIES
CF_B1  Purchase of PPE/Intangibles (Capex) [from ingestion]
CF_B2  Proceeds from Sale of PPE          [from ingestion]
CF_B3  Purchase of Investments            [from ingestion]
CF_B4  Proceeds from Sale of Investments  [from ingestion]
CF_B5  Interest Received                  [from ingestion]
CF_B6  Dividends Received                 [from ingestion]
CF_B7  Other Investing Activities         [from ingestion]
CF_B8  NET CASH FROM INVESTING (ICF)      =SUM(CF_B1:CF_B7)

C. CASH FLOW FROM FINANCING ACTIVITIES
CF_C1  Proceeds from LT Borrowings       [from ingestion]
CF_C2  Repayment of LT Borrowings        [from ingestion]
CF_C3  Net Proceeds/(Repayment) ST Borr.  [from ingestion]
CF_C4  Interest Paid                      [from ingestion]
CF_C5  Dividends Paid                     [from ingestion]
CF_C6  Lease Payments (Ind-AS 116)        [from ingestion]
CF_C7  Equity Infusion / Share Premium    [from ingestion]
CF_C8  Other Financing Activities         [from ingestion]
CF_C9  NET CASH FROM FINANCING (FCF_fin)  =SUM(CF_C1:CF_C8)

D. SUMMARY
CF_D1  Net Change in Cash                 =CF_A17+CF_B8+CF_C9
CF_D2  Opening Cash Balance               =Prior year CA3 [from BS]
CF_D3  Closing Cash Balance               =CF_D1+CF_D2
CF_D4  Cash per Balance Sheet             =CA3 [from BS]
CF_D5  RECONCILIATION CHECK               =CF_D3-CF_D4 [MUST BE ZERO]
```

### Sheet 5: Key Schedules (Supporting Detail)

```
FIXED ASSET SCHEDULE (INR Crores)
                        Gross Block              Depreciation           Net Block
Asset Class        Opening  Add  Disp  Closing  Opening  Charge  Disp  Closing  Net
Land                 XXX    XXX   XXX    XXX      -       -       -      -      XXX
Buildings            XXX    XXX   XXX    XXX     XXX     XXX     XXX    XXX     XXX
Plant & Machinery    XXX    XXX   XXX    XXX     XXX     XXX     XXX    XXX     XXX
Furniture            XXX    XXX   XXX    XXX     XXX     XXX     XXX    XXX     XXX
Vehicles             XXX    XXX   XXX    XXX     XXX     XXX     XXX    XXX     XXX
Computers            XXX    XXX   XXX    XXX     XXX     XXX     XXX    XXX     XXX
RoU Assets           XXX    XXX   XXX    XXX     XXX     XXX     XXX    XXX     XXX
TOTAL                XXX    XXX   XXX    XXX     XXX     XXX     XXX    XXX     XXX

Cross-check: Total Net Block = NA1 + NA3 [from BS]
Cross-check: Depreciation Charge = B6 [from P&L]

BORROWING SCHEDULE (INR Crores)
Lender       Type      Sanctioned  Outstanding   Rate        Maturity   Security     CMLTD
SBI          Term Loan    150.0      112.5      MCLR+1.25%   Mar-27    1st charge     25.0
HDFC Bank    CC/OD         75.0       48.2      MCLR+0.75%   Revolving  Stock+Recv     -
PFC          ECB           50.0       42.0      SOFR+2.50%   Jun-28    2nd charge     10.0
TOTAL                     275.0      202.7                                             35.0

Cross-check: LT Outstanding - CMLTD = NL1 [from BS]
Cross-check: CMLTD = CL6 [from BS]
Cross-check: ST Outstanding = CL1 [from BS]
Cross-check: Total Outstanding = NL1 + CL1 + CL6 = Total Debt

WORKING CAPITAL SCHEDULE (INR Crores)
                              FY2020  FY2021  FY2022  FY2023  FY2024
Inventories (CA1)               XXX     XXX     XXX     XXX     XXX
Trade Receivables (CA2)         XXX     XXX     XXX     XXX     XXX
Other Current Assets (CA6+CA7)  XXX     XXX     XXX     XXX     XXX
TOTAL CURRENT ASSETS            XXX     XXX     XXX     XXX     XXX

Trade Payables (CL3)            XXX     XXX     XXX     XXX     XXX
Other Current Liab (CL4+CL5)   XXX     XXX     XXX     XXX     XXX
TOTAL CURRENT LIABILITIES       XXX     XXX     XXX     XXX     XXX
(excl. Short-Term Borrowings)

NET WORKING CAPITAL              XXX     XXX     XXX     XXX     XXX
NWC as % of Revenue              XX%     XX%     XX%     XX%     XX%
```

---

## Line Item Mapping Rules

### Revenue Mapping
| Source Document Term | Maps To | Notes |
|---------------------|---------|-------|
| "Revenue from Operations" | A1 | Direct |
| "Sales" / "Turnover" | A1a | Old GAAP terminology |
| "Income from Operations" | A1 | Alternative Ind-AS phrasing |
| "Service Income" / "Service Revenue" | A1b | Service companies |
| "Scrap Sales" | A1c (if regular) or A2c (if irregular) | Judgment call based on materiality and recurrence |
| "Export Incentives" / "Duty Drawback" | A1c | Operating in nature |
| "Government Grants" | A1c or A2c | Depends on Ind-AS 20 treatment |

### Expense Mapping
| Source Document Term | Maps To | Notes |
|---------------------|---------|-------|
| "Cost of Materials Consumed" | B1 | Direct — opening stock + purchases - closing stock |
| "Purchase of Traded Goods" | B2 | Trading companies |
| "Changes in Inventories of FG/WIP" | B3 | Negative means inventory increased (cost not yet in COGS) |
| "Salaries and Wages" | B4 | Part of Employee Benefits |
| "Contribution to PF/Gratuity" | B4 | Part of Employee Benefits |
| "Staff Welfare" | B4 | Part of Employee Benefits |
| "ESOP Expense" | B4 | Non-cash — note for adjusted EBITDA |
| "Interest Expense" | B5a | |
| "Bank Charges" | B5b | Sometimes material, sometimes in Other Expenses |
| "Processing Fees" | B5b | Loan processing costs |
| "Lease Rent" (pre Ind-AS 116) | B7 | Old GAAP treatment |
| "Power and Fuel" | B7 | |
| "Repairs and Maintenance" | B7 | |
| "Selling and Distribution" | B7 | |
| "Legal and Professional" | B7 | |
| "CSR Expenditure" | B7 | Mandatory for qualifying companies (Section 135) |

### Debt Classification
**Critical for leverage ratios — get this right.**

| Item | Treatment | Rationale |
|------|-----------|-----------|
| Long-Term Borrowings (BS) | Total Debt | Includes term loans, NCDs, ECBs |
| Current Maturities of LT Debt | Total Debt | Already in Current Liabilities, but originally LT |
| Short-Term Borrowings | Total Debt | Working capital facilities (CC/OD), short-term loans |
| Lease Liabilities (Ind-AS 116) | **Include in Total Debt** for credit analysis | Not all funds treat this the same — default include |
| Buyer's Credit / Supplier's Credit | Total Debt if > 90 days | Short-term trade finance |
| Interest Accrued but Not Due | **Exclude** from Total Debt | Already reflected in Finance Costs |
| Preference Shares (redeemable) | Total Debt | Treated as debt under Ind-AS |
| Compulsorily Convertible Debentures | **Case by case** — equity if converts within 18 months | Discuss with senior |

### Cash for Net Debt
| Item | Treatment |
|------|-----------|
| Cash and Cash Equivalents (CA3) | Include in cash |
| Bank Balances Other than Cash (CA4) | Include if liquid (FDs < 12 months) |
| Current Investments (CA5) | Include if liquid (mutual funds, T-bills) |
| Unpledged FDs | Include |
| Margin money / lien-marked deposits | **Exclude** — not available for debt repayment |
| Earmarked balances (dividend accounts, unclaimed) | **Exclude** |

**Net Debt = Total Debt - (Cash + Liquid Investments)**

---

## Cross-Statement Validation Rules

These checks MUST all pass before the model is considered complete.

### Check 1: Balance Sheet Balance
```
For each year:
  TOTAL ASSETS - (TOTAL EQUITY + TOTAL LIABILITIES) = 0
  Tolerance: < INR 0.01 Cr (rounding only)
```
If this fails: There is a data extraction error. Go back to ingestion output and verify each line item. Common causes:
- Missing a schedule (e.g., "Other Current Liabilities" not extracted)
- CMLTD double-counted (once in Non-Current as negative, once in Current as positive)
- OCI reserve not included in Equity

### Check 2: Cash Flow Reconciliation
```
For each year:
  Opening Cash (= prior year Closing Cash on BS) + Net CF = Closing Cash (on BS)
  Tolerance: < INR 0.05 Cr
```
If this fails and CF was taken from the filed statement: The filed CF itself may have an error (happens occasionally with Indian filings) or there is a foreign exchange translation effect on cash. Note the variance but proceed.

If CF was derived (because company didn't file one): Check that WC changes are correctly signed (increase in receivables is negative CF, increase in payables is positive CF).

### Check 3: Retained Earnings Flow
```
For each year:
  Opening Reserves + PAT - Dividends Paid +/- OCI +/- Other Adjustments = Closing Reserves
  Tolerance: < INR 0.10 Cr
```
"Other Adjustments" include:
- Share premium received during the year
- Bonus shares issued (transfer from reserves to share capital)
- Buyback (reduction in reserves and share capital)
- Ind-AS transition adjustments (first year of Ind-AS adoption)
- Changes in accounting policy (retrospective adjustments)

If the variance is material and unexplained: Flag it. Common cause is an Ind-AS transition restatement that wasn't clearly disclosed.

### Check 4: Depreciation Cross-Check
```
For each year:
  Depreciation in P&L (B6) = Depreciation charge in Fixed Asset Schedule
  Tolerance: < INR 0.05 Cr
```
If this fails: Check if RoU Asset depreciation is shown separately in the notes but combined in the P&L line item. Also check if there's depreciation on investment property (separate from PPE).

### Check 5: Interest Expense Cross-Check
```
For each year:
  Finance Costs in P&L (B5) ≈ Interest Paid in CF (CF_C4) +/- change in interest accrued
  Tolerance: < INR 0.50 Cr (interest accrual timing can cause larger variances)
```

### Check 6: Capex Cross-Check
```
For each year:
  Additions to Gross Block (from Fixed Asset Schedule) ≈
  Purchase of PPE in CF (CF_B1) + Change in CWIP + Change in Capital Advances
  Tolerance: < INR 1.00 Cr (CWIP timing differences)
```

### Check 7: Tax Cross-Check
```
For each year:
  Current Tax in P&L (D4a) ≈ Income Tax Paid in CF (CF_A16) +/- change in tax payable/receivable
  Tolerance: < INR 0.50 Cr
```

### Check 8: Debt Movement Cross-Check
```
For each year:
  Opening Total Debt + New Borrowings - Repayments = Closing Total Debt
  (From CF: CF_C1 + CF_C2 + CF_C3 should explain the change in BS debt)
  Tolerance: < INR 1.00 Cr
```

---

## Handling Common Indian Accounting Issues

### Ind-AS vs Old GAAP Transition
- Companies above certain thresholds transitioned to Ind-AS between FY2017-FY2019
- The transition year has restated comparatives — use the restated numbers for the prior year
- Key differences: revenue (Ind-AS 115), leases (Ind-AS 116), financial instruments (Ind-AS 109)
- If comparing across the transition, note it clearly: "FY2018 is IGAAP, FY2019+ is Ind-AS"

### Exceptional Items Treatment
- Indian P&Ls frequently have "Exceptional Items" — these distort profitability
- Common exceptional items:
  - Write-down of investments
  - VRS/restructuring costs
  - Insurance claims received
  - Gain/loss on sale of subsidiary
  - Impairment of assets
  - COVID-related provisions (FY2020-FY2022)
- **Always compute both Reported EBITDA and Adjusted EBITDA** (excluding exceptional items)

### Related Party Adjustments
- If the company pays above-market rent to a promoter entity, Adjusted EBITDA should note this
- If revenue from a related party is at non-arm's-length prices, flag for the ratio engine
- Do not adjust the model itself — flag these in a separate "Adjustments" section

### GST Impact (introduced July 2017)
- Pre-GST revenue is gross of excise/service tax; post-GST revenue is net of GST
- FY2018 is the transition year — H1 pre-GST, H2 post-GST
- Revenue comparison FY2017 to FY2018 is NOT apples-to-apples
- If comparing, note: "Revenue adjusted for GST comparability" and apply a rough adjustment (typically 5-12% depending on industry)

### Minority Interest (Consolidated)
- If using consolidated financials, PAT attributable to minority interest must be separated
- Net Worth should also separate minority interest
- For credit analysis of the borrower entity, standalone is preferred

---

## Decimal and Unit Verification Protocol

Before finalizing the model, run this checklist:

1. **Unit header confirmed** for every source document: [ ] Yes / [ ] No (which?)
2. **All numbers converted to INR Crores**: [ ] Yes
3. **Sense checks passed**:
   - Revenue is in a believable range for the industry and company size: [ ] Yes
   - Total Assets > Revenue (for asset-heavy) or Total Assets < Revenue (for trading): [ ] Reasonable
   - PAT Margin is within industry norms (not negative 500% or positive 80%): [ ] Yes
   - EPS x Share Count ≈ PAT: [ ] Yes (tolerance 1%)
   - Debt matches the borrowing schedule total: [ ] Yes
4. **Year-over-year sanity**: No line item changes by more than 5x without an explanation: [ ] Yes
5. **Decimal alignment**: All numbers have consistent decimal places (2 decimal places for Crores): [ ] Yes

---

## Output Format

The model is produced as structured data that can be:
1. Rendered as formatted Markdown tables (for in-conversation review)
2. Exported to Excel (for the associate to work with further)
3. Fed directly to the Ratio Engine (03) and Red Flag Scanner (04)

Every cell in the output carries metadata:
```json
{
  "value": 523.45,
  "formula": "=A1a+A1b+A1c",
  "source": "ingestion.profit_and_loss.revenue_from_operations",
  "confidence": 0.95,
  "unit": "crores",
  "validated": true,
  "validation_checks_passed": ["bs_balance", "cf_reconciliation"]
}
```

---

## When to Derive vs Extract

| Statement | Prefer | When to Derive |
|-----------|--------|----------------|
| P&L | Always extract from source | Never derive — P&L is always filed |
| Balance Sheet | Always extract from source | Never derive — BS is always filed |
| Cash Flow | Extract if filed | Derive if: (a) company exempt, (b) filed CF doesn't reconcile, (c) CF not available |
| Fixed Asset Schedule | Extract from notes | Derive if notes not available — use BS PPE + P&L depreciation |
| Borrowing Schedule | Extract from notes | Derive if notes incomplete — use BS debt figures, estimate CMLTD |
| Working Capital | Always derive from BS | WC = Current Assets - Current Liabilities (excl ST Borrowings) |

When deriving Cash Flow from P&L and BS changes:
1. Start with PBT from P&L
2. Add back depreciation (from P&L) and finance costs (from P&L)
3. Compute WC changes from BS deltas (change in receivables, inventories, payables, other)
4. Tax paid = current tax expense from P&L (approximate)
5. Capex = change in gross block from Fixed Asset Schedule (or change in Net Block + Depreciation)
6. Debt changes = change in total borrowings from BS
7. Clearly label: **"DERIVED CASH FLOW — constructed from P&L and Balance Sheet movements. Not from filed Cash Flow Statement."**

---

## Historical Trend Requirements

- **Minimum**: 3 years of historicals
- **Preferred**: 5 years of historicals
- **Maximum useful**: 7 years (beyond that, the business may have changed fundamentally)
- All years in the same unit (INR Crores)
- All years on the same accounting standard if possible (note IGAAP-to-IndAS transitions)
- Column order: oldest on left, newest on right (standard in Indian financial analysis)
- Include year-over-year growth rates for key items (Revenue, EBITDA, PAT, Total Debt)
