# Skill: Working File / CMA Builder

> **Stage**: 0 — Screening
> **Input**: Extracted financials (from `02-financial-extraction.md`), raw data room files
> **Output**: Multi-sheet Excel workbook answering "does this deal pencil?"
> **Time budget**: 4-6 hours analyst time (AI-assisted: 1-2 hours)

---

## Purpose

The Working File is the ANALYTICAL layer on top of extracted financials. Raw financials tell you what happened. The Working File tells you whether the company can service the debt you're considering. Everything in this file exists to answer one question: **does the DSCR hold under stress?**

This is NOT the final credit model — that gets built from scratch during DD. The Working File is a disposable screening tool. What survives is the knowledge you build, not the spreadsheet.

---

## Working File Architecture

The Working File is a multi-sheet Excel workbook. Structure varies by deal type, but the core sheets are constant.

### Core Sheets (Every Deal)

| Sheet | Purpose | Key columns |
|-------|---------|-------------|
| **Summary** | One-page snapshot: Capacity, Revenue, EBITDA, EBITDA%, Debt, Debt/EBITDA, DSCR across historical + projected years | FY(H-3) to FY(H+5), e.g., FY21-FY28 |
| **DSCR + Leverage** | Full DSCR waterfall calculation, Management Case and Ascertis Case side by side | Same year range |
| **Entity Financials** | Standalone P&L, BS, CF for each entity in the group (consolidated if available) | 3-5 years historical + projections |
| **Run-rate** | 9M/6M actuals annualized vs full-year projections | Current partial year vs projection |
| **Debt Profile** | All existing debt: lender, facility type, outstanding, rate, tenure, repayment schedule | Current snapshot + maturity profile |
| **IRR Workings** | Return calculation for proposed facility by tranche | Per-tranche + blended |
| **Comments** | Questions/observations flagged during screen-share with senior | Line item reference + comment + status |

### Sector-Specific Sheets

| Sector | Additional Sheets |
|--------|-------------------|
| **Manufacturing** | Capacity Utilization, Peer Comparison, Subsidy/Incentive tracker |
| **NBFC/Fintech** | AUM build-up, Portfolio quality (DPD/NPA), ALM mismatch, Cohort analysis |
| **Infrastructure** | Order Book (summary + movement), Project-level margins, Bid pipeline |
| **Food/Agri** | Seasonality analysis, Procurement cost tracker, Cold chain capacity |

### Group Structure Sheets

When the borrower is part of a group (common), add per-entity sheets:

- `{Entity}_Stdl` — standalone financials for each entity (e.g., SAPL_Stdl, OSPL_Stdl)
- `{Entity}_Debt` — debt profile per entity
- Consolidated view rolling up to group level

---

## 1. Run-Rate Analysis

This is the single fastest way to test whether management projections are realistic. Do this FIRST.

### Method

```
Annualized Revenue = 9M Actual Revenue x (12/9)
                   = 9M Actual Revenue x 1.333

Annualized EBITDA  = 9M Actual EBITDA x (12/9)

Implied Q4 Revenue = FY Projection - 9M Actual
Implied Q4 EBITDA  = FY Projection - 9M EBITDA Actual
```

### What to Calculate

| Metric | 9M Actual | Annualized (x 12/9) | FY Projection | Gap % | Implied Q4 |
|--------|-----------|---------------------|---------------|-------|-------------|
| Revenue | | | | | |
| COGS | | | | | |
| Gross Profit | | | | | |
| EBITDA | | | | | |
| EBITDA % | | | | | |
| PAT | | | | | |

### Interpretation

- **Gap < 5%**: Projection looks achievable. Proceed with management numbers.
- **Gap 5-15%**: Projection is optimistic. Flag it. Use annualized as base case, management as upside.
- **Gap > 15%**: Projection is aggressive. Use annualized figure as YOUR base case. Ask management what they expect to change in Q4 that would justify the jump.
- **Negative gap** (annualized > projection): Unusual. Check if Q4 is seasonally weak (e.g., monsoon for agri, Q4 slowdown for infra). If not, management may be sandbagging — which is actually a mild positive for credit.

