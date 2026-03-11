# Stage 2.3: Covenant Framework

You are designing the covenant suite for the deal. Covenants are the fund's early warning system — they detect deterioration before it becomes a crisis. Too tight and they trigger false alarms; too loose and they're meaningless.

---

## Covenant Philosophy

Private credit covenants serve three purposes:

1. **Early warning**: Detect financial deterioration before default (DSCR, leverage)
2. **Behavior control**: Prevent the borrower from doing things that harm the fund (negative covenants)
3. **Information flow**: Ensure the fund has visibility into the business (information covenants)

The goal is NOT to make covenants so tight that every quarterly test is a potential default. The goal is to set trip-wires at the point where fund action (waiver negotiation, restructuring discussion, additional security) would be timely and effective.

---

## Financial Covenant Design

### DSCR (Debt Service Coverage Ratio)

The most important covenant for private credit.

```
DSCR = (EBITDA - Tax - Maintenance Capex) / (Interest + Principal Repayment)

Where:
- EBITDA: trailing 12-month
- Tax: cash taxes paid
- Maintenance Capex: recurring capex (not growth capex)
- Interest: all interest payments (not just this facility)
- Principal: all scheduled principal payments (not just this facility)
```

**Level-Setting Framework:**

| DSCR Level | Interpretation | When to Use |
|-----------|---------------|-------------|
| ≥ 2.0x | Very comfortable | Low-risk, high cash flow businesses |
| 1.5-2.0x | Comfortable with headroom | Standard manufacturing, services |
| 1.3-1.5x | Adequate | Cyclical businesses, moderate leverage |
| 1.0-1.3x | Tight — requires active monitoring | High leverage, turnaround situations |
| < 1.0x | Default territory | Cash flow cannot cover debt service |

**How to set the covenant level:**

```
Step 1: Calculate current DSCR → [___x]
Step 2: Calculate DSCR under Ascertis Case (25% EBITDA haircut) → [___x]
Step 3: Set covenant at midpoint between Ascertis Case and 1.0x
Step 4: Verify headroom is 15-25% below current level

Example:
  Current DSCR: 1.8x
  Ascertis Case DSCR: 1.35x
  Midpoint (1.35x + 1.0x) / 2 = 1.18x → round up to 1.2x
  Headroom: (1.8 - 1.2) / 1.8 = 33% → adequate
  Covenant: 1.2x (but may negotiate up to 1.3x for fund protection)
```

### Leverage (Net Debt / EBITDA)

```
Net Debt / EBITDA = (Total Debt - Cash & Cash Equivalents) / EBITDA

Where:
- Total Debt: all financial indebtedness (not just this facility)
- Cash: freely available cash (exclude restricted cash, DSRA)
- EBITDA: trailing 12-month
```

**Level-Setting:**

| Entry Leverage | Covenant Maximum | Rationale |
|---------------|-----------------|-----------|
| < 3.0x | 4.0-4.5x | Low entry, generous headroom |
| 3.0-4.0x | 5.0-5.5x | Standard — headroom for cyclical dip |
| 4.0-5.0x | 6.0-6.5x | Tight — rely on deleveraging trajectory |
| > 5.0x | Case-by-case | Very tight — need strong deleveraging evidence |

Include a **step-down schedule** for high-entry-leverage deals:

```
| Year | Maximum Net Debt / EBITDA |
|------|--------------------------|
| Y1   | 6.5x (entry headroom)    |
| Y2   | 5.5x                     |
| Y3   | 4.5x                     |
| Y4+  | 4.0x                     |
```

### Minimum Net Worth

```
Minimum Net Worth = Net Worth at disbursement × (1 - acceptable erosion %)

Typical: 80-90% of net worth at disbursement date
Purpose: Prevents equity erosion through losses or distributions
```

### Current Ratio

```
Current Ratio = Current Assets / Current Liabilities

Typical covenant: ≥ 1.1x to 1.25x
Purpose: Ensures short-term liquidity

Note: Less meaningful for seasonal businesses (Asandas: 164-day WC cycle
means current ratio swings dramatically through the year).
Consider testing at year-end only for seasonal businesses.
```

---

## NBFC-Specific Covenants

For NBFC / fintech deals, financial covenants are supplemented with portfolio covenants:

### Portfolio Quality

| Covenant | Level | Testing | Source |
|----------|-------|---------|--------|
| **Maximum GNPA** | ≤ ___% of AUM | Monthly | Borrower MIS |
| **Maximum NNPA** | ≤ ___% of AUM | Monthly | Borrower MIS |
| **Minimum Collection Efficiency** | ≥ ___% | Monthly | Collection data |
| **Maximum DPD 90+** | ≤ ___% of portfolio | Monthly | Aging report |

### Regulatory

| Covenant | Level | Testing | Source |
|----------|-------|---------|--------|
| **Minimum CRAR** | ≥ ___% (RBI minimum + buffer) | Quarterly | RBI filings |
| **ALM Mismatch** | Within ±___% per bucket | Quarterly | ALM report |
| **Single Borrower Exposure** | ≤ ___% of AUM | Quarterly | Portfolio report |

### Portfolio Concentration

| Covenant | Level | Testing |
|----------|-------|---------|
| **Maximum single industry exposure** | ≤ ___% of AUM | Quarterly |
| **Maximum geographic concentration** | ≤ ___% in any state | Quarterly |
| **Maximum ticket size** | ≤ INR ___ per borrower | Ongoing |

