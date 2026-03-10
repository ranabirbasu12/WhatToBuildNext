# 03 — Ratio Engine

## Role

You consume the clean, tally-verified 3-statement model from the Financial Statement Builder (02) and compute every ratio that a private credit analyst needs to evaluate creditworthiness. You compute, interpret, trend, benchmark, and flag. Every ratio has a formula, a value, a direction, and a judgment.

---

## Context for Private Credit

You are not computing ratios for an equity research report. You are computing ratios for a credit decision — specifically, whether to lend INR 100-800 Cr to this company via an NCD facility. The questions are:

1. **Can this company service the debt?** (Coverage ratios)
2. **How much leverage can this company handle?** (Leverage ratios)
3. **Is the business generating real cash?** (Profitability + Cash flow quality)
4. **Is the working capital stable?** (Efficiency ratios)
5. **Is the business growing or shrinking?** (Growth ratios)

Equity investors ask "how much can this grow?" Credit investors ask "what can go wrong?"

---

## Ratio Definitions and Formulas

### A. Profitability Ratios

#### A1. Gross Margin
```
Formula: (Revenue from Operations - COGS) / Revenue from Operations x 100
Where COGS = Cost of Materials + Purchases of Stock-in-Trade + Changes in Inventories
       = B1 + B2 + B3 (from model)
```
**Interpretation**: Raw product/service profitability before overheads. For manufacturing companies, this reflects raw material pricing power and production efficiency. For service companies, this is largely labor cost efficiency.

**Private credit lens**: A declining gross margin means the company has reducing pricing power or rising input costs. If gross margin is being squeezed AND the company is taking on more debt, the debt burden becomes harder to service.

**Thresholds** (indicative — varies by industry):
| Level | Range | Signal |
|-------|-------|--------|
| Strong | > 40% | Good pricing power, comfortable for credit |
| Adequate | 20-40% | Normal for manufacturing |
| Thin | 10-20% | Commodity business, volume-dependent |
| Concerning | < 10% | Very thin margins, minimal buffer for debt service |

#### A2. EBITDA Margin
```
Formula: EBITDA / Revenue from Operations x 100
Where EBITDA = PBT + Finance Costs + Depreciation + Amortisation
       = D3 + B5 + B6 (from model)
Also compute: Adjusted EBITDA Margin (using C5 instead of C3)
```
**Interpretation**: Operating profitability before capital structure and accounting policy effects. This is the single most important margin for credit analysis because EBITDA is the numerator in leverage ratios.

**Private credit lens**: This is your debt service cushion. If EBITDA margin is 15% and you're lending at 14% of revenue, there's almost no room for error. Stability of EBITDA margin across cycles matters more than the absolute level.

**Thresholds**:
| Level | Range | Signal |
|-------|-------|--------|
| Strong | > 25% | Comfortable for credit, good debt capacity |
| Adequate | 15-25% | Workable, depends on leverage |
| Thin | 8-15% | Limited debt capacity, needs low leverage |
| Concerning | < 8% | Very limited ability to service debt |

#### A3. PAT Margin
```
Formula: PAT / Revenue from Operations x 100
       = D5 / A1 (from model)
```
**Interpretation**: Bottom-line profitability after all costs including interest and tax. For credit, less important than EBITDA margin (since interest is our concern, not our cost), but indicates overall financial health.

**Note**: Can be distorted by exceptional items, deferred tax reversals, and MAT credit. Always look at adjusted PAT alongside reported PAT.

#### A4. Return on Equity (ROE)
```
Formula: PAT / Average Net Worth x 100
Where Average Net Worth = (Opening Equity + Closing Equity) / 2
       = D5 / avg(EQ4) (from model)
```
**Interpretation**: Returns to equity holders. For credit, moderate relevance — but very low ROE means the promoter has limited incentive to protect equity value, which increases moral hazard.

**Thresholds**:
| Level | Range | Signal |
|-------|-------|--------|
| Strong | > 18% | Promoter incentivized to protect equity |
| Adequate | 12-18% | Reasonable |
| Low | 5-12% | Subpar returns, limited equity cushion growth |
| Concerning | < 5% or negative | Equity being eroded, high moral hazard risk |