### Seasonality Adjustment

For sectors with known seasonality, adjust the annualization factor:

- **Food/Agri (e.g., Asandas potato procurement)**: Jan-Mar is peak procurement. 9M annualization will OVERSTATE full-year costs but may understate revenue if peak selling is Q4. Use prior-year quarterly splits to weight.
- **Infrastructure**: Q4 is typically strongest (fiscal year-end billing push). 9M annualization may UNDERSTATE revenue.
- **NBFC**: Relatively even, but watch for quarter-end disbursement spikes.

If 6M actuals are available instead of 9M, use the same method (x 12/6 = x 2) but note that 6M annualization is less reliable. Flag wider confidence intervals.

---

## 2. DSCR Calculation

**DSCR is the most important screening metric.** This is what the IC cares about. Everything else is context for the DSCR.

### DSCR Waterfall

```
Revenue
(-) COGS
= Gross Profit
(-) Operating Expenses (excl. depreciation)
= EBITDA

EBITDA
(-) Tax (use effective tax rate from historicals, or 25% if new regime)
(-) Maintenance Capex (not growth capex — ask management to split)
(-) Net Working Capital Change (increase = cash outflow)
= Cash Available for Debt Servicing (CFADS)

Interest on all debt (existing + proposed)
(+) Principal repayment on all debt (existing + proposed)
= Total Debt Servicing

DSCR = CFADS / Total Debt Servicing
```

### Two Cases — Always

| | Management Case | Ascertis Case |
|---|---|---|
| EBITDA | Management projection | Management projection x 0.75 (25% haircut) |
| Revenue | Management projection | Management projection x 0.85-0.90 (10-15% haircut) |
| Costs | Management projection | Held constant (no relief on costs) |
| Capex | Management projection | Management projection (no relief) |
| WC days | Management projection | +5-10 days on receivables (slower collection) |

The 25% EBITDA haircut is the Ascertis standard stress case. It answers: "if the company performs 25% worse than they promise, can they still pay us?"

### DSCR Output Table

| Metric | FY25 | FY26 | FY27 | FY28 | FY29 | FY30 |
|--------|------|------|------|------|------|------|
| **Management Case** | | | | | | |
| EBITDA | | | | | | |
| CFADS | | | | | | |
| Debt Servicing | | | | | | |
| **DSCR** | | | | | | |
| **Ascertis Case** | | | | | | |
| EBITDA (75%) | | | | | | |
| CFADS | | | | | | |
| Debt Servicing | | | | | | |
| **DSCR** | | | | | | |

### DSCR Thresholds

- **> 1.5x** (Ascertis Case): Comfortable. Strong debt serviceability.
- **1.2x - 1.5x** (Ascertis Case): Acceptable. Needs strong security and promoter.
- **1.0x - 1.2x** (Ascertis Case): Tight. Needs exceptional circumstances to proceed (very strong security, short tenor, known cash flow lumpiness).
- **< 1.0x** (Ascertis Case): The company cannot service debt under stress. Kill unless there is a very specific structural reason (e.g., bullet repayment with clear refinancing path).

### Common DSCR Pitfalls

- **Forgetting existing debt servicing**: DSCR must include ALL debt, not just the proposed facility. Pull the full debt schedule.
- **Using EBITDA as CFADS**: EBITDA is not cash. Tax, capex, and WC changes must be deducted.
- **Ignoring WC seasonality**: A company with 90-day receivables and 30-day payables has a structural WC drag. Model it.
- **Maintenance vs growth capex**: Growth capex is discretionary and can be deferred. Maintenance capex cannot. Ask management to split. If they can't, assume 30-40% of total capex is maintenance.

---

## 3. Debt/EBITDA Trajectory

