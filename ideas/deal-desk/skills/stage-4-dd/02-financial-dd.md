# Stage 4.2: Financial DD

You are performing the financial deep dive — validating that the numbers are real, identifying adjustments, and producing the restated financials that will feed into the Financial Model (Stage 5).

This is the most analytically intensive workstream in DD. The external vendor (Deloitte, EY, KPMG) does the heavy lifting, but the associate must understand, challenge, and integrate their findings.

---

## Financial DD Scope

### Quality of Earnings

The central question: **"Is reported EBITDA a reliable indicator of future cash generation?"**

```
Reported EBITDA
  (-) One-time / non-recurring income
  (-) Related party revenue at non-arm's-length prices
  (-) Accounting policy changes that inflate earnings
  (+) One-time / non-recurring expenses
  (+) Normalization adjustments (COVID impact, restructuring costs)
  (=) Adjusted EBITDA (Quality of Earnings EBITDA)
```

> **Source Citation Requirement:** Every QoE adjustment, financial finding, and verified data point must cite the original document using `[Source: <filename>, p.<page>, "<quoted text if key>"]`. For example: `[Source: Audited BS FY24, p.12, Note 8, "Trade Receivables: 94.3 Cr"]` or `[Source: GST Returns FY24, GSTR-1 Mar-24, "Outward supplies: 48.2 Cr"]`. The DD report is an evidentiary document — unsourced findings will not survive IC scrutiny.

### Common Adjustments

| Adjustment Type | What to Look For | Impact Direction |
|----------------|-----------------|-----------------|
| **One-time income** | Asset sales, insurance claims, government grants | Reduces sustainable EBITDA |
| **Related party** | Management fees to promoter entities, rent at above-market rates | Reduces or increases EBITDA |
| **Accounting policy** | Revenue recognition changes, depreciation method changes | May inflate recent EBITDA |
| **Provision reversals** | Bad debt provisions reversed, warranty provision released | Reduces sustainable EBITDA |
| **Capitalized expenses** | Operating expenses capitalized as assets (common trap) | Reduces real EBITDA |
| **COVID normalization** | FY20-21 affected by lockdowns, stimulus | Adjust or exclude affected periods |
| **Seasonality** | Agri businesses: single harvest cycle distorts quarterly numbers | Annualize carefully |

### Checklist: What to Verify

**P&L Verification:**
- [ ] Revenue reconciliation: audited P&L ↔ GST returns ↔ bank credit entries
- [ ] Top 10 customers: revenue trend, contract terms, payment track record
- [ ] EBITDA margin drivers: raw material cost, employee cost, other expenses
- [ ] Below-EBITDA items: depreciation policy, interest allocation, exceptional items
- [ ] Tax reconciliation: book profit vs. taxable income, reasons for difference

**Balance Sheet Verification:**
- [ ] Fixed asset register: exists, reconciles, properly depreciated
- [ ] Inventory: valuation method, aging, slow-moving/obsolete stock, physical verification
- [ ] Receivables: aging analysis, provisioning policy, customer creditworthiness
- [ ] Payables: aging, any overdue amounts, concentration
- [ ] Debt schedule: all borrowings listed, terms, repayment schedule, compliance
- [ ] Contingent liabilities: guarantees, disputed tax demands, pending litigation
- [ ] Related party balances: inter-company loans, trade balances, nature and terms

**Cash Flow Verification:**
- [ ] EBITDA to OCF bridge: does operating cash flow track EBITDA? (If OCF/EBITDA < 0.7x consistently → investigate)
- [ ] Working capital changes: are they absorbing cash? Trend direction?
- [ ] Capex: maintenance vs. growth split. Is maintenance capex sufficient?
- [ ] Free cash flow: after capex and WC changes, is there cash available for debt service?

---

## Working Capital Deep Dive

Working capital analysis is critical for credit — it determines whether EBITDA translates into actual cash available for debt service.

### WC Cycle Calculation

```
Debtor Days = (Trade Receivables / Revenue) × 365
Inventory Days = (Inventory / COGS) × 365
Creditor Days = (Trade Payables / Purchases) × 365

Net WC Cycle = Debtor Days + Inventory Days - Creditor Days
```

### WC Normalization

For seasonal businesses (like Asandas with 164-day WC cycle due to single potato harvest):
- Don't use quarter-end snapshots — they'll show extreme swings
- Use average of monthly balances for a normalized view
- Understand the seasonal pattern: when does cash build? When does it drain?

### WC Funding Check