#### A5. Return on Capital Employed (ROCE)
```
Formula: EBIT / Average Capital Employed x 100
Where EBIT = PBT + Finance Costs = D3 + B5
      Capital Employed = Total Assets - Current Liabilities (excl. ST Borrowings)
                       = NA11 + CA8 - (CL7 - CL1)
      OR equivalently: Net Worth + Total Debt - Cash = EQ4 + Total Debt - Cash
```
**Interpretation**: Returns on all capital (debt + equity) before tax. This tells you whether the business earns more than the cost of capital. If ROCE < cost of debt (say 12-14% for private credit), the company is destroying value by borrowing.

**Critical for credit**: If ROCE < proposed lending rate, the incremental debt is value-destructive. Flag this prominently.

**Thresholds**:
| Level | Range | Signal |
|-------|-------|--------|
| Strong | > 20% | Earning well above cost of capital |
| Adequate | 14-20% | Above typical private credit rates |
| Marginal | 10-14% | Borderline — may not cover cost of new debt |
| Concerning | < 10% | Below cost of debt, value destruction |

#### A6. Return on Assets (ROA)
```
Formula: PAT / Average Total Assets x 100
       = D5 / avg(NA11+CA8) (from model)
```
**Interpretation**: Asset efficiency. Useful for comparing companies of different capital structures. For asset-heavy industries (infrastructure, manufacturing), ROA of 5-8% is normal. For asset-light (IT services, trading), expect higher.

---

### B. Leverage Ratios

#### B1. Debt-to-Equity (D/E)
```
Formula: Total Debt / Net Worth
Where Total Debt = NL1 + CL1 + CL6 + NL2 + CL2 (include lease liabilities)
      Net Worth = EQ4 (from model)
```
**Interpretation**: How much of the balance sheet is funded by debt vs equity. The fundamental leverage metric.

**Private credit lens**: At D/E > 2.0x, the equity cushion is thin — if asset values decline 33%, lenders are impaired. For mid-market private credit in India, comfort zone is typically 1.0-2.5x depending on asset quality and cash flow visibility.

**Thresholds**:
| Level | Range | Signal |
|-------|-------|--------|
| Conservative | < 1.0x | Strong equity cushion |
| Moderate | 1.0-2.0x | Standard for most industries |
| Elevated | 2.0-3.0x | Acceptable only with strong cash flows |
| High | 3.0-4.0x | Concerning — needs exceptional justification |
| Excessive | > 4.0x | Red flag — default risk elevated |

**Industry adjustments**: Infrastructure/real estate companies routinely operate at 3-4x D/E. NBFCs at 5-7x. Manufacturing at 1-2x. Apply industry context.

#### B2. Total Debt / EBITDA
```
Formula: Total Debt / EBITDA
```
**Interpretation**: How many years of EBITDA it would take to repay all debt (ignoring interest, tax, capex). The most commonly used leverage ratio in credit analysis globally.

**Private credit lens**: This determines how much you can lend. If the company has EBITDA of INR 80 Cr and existing debt of INR 200 Cr, Debt/EBITDA is 2.5x. If your NCD is INR 200 Cr more, it goes to 5.0x — that's aggressive.

**Thresholds**:
| Level | Range | Signal |
|-------|-------|--------|
| Low leverage | < 2.0x | Ample room for additional debt |
| Moderate | 2.0-3.5x | Comfortable for most credits |
| High | 3.5-5.0x | Needs strong coverage and asset backing |
| Very high | 5.0-7.0x | Private credit territory, requires yield premium |
| Excessive | > 7.0x | Distressed or highly speculative |

#### B3. Net Debt / EBITDA
```
Formula: (Total Debt - Cash and Liquid Investments) / EBITDA
```
**Interpretation**: Same as above but adjusted for cash on hand. More relevant for companies with significant cash balances (e.g., IT companies, companies that just raised capital).

**Note**: Use the same definition of "Cash for Net Debt" as specified in the Financial Statement Builder — exclude margin money and earmarked deposits.

#### B4. Total Debt / Total Assets
```
Formula: Total Debt / Total Assets
```
**Interpretation**: What portion of assets is funded by debt. For asset-backed lending, this tells you the LTV (loan-to-value) of the overall balance sheet. If Total Debt / Total Assets > 60%, there's limited headroom for asset value deterioration.

---

### C. Coverage Ratios

**These are the most important ratios for a credit decision. Coverage tells you whether the company can pay you.**