### What to Show

| Metric | FY23A | FY24A | FY25E | FY26E | FY27E | FY28E |
|--------|-------|-------|-------|-------|-------|-------|
| Total Debt | | | | | | |
| EBITDA | | | | | | |
| **Debt/EBITDA** | | | | | | |
| Net Debt | | | | | | |
| **Net Debt/EBITDA** | | | | | | |

### The Leverage Story

Every deal has a leverage story. The pattern is almost always:

1. **Current leverage**: Where they are today (e.g., 3.5x)
2. **Peak leverage**: When the proposed facility is fully drawn (e.g., 4.5x — this is the moment of maximum risk)
3. **Deleveraging glide path**: How leverage comes down as EBITDA grows and principal is repaid (e.g., 4.5x → 3.0x → 2.0x over 3-4 years)

**What the IC wants to see**: Peak leverage < 4.0-4.5x, with a credible glide path to < 3.0x within the facility tenor.

### Thresholds

- **< 3.0x**: Comfortable leverage for most sectors.
- **3.0x - 4.0x**: Acceptable if deleveraging trajectory is clear.
- **4.0x - 5.0x**: Elevated. Needs strong EBITDA growth or asset backing.
- **> 5.0x**: Red flag. Very few screening-stage deals survive this unless asset-backed or NBFC (different leverage norms).

---

## 4. IRR Workings

### Structure

Private credit facilities often have multiple tranches. Calculate IRR for each tranche AND blended.

```
Facility Structure Example (from Omsairam HoT):
- RPS (Redeemable Preference Shares)
- F1S1 (Facility 1, Series 1)
- F1S2 (Facility 1, Series 2)
- F2S1 (Facility 2, Series 1)
- F2S2 (Facility 2, Series 2)
```

### IRR Components

For each tranche, model the cash flows:

| Quarter | Disbursement | Upfront Fee | Coupon | Principal | Equity Kicker | Net Cash Flow |
|---------|-------------|-------------|--------|-----------|---------------|---------------|
| Q0 | (100) | 2.0 | | | | (98.0) |
| Q1 | | | 3.5 | | | 3.5 |
| ... | | | | | | |
| Qn | | | 3.5 | 100 | 5.0 | 108.5 |

### IRR Output

| Tranche | Coupon | Upfront Fee | Tenor | IRR (Mgmt Case) | IRR (Ascertis Case) |
|---------|--------|-------------|-------|------------------|---------------------|
| RPS | | | | | |
| F1S1 | | | | | |
| F1S2 | | | | | |
| F2S1 | | | | | |
| F2S2 | | | | | |
| **Blended** | | | | | |

### Target IRR

- **Fund target**: 15-18% gross IRR (typical for Indian private credit)
- **Ascertis Case IRR**: Should still be > 14% after EBITDA haircut (delayed repayments, not coupon default)
- If IRR < 14% in Ascertis Case, either restructure the facility (higher coupon, larger equity kicker, shorter tenor) or reconsider the deal

---

## 5. Working Capital Analysis

### Core Metrics

| Metric | FY22A | FY23A | FY24A | FY25E | 9M Annualized |
|--------|-------|-------|-------|-------|---------------|
| Receivable Days | | | | | |
| Inventory Days | | | | | |
| Payable Days | | | | | |
| **Net WC Days** | | | | | |
| WC as % Revenue | | | | | |
| Absolute WC (Cr) | | | | | |

### Formulas

```
Receivable Days = (Trade Receivables / Revenue) x 365
Inventory Days  = (Inventory / COGS) x 365
Payable Days    = (Trade Payables / Purchases) x 365
Net WC Days     = Receivable Days + Inventory Days - Payable Days
WC as % Revenue = (Net Working Capital / Revenue) x 100
```

### What to Watch

