# Stage 2.1: Terms Design

You are drafting the opening position for the Head of Terms. This document establishes the fund's ideal deal economics — the starting point from which negotiation will pull terms toward a middle ground.

---

## The Opening Position vs. Final Terms

The opening HoT is deliberately aggressive on fund-favorable terms. This is standard negotiation practice — you start higher on coupon, tighter on covenants, broader on security, and negotiate down. The IC-approved Concept Paper sets the floor below which you cannot go.

| Parameter | Opening Position (Fund-Favorable) | Typical Negotiated Outcome | Floor (IC Minimum) |
|-----------|----------------------------------|---------------------------|-------------------|
| Coupon | 13-14% | 11-12% | 10% (below this, returns don't work) |
| Upside Premium | 6-7% of exit EV | 5-6% | 4% (minimum equity kicker) |
| Make-Whole | 36 months | 24-30 months | 24 months |
| Security Coverage | 2.5x | 1.5-2.0x | 1.3x (minimum acceptable) |
| DSCR Covenant | 1.5x | 1.3x | 1.2x (below this, no early warning) |

---

## HoT Section-by-Section

### 1. Parties and Recitals

```
Issuer:         [Entity name]
Investor:       BPEA Credit Fund [X] / Ascertis Credit
Arranger:       [Investment bank, if applicable]
Date:           [Draft date]
Project Code:   [Codename]
```

### 2. Facility Details

| Parameter | Specification |
|-----------|--------------|
| **Instrument** | Senior Secured Listed/Unlisted NCDs [and/or CCDs] |
| **Facility Size** | INR ___ Cr |
| **Tranches** | [Single / describe each tranche with size and purpose] |
| **Tenure** | ___ months from first disbursement |
| **Coupon** | ___% p.a., payable quarterly/semi-annually |
| **Day Count** | Actual/365 |
| **Accrued Premium** | ___% p.a., payable on [maturity/exit/annually] |
| **Upside Premium** | ___% of Enterprise Value at exit |
| **Make-Whole** | ___% for first ___ months; ___% thereafter |
| **Listing** | BSE/NSE [if listed NCDs] |

### 3. Use of Proceeds

```
| Use                    | Amount (INR Cr) | % of Facility |
|------------------------|-----------------|---------------|
| Capex                  |                 |               |
| Acquisition            |                 |               |
| Refinancing            |                 |               |
| Working Capital        |                 |               |
| Transaction Costs      |                 |               |
| Total                  |                 | 100%          |
```

Red flag: If "refinancing" > 30%, probe why the existing lender is exiting.

### 4. Security Package

**Standard security suite for Ascertis Credit:**

| Security Type | Description |
|--------------|-------------|
| **First Exclusive Charge** | On all immovable and movable fixed assets of [Issuer + subsidiaries] |
| **First Pari Passu Charge** | On current assets (if applicable, usually for WC-heavy businesses) |
| **Share Pledge** | ___% of equity shares of [Operating Company] held by [Promoter/HoldCo] |
| **Corporate Guarantee** | From [Parent/HoldCo/Group Companies] |
| **Personal Guarantee** | From [Promoter Name(s)] |
| **Escrow Account** | [Cash flow sweep / portfolio collections escrow — esp. for NBFC] |
| **Negative Pledge** | No additional encumbrance on charged assets |
| **DSRA** | Debt Service Reserve Account — [X] months of debt service |

**For NBFC deals, replace fixed-asset security with:**

| Security Type | Description |
|--------------|-------------|
| **Portfolio Assignment** | First exclusive charge on identified portfolio with ___x cover |
| **Collection Account Escrow** | Daily sweep of portfolio collections to designated account |
| **Waterfall Mechanism** | Collections → Interest → Principal → Reserve → Release to borrower |
| **CRAR Floor** | Maintain CRAR above ___% |

### 5. Financial Covenants

Design covenants based on risks identified in the Concept Paper's risk register:

| Covenant | Level | Testing Frequency | Cure Period |
|----------|-------|-------------------|-------------|
| **Minimum DSCR** | ≥ ___x | Quarterly | ___ days |
| **Maximum Leverage** | ≤ ___x Net Debt/EBITDA | Quarterly | ___ days |
| **Minimum Net Worth** | ≥ INR ___ Cr | Annual | ___ days |
| **Minimum Current Ratio** | ≥ ___x | Quarterly | ___ days |
| **Maximum Capex** | ≤ INR ___ Cr per annum | Annual | None |

**NBFC-specific covenants:**

| Covenant | Level | Testing Frequency |
|----------|-------|-------------------|
| **Maximum GNPA** | ≤ ___% | Monthly |
| **Minimum Collection Efficiency** | ≥ ___% | Monthly |
| **Minimum CRAR** | ≥ ___% | Quarterly |
| **Maximum Single Borrower Exposure** | ≤ ___% of AUM | Quarterly |
| **ALM Mismatch** | Within ±___% per bucket | Quarterly |

### 6. Information Covenants

| Requirement | Frequency | Deadline |
|-------------|-----------|----------|
| Monthly MIS (P&L, key metrics) | Monthly | 15 days after month-end |
| Quarterly financial statements | Quarterly | 30 days after quarter-end |
| Annual audited financials | Annual | 90 days after FY-end |
| Compliance certificate | Quarterly | With quarterly financials |
| Board-approved budget | Annual | Before start of FY |
| Material event notification | As they occur | Within 3 business days |

### 7. Negative Covenants

| Restriction | Permitted Exception |
|------------|-------------------|
| No additional financial indebtedness | Permitted debt basket of INR ___ Cr |
| No dividend/distribution to equity | Until [DSCR > ___x / leverage < ___x] |
| No change of control | Without investor consent |
| No material asset disposal | Below INR ___ Cr threshold |
| No related party transactions | At arm's length, below INR ___ Cr |
| No change in business nature | Core business must remain ___% of revenue |

### 8. Conditions Precedent (CP)

Split into pre-disbursement and post-disbursement:

**Pre-Disbursement CPs:**
- Completion of financial, legal, commercial, and ESG DD
- Satisfactory legal opinion on structure and security
- Board and shareholder resolutions
- Security creation and perfection
- DSRA funded
- No material adverse change since CP date
- KYC/AML compliance
- [Deal-specific CPs from IC conditions]

**Post-Disbursement CPs (if any):**
- Mortgage registration (within ___ days)
- Insurance assignment (within ___ days)
- [Other administrative items that don't block disbursement]

### 9. Events of Default

Standard events + deal-specific triggers:
- Payment default (failure to pay interest or principal when due)
- Covenant breach (with cure period)
- Cross-default (default on any other debt > INR ___ Cr)
- Material adverse change
- Change of control without consent
- Misrepresentation
- Insolvency / NCLT proceedings
- Regulatory non-compliance (especially for NBFC)

### 10. Exclusivity and Confidentiality

| Term | Provision |
|------|----------|
| **Exclusivity Period** | ___ days from HoT execution |
| **Break Fee** | ___% of facility size if borrower terminates during exclusivity |
| **Confidentiality** | Standard mutual NDA terms |
| **Non-Binding** | Except for exclusivity, confidentiality, and cost-sharing provisions |

---

## Pricing the Deal

### Returns Framework

The associate must show the deal team that proposed terms achieve target returns:

```
Fixed Return:
  Coupon: ___% p.a. × ___ years = ___% cumulative
  Accrued Premium: ___% p.a. × ___ years = ___% cumulative

Variable Return:
  Upside Premium: ___% of Exit EV (at assumed ___x EV/EBITDA)

Total Expected IRR: ___%
```

Run at three scenarios:
1. **Base Case**: Management projections with Ascertis haircut (25% EBITDA reduction)
2. **Upside Case**: Management projections as-is
3. **Downside Case**: Flat EBITDA, no upside premium, scheduled repayment only

The IC needs to see that even in the Downside Case, the fixed return component meets the fund's hurdle rate.

---

## Output

The terms design produces:
1. **Complete draft HoT** (all sections populated)
2. **Negotiation brief** (which terms have room to move, which are non-negotiable)
3. **Returns sensitivity table** (IRR at different coupon/upside/exit scenarios)
4. **Covenant rationale document** (why each covenant level was chosen, what risk it monitors)

These feed into the Redline Tracker (`02-redline-tracker.md`) once the borrower responds.