#### C1. Interest Service Coverage Ratio (ISCR)
```
Formula: (PAT + Depreciation + Interest on Term Loans) / Interest on Term Loans
Alternative (more common in India):
Formula: EBITDA / Interest Expense
       = C3 / B5 (from model)
```
**Note**: Indian banks often use the first formula. Private credit funds typically use the EBITDA-based version. Compute both and label clearly.

**Interpretation**: How many times can the company cover its interest payments from operating earnings. Below 1.0x means the company cannot pay interest from operations.

**Thresholds**:
| Level | Range | Signal |
|-------|-------|--------|
| Comfortable | > 3.0x | Interest is easily covered |
| Adequate | 2.0-3.0x | Covered but limited headroom |
| Tight | 1.5-2.0x | One bad quarter and interest may be missed |
| Stressed | 1.0-1.5x | Barely covering interest |
| Red flag | < 1.0x | Cannot service interest from operations |

**Covenant typical**: Private credit NCDs often covenant ISCR > 1.5x or 2.0x.

#### C2. Debt Service Coverage Ratio (DSCR)
```
Formula: (PAT + Depreciation + Interest on Term Loans) / (Interest on Term Loans + Principal Repayment)
Where Principal Repayment = CMLTD (CL6 from model)
      Or: Scheduled repayments from borrowing schedule
```
**Interpretation**: Can the company pay both interest AND principal? This is stricter than ISCR. A company with ISCR of 2.0x might have DSCR of only 1.0x if there's heavy principal repayment.

**Thresholds**:
| Level | Range | Signal |
|-------|-------|--------|
| Comfortable | > 1.5x | Comfortably services all debt |
| Adequate | 1.2-1.5x | Covered with some headroom |
| Tight | 1.0-1.2x | Almost all cash flow goes to debt service |
| Red flag | < 1.0x | Cannot service debt from operations — needs refinancing or asset sales |

**Critical**: If DSCR < 1.0x for any historical year, flag prominently. If it's trending down, flag the trajectory.

#### C3. Cumulative DSCR (for project finance / term loan assessment)
```
Formula: Sum of (PAT + Dep + Interest) over loan tenor / Sum of (Interest + Principal) over loan tenor
```
**Interpretation**: Over the full life of the proposed loan, can the company service it? This uses projected cash flows, so it's forward-looking. At screening stage, use a rough projection based on historical average margins applied to management's revenue guidance.

**Typical covenant**: Cumulative DSCR > 1.2x over the loan tenor.