- **Increasing receivable days**: Customer is stretching payments. Could indicate weak bargaining position or revenue quality issues.
- **Increasing inventory days**: Slow-moving stock, overproduction, or demand weakness.
- **Decreasing payable days**: Suppliers tightening terms. Could signal credit quality concerns from the supply side.
- **WC > 25% of revenue**: Heavy WC business. Ensure WC funding is in place and not dependent on the proposed facility.

### WC Limit Utilization (If Available)

From bank statements or CA certificates:

| Month | Sanctioned Limit | Peak Utilization | Avg Utilization | Util % |
|-------|-----------------|-----------------|-----------------|--------|
| Apr | | | | |
| May | | | | |
| ... | | | | |

- **Avg utilization > 90%**: Company is stretched on WC. Any revenue growth will need incremental WC funding.
- **Avg utilization < 60%**: Comfortable WC headroom. Proposed facility is likely growth/capex funding, not WC gap-filling.

---

## 6. Customer/Revenue Concentration

### Revenue Concentration Table

| Customer | FY23 Rev | % | FY24 Rev | % | 9M FY25 Rev | % | Trend |
|----------|----------|---|----------|---|-------------|---|-------|
| Customer A | | | | | | | |
| Customer B | | | | | | | |
| ... | | | | | | | |
| **Top 5** | | | | | | | |
| **Top 10** | | | | | | | |
| Others | | | | | | | |
| **Total** | | | | | | | |

### Customer Movement Analysis

| Category | FY23→FY24 | FY24→9M FY25 |
|----------|-----------|---------------|
| Retained customers (revenue) | | |
| New customers (revenue) | | |
| Lost customers (revenue) | | |
| **Net addition** | | |

### Concentration Thresholds

- **Top customer < 15% of revenue**: Healthy diversification.
- **Top customer 15-30%**: Concentration risk but manageable. Understand the relationship depth.
- **Top customer > 30%**: Material concentration risk. Understand contractual protections, relationship history, switching costs.
- **Top 5 > 60%**: Elevated concentration. Deep dive into each of the top 5.

### Revenue Cuts (Where Available)

Build pivot tables for:
- Revenue by product/segment
- Revenue by geography/region
- Revenue by specification (e.g., diameter for pipe manufacturers — Casablanca)
- Revenue by channel (direct vs dealer vs institutional)

---

## 7. Peer Comparison

### Peer Selection

- Listed peers in the same sector and similar scale
- Rated peers (pull from rating rationales — ICRA, CRISIL, India Ratings, CARE)
- Direct competitors mentioned by the company

### Comparison Table

| Metric | Target Co. | Peer 1 | Peer 2 | Peer 3 | Sector Median |
|--------|-----------|--------|--------|--------|---------------|
| Revenue (Cr) | | | | | |
| Revenue Growth (3Y CAGR) | | | | | |
| EBITDA Margin | | | | | |
| PAT Margin | | | | | |
| Debt/EBITDA | | | | | |
| DSCR | | | | | |
| ROE | | | | | |
| ROCE | | | | | |
| WC Days | | | | | |

### Sources for Peer Data

- Annual reports (BSE/NSE filings for listed peers)
- Rating rationales (ICRA, CRISIL, India Ratings, CARE — these often have peer comparison tables)
- PrivCircle, Tofler, MCA filings for unlisted peers
- Industry reports (IBEF, FICCI, sector associations)

---

## 8. Capacity Utilization (Manufacturing)

### Capacity Table

| Parameter | FY22A | FY23A | FY24A | FY25E | FY26E | FY27E |
|-----------|-------|-------|-------|-------|-------|-------|
| Installed Capacity (MT/units) | | | | | | |
| Actual Production | | | | | | |
| **Utilization %** | | | | | | |
| Realisation (Rs/unit) | | | | | | |
| Capacity Addition (if any) | | | | | | |

### What to Watch

- **Utilization > 85%**: Company needs capacity expansion to grow. Capex-funded deal makes sense.
- **Utilization 60-85%**: Room to grow without capex. If they're asking for capex funding, ask why they aren't filling existing capacity first.
- **Utilization < 60%**: Demand problem. Why are they not selling what they can already make? Red flag for capacity expansion funding.