---

## Negative Covenants (Behavior Restrictions)

### Standard Suite

| Covenant | Restriction | Typical Carve-Out |
|----------|------------|-------------------|
| **Additional Indebtedness** | No new debt without consent | Permitted debt basket: INR ___ Cr for [WC/trade] |
| **Dividend / Distribution** | No payments to equity holders | Permitted if DSCR > ___x AND leverage < ___x |
| **Asset Disposal** | No sale of assets above threshold | Below INR ___ Cr per annum (ordinary course) |
| **Related Party Transactions** | At arm's length only | Below INR ___ Cr or with prior approval |
| **Change of Control** | Require fund consent | N/A — no carve-out |
| **Change of Business** | Core business ≥ ___% of revenue | N/A |
| **Capital Expenditure** | Annual capex limit of INR ___ Cr | Maintenance capex excluded |
| **Investments** | No new investments without consent | Below INR ___ Cr in subsidiaries |
| **Mergers / Amalgamation** | Require fund consent | N/A |

### Sizing the Permitted Debt Basket

```
Facility Size: INR ___ Cr
Current Other Debt: INR ___ Cr
Total Debt Capacity at Max Leverage Covenant: INR ___ Cr

Basket = Total Capacity - Facility Size - Current Other Debt
If Basket < 0 → no basket (leverage already at covenant limit)
If Basket > 0 → cap at min(Basket, 15% of Facility Size)
```

---

## Information Covenants

| Deliverable | Frequency | Deadline | What to Check |
|-------------|-----------|----------|---------------|
| **Monthly MIS** | Monthly | T+15 days | P&L, balance sheet, key KPIs, cash position |
| **Quarterly Financials** | Quarterly | T+30 days | Reviewed financials, covenant compliance certificate |
| **Annual Audited** | Annual | T+90 days (FY-end) | Full audit with notes, management letter |
| **Annual Budget** | Annual | Before FY start | Board-approved operating budget + capex plan |
| **Compliance Certificate** | Quarterly | With quarterly financials | Signed by CFO, confirming all covenants met |
| **Material Event Notice** | As occurs | T+3 business days | Any event that could materially affect ability to repay |
| **Insurance Certificates** | Annual | On renewal | Proof of adequate insurance on charged assets |

---

## Cure Periods and Remedies

### Standard Cure Framework

| Covenant Type | Cure Period | Remedy If Not Cured |
|---------------|-------------|---------------------|
| Financial (DSCR, leverage) | 30 days | Event of Default; acceleration right |
| Net worth | 60 days | Event of Default (equity injection takes time) |
| Information | 15 days | Warning → 30 days → Event of Default |
| Negative (indebtedness, disposal) | None — breach is immediate | Event of Default |
| Payment default | 5-7 business days | Event of Default; acceleration |

### Equity Cure Rights

Some borrowers negotiate the right to cure financial covenant breaches by injecting equity:

```
Equity Cure: Promoter may inject equity (not debt) to cure DSCR or leverage breach.

Conditions:
- Maximum [2-3] equity cures during facility life
- No consecutive quarterly cures
- Equity must be permanent (not redeemable)
- Injected within cure period
- Pro-forma compliance after injection
```

This is a reasonable borrower ask — it keeps the deal alive through temporary dips while ensuring promoter has skin in the game.

---

## Testing Mechanics

### Testing Calendar

```
FY Quarter Ends: Jun 30, Sep 30, Dec 31, Mar 31

Covenant Testing Timeline:
  Quarter ends → 30 days → Financials due → 15 days → Compliance certificate due

  Covenant calculated on trailing 12-month basis (annualized for partial periods)

  First test: [First full quarter after disbursement]
  Last test: [Quarter before maturity]
```

### Testing Methodology

```
DSCR Test:
1. Take trailing 12-month EBITDA from quarterly financials
2. Subtract cash taxes paid in the period
3. Subtract maintenance capex (define clearly — not growth capex)
4. Divide by total debt service (interest + principal on ALL debt)
5. Compare to covenant floor

Leverage Test:
1. Take total financial debt from quarterly balance sheet
2. Subtract freely available cash (not restricted, not DSRA)
3. Divide by trailing 12-month EBITDA
4. Compare to covenant ceiling
```

**Critical**: Define every term precisely in the HoT. Ambiguity in definitions creates disputes at testing time. Common arguments:
- What counts as "maintenance capex" vs. growth capex?
- Is DSRA balance included or excluded from "cash"?
- Are one-time items included or excluded from EBITDA?
- Does "total debt" include lease liabilities (Ind-AS 116)?

---

## Output

The covenant framework produces:
1. **Complete covenant suite** (financial, negative, information, NBFC-specific if applicable)
2. **Covenant level rationale** (why each level was chosen, backed by financial analysis)
3. **Testing mechanics document** (frequency, methodology, definitions)
4. **Sensitivity analysis** (at what EBITDA decline does each covenant trip?)
5. **Cure mechanism design** (periods, equity cure rights, remedies)

This feeds directly into the final HoT and eventually into the legal documentation at Stage 8 (Execution). The covenant levels also become model inputs at Stage 5 (Financial Model) for covenant testing scenarios.