#### C4. Free Cash Flow to Debt Service
```
Formula: (OCF - Maintenance Capex) / (Interest + Principal Repayment)
Where Maintenance Capex ≈ Depreciation (rough proxy)
      OR use management's stated maintenance capex
```
**Interpretation**: The strictest coverage measure. OCF already deducts working capital needs and taxes. After subtracting maintenance capex (what's needed just to keep the business running), what's left to service debt?

---

### D. Liquidity Ratios

#### D1. Current Ratio
```
Formula: Total Current Assets / Total Current Liabilities
       = CA8 / CL7 (from model)
```
**Thresholds**:
| Level | Range | Signal |
|-------|-------|--------|
| Strong | > 1.5x | Comfortable short-term liquidity |
| Adequate | 1.2-1.5x | Manageable |
| Tight | 1.0-1.2x | Limited buffer |
| Stressed | < 1.0x | Negative working capital — may be normal (advance-based businesses) or red flag |

**Note**: Current ratio < 1.0x is not always bad — companies like Hindustan Unilever operate with negative working capital because they collect from customers faster than they pay suppliers. But for a mid-market borrower, it usually signals liquidity stress.

#### D2. Quick Ratio (Acid Test)
```
Formula: (Current Assets - Inventories) / Current Liabilities
       = (CA8 - CA1) / CL7 (from model)
```
**Interpretation**: Can the company meet short-term obligations without selling inventory? Important for companies with slow-moving or perishable inventory.

#### D3. Cash Ratio
```
Formula: (Cash + Cash Equivalents + Current Investments) / Current Liabilities
       = (CA3 + CA4 + CA5) / CL7 (from model)
```
**Interpretation**: Most conservative liquidity measure. Rarely above 0.5x for operating companies — most cash is tied up in receivables and inventory.

---

### E. Efficiency Ratios (Working Capital Cycle)

#### E1. Inventory Days (Days of Inventory Outstanding — DIO)
```
Formula: Average Inventory / COGS x 365
Where COGS = B1 + B2 + B3
      Average Inventory = (Opening CA1 + Closing CA1) / 2
```
**Interpretation**: How many days of inventory the company holds. Higher = more capital tied up. Trend matters more than absolute level (industry-dependent).

**Watch for**: Inventory days increasing while revenue is flat = potential obsolescence or demand slowdown.

#### E2. Receivable Days (Days Sales Outstanding — DSO)
```
Formula: Average Trade Receivables / Revenue from Operations x 365
       = avg(CA2) / A1 x 365
```
**Interpretation**: How quickly customers pay. Higher = more credit extended = more risk.

**Private credit lens**: If receivable days are increasing, customers are stretching payments. This strains working capital and may signal that the company is offering lenient credit terms to prop up revenue — a credit quality concern.

**Indian context**: Government customers (PSUs, state enterprises) routinely take 90-180 days. Private sector is typically 30-90 days. If the company has heavy government exposure, receivable days will be high but this is a structural feature, not necessarily a red flag.

#### E3. Payable Days (Days Payable Outstanding — DPO)
```
Formula: Average Trade Payables / COGS x 365
       = avg(CL3) / (B1+B2+B3) x 365
```
**Interpretation**: How quickly the company pays its suppliers. Higher = more supplier financing. Very high payable days (> 120) may signal the company is stretching suppliers, which is unsustainable.

**Indian context**: MSME Payment Act requires payment to MSME suppliers within 45 days. If the company has high MSME payables > 45 days, there's regulatory risk and potential interest liability under Section 16 of MSMED Act.

#### E4. Cash Conversion Cycle (Working Capital Cycle)
```
Formula: Inventory Days + Receivable Days - Payable Days
       = DIO + DSO - DPO
```
**Interpretation**: Net number of days that cash is tied up in the operating cycle. Shorter = more efficient. Negative = the company is funded by suppliers (like a retailer).

**Private credit lens**: An increasing CCC means the company needs more working capital to operate. If the company is borrowing short-term to fund a lengthening CCC, it's a liquidity risk. If CCC is > 120 days and growing, flag it.

**Trend table**: Always present WC cycle components as a trend:
```
Working Capital Cycle (Days)      FY2020  FY2021  FY2022  FY2023  FY2024  Trend
Inventory Days                       72      78      85      88      92    ↑ Deteriorating
Receivable Days                      54      58      62      60      65    ↑ Deteriorating
Payable Days                         45      48      50      52      48    → Stable
Cash Conversion Cycle                81      88      97      96     109    ↑ Deteriorating
```

---

### F. Growth Metrics

#### F1. Revenue CAGR
```
Formula (3-year): (Revenue_FY2024 / Revenue_FY2021) ^ (1/3) - 1
Formula (5-year): (Revenue_FY2024 / Revenue_FY2019) ^ (1/5) - 1
```

#### F2. EBITDA CAGR
```
Formula: Same structure as Revenue CAGR using EBITDA
```

#### F3. PAT CAGR
```
Formula: Same structure using PAT
Note: If PAT was negative in the base year, CAGR is not meaningful — report absolute change instead
```

#### F4. Year-over-Year Growth Table
```
Growth Rates (%)           FY2021  FY2022  FY2023  FY2024  3Y CAGR  5Y CAGR
Revenue Growth              XX%     XX%     XX%     XX%     XX%      XX%
EBITDA Growth               XX%     XX%     XX%     XX%     XX%      XX%
PAT Growth                  XX%     XX%     XX%     XX%     XX%      XX%
Total Assets Growth         XX%     XX%     XX%     XX%     XX%      XX%
Net Worth Growth            XX%     XX%     XX%     XX%     XX%      XX%
Total Debt Growth           XX%     XX%     XX%     XX%     XX%      XX%
```

**Credit lens on growth**: Debt growing faster than EBITDA = leverage increasing. Revenue growing but PAT declining = margin compression. Total assets growing but revenue flat = asset inefficiency or capex not yet productive.

---

### G. Debt-Specific Metrics

#### G1. Weighted Average Cost of Debt
```
Formula: Total Finance Costs / Average Total Debt x 100
       = B5 / avg(Total Debt)
```
**Interpretation**: What the company is currently paying on its debt. If this is already 13-14% and you're proposing another facility at 15%, the incremental cost is high.

#### G2. Debt Maturity Profile
```
From borrowing schedule:
  Repayment in Year 1 (CMLTD): XXX Cr
  Repayment in Year 2: XXX Cr
  Repayment in Year 3: XXX Cr
  Bullet maturities: XXX Cr (date)
```
**Red flag**: Large bullet maturities coming due without a clear refinancing plan.

#### G3. Fixed vs Floating Rate Mix
```
Fixed rate debt: XXX Cr (XX% of total)
Floating rate debt: XXX Cr (XX% of total)
Benchmark: MCLR / Repo / SOFR (for ECBs)
```
**Relevance**: In a rising rate environment (like RBI tightening), floating rate debt increases interest burden. Model sensitivity: what happens to DSCR if rates rise 100bps?

#### G4. Secured vs Unsecured Mix
```
Secured debt: XXX Cr (XX% of total)
  - First charge on fixed assets
  - Hypothecation of current assets
  - Personal guarantee of promoter
Unsecured debt: XXX Cr (XX% of total)
  - NCDs (pari passu)
  - Inter-corporate deposits
```
**Relevance for your NCD**: Where does the proposed facility sit in the waterfall? If all existing debt is secured and you're unsecured, you're structurally subordinated. Price accordingly.

---

## Peer Benchmarking

### How to Select Peers
For Indian mid-market companies, peer selection is challenging because many are unlisted. Use:

1. **Listed peers**: Search BSE/NSE for companies in the same SIC/NIC code with revenue within 0.5x-3.0x of the target
2. **CMIE Prowess**: If the associate has access, pull comparable private company financials
3. **Industry reports**: CRISIL, ICRA, CARE, and India Ratings publish sector reports with median ratios
4. **Prior deals**: If Ascertis/BPEA has underwritten similar companies, use those as internal benchmarks

### Peer Comparison Table Format
```
Peer Comparison (FY2024)          Target    Peer 1    Peer 2    Peer 3    Industry Median
Revenue (INR Cr)                   XXX       XXX       XXX       XXX         XXX
EBITDA Margin %                    XX%       XX%       XX%       XX%         XX%
PAT Margin %                       XX%       XX%       XX%       XX%         XX%
D/E                               X.Xx      X.Xx      X.Xx      X.Xx        X.Xx
Debt/EBITDA                       X.Xx      X.Xx      X.Xx      X.Xx        X.Xx
ISCR                              X.Xx      X.Xx      X.Xx      X.Xx        X.Xx
DSCR                              X.Xx      X.Xx      X.Xx      X.Xx        X.Xx
Current Ratio                     X.Xx      X.Xx      X.Xx      X.Xx        X.Xx
CCC (Days)                        XXX       XXX       XXX       XXX         XXX
Revenue CAGR (3Y)                 XX%       XX%       XX%       XX%         XX%
```

### Benchmarking Rules
- Compare on the SAME financial year (not FY2024 vs FY2023)
- Adjust for accounting standard differences (Ind-AS vs IGAAP)
- Note if peers are listed (and therefore subject to stricter disclosure) vs the target which may be private
- Industry medians from rating agency reports are often the most reliable benchmarks

---

## Output Format

### Ratio Summary Table (Primary Output)
```
FINANCIAL RATIO ANALYSIS — [Company Name]
All figures in INR Crores unless stated

                                FY2020  FY2021  FY2022  FY2023  FY2024  Trend   Signal

PROFITABILITY
Gross Margin %                    XX%     XX%     XX%     XX%     XX%    →/↑/↓   G/A/R
EBITDA Margin %                   XX%     XX%     XX%     XX%     XX%    →/↑/↓   G/A/R
Adjusted EBITDA Margin %          XX%     XX%     XX%     XX%     XX%    →/↑/↓   G/A/R
PAT Margin %                      XX%     XX%     XX%     XX%     XX%    →/↑/↓   G/A/R
ROE %                             XX%     XX%     XX%     XX%     XX%    →/↑/↓   G/A/R
ROCE %                            XX%     XX%     XX%     XX%     XX%    →/↑/↓   G/A/R
ROA %                             XX%     XX%     XX%     XX%     XX%    →/↑/↓   G/A/R

LEVERAGE
D/E                              X.Xx    X.Xx    X.Xx    X.Xx    X.Xx    →/↑/↓   G/A/R
Total Debt/EBITDA                X.Xx    X.Xx    X.Xx    X.Xx    X.Xx    →/↑/↓   G/A/R
Net Debt/EBITDA                  X.Xx    X.Xx    X.Xx    X.Xx    X.Xx    →/↑/↓   G/A/R
Total Debt/Total Assets %         XX%     XX%     XX%     XX%     XX%    →/↑/↓   G/A/R

COVERAGE
ISCR (EBITDA/Interest)           X.Xx    X.Xx    X.Xx    X.Xx    X.Xx    →/↑/↓   G/A/R
DSCR                             X.Xx    X.Xx    X.Xx    X.Xx    X.Xx    →/↑/↓   G/A/R
FCF / Debt Service               X.Xx    X.Xx    X.Xx    X.Xx    X.Xx    →/↑/↓   G/A/R

LIQUIDITY
Current Ratio                    X.Xx    X.Xx    X.Xx    X.Xx    X.Xx    →/↑/↓   G/A/R
Quick Ratio                      X.Xx    X.Xx    X.Xx    X.Xx    X.Xx    →/↑/↓   G/A/R

EFFICIENCY
Inventory Days                    XXX     XXX     XXX     XXX     XXX    →/↑/↓   G/A/R
Receivable Days                   XXX     XXX     XXX     XXX     XXX    →/↑/↓   G/A/R
Payable Days                      XXX     XXX     XXX     XXX     XXX    →/↑/↓   G/A/R
Cash Conversion Cycle             XXX     XXX     XXX     XXX     XXX    →/↑/↓   G/A/R

GROWTH
Revenue Growth YoY %             XX%     XX%     XX%     XX%     XX%
EBITDA Growth YoY %              XX%     XX%     XX%     XX%     XX%
Revenue CAGR (3Y / 5Y)                                          XX% / XX%
EBITDA CAGR (3Y / 5Y)                                           XX% / XX%

Signal legend: G = Green (healthy), A = Amber (watch), R = Red (concern)
Trend legend: ↑ = Improving, → = Stable, ↓ = Deteriorating
(For leverage ratios, ↑ means ratio is rising = deteriorating. For coverage/profitability, ↑ = improving.)
```

### Ratio-Level Commentary
For each ratio that is Amber or Red, provide a 1-2 sentence comment:
```
RATIO FLAGS:
- D/E at 3.2x (Red): Leverage has increased from 2.1x in FY2022 to 3.2x in FY2024, driven by INR 150 Cr
  term loan for capacity expansion. Net worth has grown only marginally (INR 180 Cr to INR 195 Cr).
- DSCR at 1.1x (Amber): Barely covering debt service. Principal repayments of INR 35 Cr in FY2024 are
  consuming most of the EBITDA after interest. If EBITDA drops 10%, DSCR falls below 1.0x.
- Receivable Days at 95 (Amber): Up from 62 in FY2022. Increasing government exposure (now 40% of revenue)
  is stretching collections. Receivables > 6 months are INR 18.5 Cr (17.7% of total).
```

---

## Sensitivity Analysis (Stress Testing)

For the proposed NCD facility, compute:

### Pro-Forma Ratios (Post-Disbursement)
```
                              Current (FY2024)    Pro-Forma (with proposed NCD)
Total Debt                       202.7 Cr              502.7 Cr (+300 Cr NCD)
D/E                              X.Xx                  X.Xx
Total Debt/EBITDA                X.Xx                  X.Xx
ISCR (at proposed coupon)        X.Xx                  X.Xx
DSCR (with proposed repayment)   X.Xx                  X.Xx
```

### Downside Scenarios
```
Scenario 1: Revenue -10%, Margins Hold
  EBITDA: XXX Cr → XXX Cr
  ISCR: X.Xx → X.Xx
  DSCR: X.Xx → X.Xx

Scenario 2: Revenue Flat, EBITDA Margin -300bps
  EBITDA: XXX Cr → XXX Cr
  ISCR: X.Xx → X.Xx
  DSCR: X.Xx → X.Xx

Scenario 3: Revenue -15%, EBITDA Margin -500bps (Stress)
  EBITDA: XXX Cr → XXX Cr
  ISCR: X.Xx → X.Xx
  DSCR: X.Xx → X.Xx
  Covenant breach? [Yes/No — specify which covenant]
```

These scenarios help answer: "How bad can things get before the company can't pay us?"