### Capex Plan Linkage

If the proposed facility is for capex:
- What capacity is being added? (MT, units, lines)
- What is the project cost? How is it being funded? (debt/equity split)
- When does new capacity come online?
- What utilization is assumed for new capacity in year 1, year 2, year 3?
- Is there offtake visibility for the new capacity? (contracts, LOIs, order book)

---

## 9. The Comments Column

This is the most underrated part of the Working File. During the screen-share walkthrough with your senior (VP/Principal), you maintain a dedicated "Comments" column next to each financial line item.

### How It Works

1. **Setup**: Add a column labeled "Comments / Questions" to the right of each financial sheet.
2. **During screen-share**: As the senior reviews numbers, they'll ask questions or make observations. Capture them immediately.
3. **Post-meeting**: Categorize each comment.

### Comment Categories

| Tag | Meaning | Action |
|-----|---------|--------|
| `[Q-MGMT]` | Question to ask management in the next meeting | Add to management meeting agenda |
| `[Q-INTERNAL]` | Internal question (check with legal, compliance, ops) | Route to relevant internal team |
| `[FLAG]` | Risk flag or anomaly spotted | Add to risk register, investigate |
| `[VERIFY]` | Number needs verification (cross-check with another source) | Verify before CP stage |
| `[NOTE]` | Observation, no action needed | Retain for context |

### Example Comments

```
Revenue FY24: 450 Cr → [Q-MGMT] Revenue jumped 35% YoY. What drove this? New customer or volume?
EBITDA% FY24: 22% → [FLAG] Margin expanded 400bps. Is this sustainable or one-off (subsidy, input cost)?
Receivable Days: 95 → [Q-MGMT] Why are receivable days so high? Who are the slow payers?
Promoter Salary: 8 Cr → [VERIFY] Check against industry norms. Seems high for this scale.
Related Party Txn: 15 Cr → [FLAG] Need full list of related parties and nature of transactions.
```

### What the Comments Column Becomes

The Comments Column is NOT throwaway. It feeds directly into:
- **IRL (Information Request List)**: Every `[Q-MGMT]` and `[VERIFY]` becomes an IRL item
- **Management meeting agenda**: `[Q-MGMT]` items in priority order
- **Risk section of Concept Paper**: Every `[FLAG]` needs a response before the CP is written
- **DD scope**: Aggregated flags define where the DD needs to dig deeper

---

## 10. Sector-Specific Variants

### Manufacturing

**Additional analyses**:
- **Raw material cost trends**: Track key RM prices (steel, polymer, cotton, etc.) over 12-24 months. Is margin at risk from RM inflation?
- **Order book analysis**: For B2B manufacturers, order book provides revenue visibility.
  - Order book / trailing revenue = months of visibility
  - Order book composition (repeat vs new customers)
  - Order book execution rate (how much converts to revenue per quarter)
- **Subsidy/incentive dependency**: Some manufacturers (especially in Gujarat, AP, Telangana) receive state subsidies. Quantify: what is EBITDA margin WITHOUT subsidies? If margin is sub-15% without subsidies, flag it.
- **Capacity model**: Build a bottoms-up revenue model from capacity x utilization x realization. Cross-check against top-down revenue projections.

### NBFC / Fintech