```
Net Working Capital: INR ___ Cr
WC funded by short-term borrowings: INR ___ Cr
WC funded by equity / long-term debt: INR ___ Cr

If >80% funded by short-term borrowings:
→ Refinancing risk (what if banks don't renew?)
→ Verify CC/OD limit utilization over 12 months
→ Check for persistent overutilization (regulatory red flag)
```

---

## Related Party Analysis

Related party transactions are the most common source of hidden value extraction. Every RPT must be assessed:

```
| # | Related Party | Relationship | Transaction Type | Amount (INR Cr) | At Arm's Length? |
|---|--------------|-------------|-----------------|-----------------|-----------------|
| 1 | [Entity] | Promoter group co | Management fee | ___ | Verify vs. market rate |
| 2 | [Entity] | Promoter family | Rent | ___ | Compare to circle rate |
| 3 | [Entity] | Subsidiary | Inter-company sale | ___ | Check transfer pricing |
| 4 | [Entity] | Associate | Loan | ___ | Check interest rate |
```

**Red Flags:**
- Management fees > 2% of revenue (excessive extraction)
- Rent at significantly above market rates
- Inter-company loans at below-market interest rates
- Purchases from promoter entities at above-market prices
- Promoter personal expenses charged to the company

---

## Cash Flow Bridge

The most important analytical output of financial DD:

```
EBITDA (Audited)                                    ___
(−) Quality of earnings adjustments                  (__)
= Adjusted EBITDA                                   ___

(−) Cash taxes paid                                  (__)
(−) Change in working capital                        (__)
    Increase in receivables                          (__)
    Increase in inventory                            (__)
    Decrease in payables                             (__)
= Operating Cash Flow (OCF)                         ___

(−) Maintenance capex                                (__)
= Free Cash Flow (FCF) before growth                ___

(−) Growth capex                                     (__)
(−) Acquisitions                                     (__)
= Free Cash Flow (FCF) after growth                 ___

Debt Service:
(−) Interest payments (all debt)                     (__)
(−) Principal repayments (all debt)                  (__)
= Cash Flow after Debt Service                      ___

DSCR = (Adjusted EBITDA − Tax − Maintenance Capex) / (Interest + Principal)
     = ___ / ___
     = ___x
```

---

## NBFC Portfolio DD

For NBFC / fintech deals, the financial DD is supplemented with a full portfolio analysis:

### Data Tape Analysis

The borrower provides a loan-level data tape (every active loan with origination date, amount, rate, tenure, DPD status, collections to date).

```
Data Tape Fields Required:
- Loan ID
- Borrower segment (student, salaried, MSME, etc.)
- Origination date
- Disbursement amount
- Interest rate
- Tenure (months)
- Outstanding principal
- DPD bucket (0, 1-30, 31-60, 61-90, 90+, write-off)
- Total collections to date
- Last payment date
- Geographic location (state/city)
```

### Static Pool / Vintage Analysis

Group loans by origination month/quarter. For each vintage, track:

```
| Vintage | Disbursed (INR Cr) | 3m Collection % | 6m % | 12m % | Overall % |
|---------|-------------------|-----------------|------|-------|-----------|
| Q1 FY23 | ___ | ___% | ___% | ___% | ___% |
| Q2 FY23 | ___ | ___% | ___% | ___% | ___% |
| Q3 FY23 | ___ | ___% | ___% | ___% | ___% |
| Q4 FY23 | ___ | ___% | ___% | ___% | ___% |
```

**What to check:**
- Are newer vintages performing better or worse? (Deteriorating = credit model risk)
- Is there a "long tail" of recovery? (MPokket: 2% takes >12 months — unusual for short-tenor)
- How sensitive is recovery to macro conditions? (Compare vintages during stress periods)

### DuPont Decomposition

Break down NBFC profitability to understand sustainable earnings:

```
Yield on AUM                    ___%
(-) Cost of Debt               ___%
= Net Interest Margin (NIM)    ___%
(-) Operating Expenses          ___%
(-) Credit Costs               ___%
= Pre-Tax Return on AUM        ___%
× Leverage (AUM/Equity)        ___x
= Pre-Tax ROE                  ___%
```

---

## Output

The financial DD produces:
1. **Quality of earnings analysis** (adjusted EBITDA with all adjustments explained)
2. **Working capital analysis** (cycle days, normalization, funding assessment)
3. **Related party summary** (all RPTs assessed for arm's length)
4. **Cash flow bridge** (EBITDA → OCF → FCF → post-debt-service)
5. **Balance sheet verification notes** (assets confirmed, liabilities identified)
6. **NBFC portfolio analysis** (if applicable — vintage, DuPont, concentration)

These become the primary inputs for Stage 5 (Financial Model) — the model uses DD-validated, adjusted financials, not the raw audited numbers.