**Replace several standard analyses with NBFC-specific ones**:
- **AUM growth and composition**: AUM by product, geography, ticket size. Growth rate and mix shift.
- **Portfolio quality**: DPD buckets (0, 1-30, 31-60, 61-90, 90+), GNPA, NNPA trends. Cohort-level analysis if available.
- **Collection efficiency**: Month-on-month collection rates. Is it > 95%? Trend direction matters.
- **CRAR (Capital to Risk-weighted Assets Ratio)**: Regulatory minimum 15%. Where are they? What's the trajectory post-disbursement?
- **ALM mismatch**: Assets vs liabilities maturity profile. Negative cumulative mismatch in near-term buckets is a red flag.
- **APR/ROI calculation**: Effective lending rate. Compare to cost of funds. NIM (Net Interest Margin) sustainability.
- **Leverage**: Different norms. Debt/Equity up to 5-6x is normal for NBFCs. Use Debt/Equity and Debt/AUM instead of Debt/EBITDA.
- **Borrowing mix**: Bank lines vs NCDs vs securitization vs DFI. Diversification of funding sources.

### Infrastructure

**Additional analyses**:
- **Order book deep-dive**:
  - Total order book value, value remaining, time remaining
  - Order book by client (government vs private)
  - Bid pipeline (bids submitted, success rate)
  - Order book / revenue = years of visibility (should be > 2x)
- **Project-level margins**: Not all projects are equal. Gross margin by project. Identify margin-dilutive projects.
- **Subcontracting %**: What portion of work is subcontracted? High subcontracting (> 40%) means lower control over execution and margins.
- **Retention money / claims**: Outstanding retention money and claims. These are quasi-receivables. Large outstanding claims against government entities can be slow to resolve.
- **Mobilization advances**: How much advance does the company receive at project start? This is a WC benefit.

### Food / Agri

**Additional analyses**:
- **Seasonality mapping**: Map procurement cycles (e.g., potato: Jan-Mar, kharif crops: Jun-Sep, rabi: Oct-Dec). Understand when cash outflows peak vs when revenue comes in.
- **Procurement cost analysis**: Track RM costs by season. For commodity processors, procurement cost IS the business.
- **Cold chain / storage capacity**: For perishable goods processors, storage capacity = ability to manage seasonality. Utilization of cold storage through the year.
- **Wastage rates**: Industry-specific but important. For food processors, 2-5% wastage is normal. Higher rates indicate supply chain issues.
- **Harvest risk**: Single-crop dependency = weather risk. Is there crop/geography diversification?

---

## Building the Working File — Step by Step

### Step 1: Set Up the Structure
Create the workbook with the core sheets listed above. Add sector-specific sheets as needed.

### Step 2: Populate Entity Financials
Pull from the extracted financials (02-financial-extraction output). One sheet per entity, standalone basis. Add consolidated if available.

### Step 3: Run the Run-Rate Analysis
This takes 15 minutes and immediately tells you if projections are real. Do it before anything else.

### Step 4: Build the DSCR Waterfall
Both Management Case and Ascertis Case. This is the heart of the Working File.

### Step 5: Calculate IRR
Model the proposed facility structure. If the HoT (Heads of Terms) exists, use those terms. If not, use indicative terms from the origination team.

### Step 6: Build Supporting Analyses
WC analysis, customer concentration, capacity utilization — in order of relevance to the specific deal.

### Step 7: Screen-Share with Senior
Walk through the Working File with your VP/Principal. Populate the Comments Column in real-time.

### Step 8: Export Key Findings
The Working File feeds into `04-screening-verdict.md`. Extract:
- DSCR trajectory (both cases)
- Key leverage metrics
- Red flags from Comments Column
- Run-rate vs projection gap

---

## Quality Checks Before Moving to Verdict

- [ ] Run-rate analysis done and gap quantified
- [ ] DSCR calculated for both Management and Ascertis cases
- [ ] DSCR includes ALL debt (existing + proposed), not just proposed facility
- [ ] Debt/EBITDA trajectory shows peak and glide path
- [ ] IRR meets fund threshold (>15% Management Case, >14% Ascertis Case)
- [ ] WC analysis flags any structural concerns
- [ ] Customer concentration quantified
- [ ] Comments Column populated from senior walkthrough
- [ ] All `[Q-MGMT]` items compiled for management meeting agenda
- [ ] All `[FLAG]` items logged for risk assessment
