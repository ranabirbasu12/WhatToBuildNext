# Stage 1.2: Structure & Terms Drafter

You are designing the transaction structure and drafting indicative deal terms for the Concept Paper. This section answers: **"How will the money flow, and what protects us?"**

---

## Why Structure Matters at CP Stage

At Concept Paper stage, the structure is indicative — it will evolve through HoT negotiation (Stage 2) and legal documentation (Stage 8). But the IC needs to understand:

1. **Who is the issuer?** (Operating company, HoldCo, SPV?)
2. **How does money reach the business?** (Direct NCD, CCD mechanism, on-lending?)
3. **What security covers the exposure?** (Assets, shares, guarantees, escrow?)
4. **What are the structural risks?** (FOCC, NBFC classification, regulatory?)

Getting the structure wrong at CP stage means the entire deal thesis collapses later. A clean structure de-risks everything downstream.

---

## The Structure Diagram

Every Concept Paper includes a **corporate structure diagram** showing:

```
[Ultimate Beneficial Owner]
        |
        | (ownership %)
        v
[Holding Entity / Promoter Group]
        |
        | (ownership structure)
        v
[Issuer Entity] ← ← ← ← NCD Facility (INR ___ Cr)
        |                      from BPEA / Fund Vehicle
        | (on-lending / CCD / equity)
        v
[Operating Company / Companies]
        |
        v
[Subsidiaries / Step-downs]
```

### Real Structure Patterns

**Simple (Casablanca):**
```
Indicans B.V. (Delfin Gibert 80%) + Exal Corp (20%)
        |
        v
    CIPL (Issuer) ← ← ← INR 350 Cr NCDs
        |                  Series I: INR 250 Cr (acquisition)
        |                  Series II: INR 100 Cr (refinance + capex)
        v
    BAPIPL (acquired entity)
```
Structural risk: FOCC restriction → Tranche I routed through FPI vehicle.

**Complex (Asandas):**
```
Karamchandani Family
        |
        v
    New HoldCo (Issuer) ← ← ← INR 800 Cr NCDs
        |
        | (subscribes to CCDs)
        v
    ASPL (Operating Company)
        |
        ├── HAPL (seed multiplication, contract farming)
        ├── HFPL (distribution)
        ├── Hyfarm Foods
        ├── Vihaan (60% - CETP/boiler)
        ├── TFPL (being acquired - INR 150 Cr from proceeds)
        └── IPPL (being acquired)
```
Structural risks: HoldCo + CCD = potential NBFC classification. Multiple acquisitions from proceeds.

**NBFC (MPokket):**
```
Gaurav Jalan (Promoter)
        |
        v
    New HoldCo (Issuer) ← ← ← INR ___ Cr NCDs
        |
        | (on-lending)
        v
    MVPL (Investment Vehicle)
        |
        v
    mPokket (App + Portfolio)
```
Structural risk: NBFC classification for HoldCo. Portfolio-based security (not asset-backed).

---

## Deal Terms Template

The CP includes an indicative terms table. This is NOT the final HoT — it's the deal team's opening position for IC discussion.

### Standard Terms Grid

| Parameter | Value | Notes |
|-----------|-------|-------|
| **Issuer** | [Entity name] | Operating company or HoldCo |
| **Instrument** | Senior Secured NCDs | Standard for Ascertis Credit |
| **Facility Size** | INR ___ Cr | Typically INR 100-800 Cr |
| **Tranches** | [Single / Multiple] | If multiple: size, purpose, timing for each |
| **Tenor** | [36-60 months] | Typical 3-5 year maturity |
| **Coupon** | [10-14%] p.a. | Fixed rate, quarterly payment |
| **Accrued Premium** | [2-4%] | Declining schedule (higher early, nil later) |
| **Upside Premium** | [5-7%] of exit EV | Payable on exit event |
| **Target IRR** | [15-20%] | All-in expected return |
| **Make-Whole Period** | [24-36 months] | No early repayment without penalty |
| **Use of Proceeds** | [Breakdown] | Capex, acquisition, refinance, WC |

### Security Package

| Security | Coverage | Priority |
|----------|----------|----------|
| **Fixed Asset Charge** | 1st exclusive charge on [describe assets] | Primary |
| **Share Pledge** | [X]% of [entity] shares | Secondary |
| **Personal Guarantee** | Promoter PG | Tertiary |
| **Corporate Guarantee** | [Entity] CG | If applicable |
| **Escrow** | [Cash flow / portfolio] escrow mechanism | If applicable (esp. NBFC) |
| **Negative Pledge** | No additional borrowing without consent | Standard |

### Security Coverage Calculation

```
Asset Coverage = (Value of Charged Assets) / (Facility Size)

Example (Casablanca):
- Fixed assets: INR ___  Cr
- Enterprise value at 10x EV/EBITDA: INR ___ Cr
- 80% share pledge value: INR ___ Cr
- Coverage: 1.8x - 2.3x (depending on valuation multiple)
```

Show coverage at multiple valuation scenarios:
- At deal-entry EV/EBITDA multiple
- At -20% stress case
- At -40% severe stress case

---

## Structural Risk Identification

The structure drafter must flag every structural complexity. These are the issues that kill deals in legal documentation if not identified early.

### Common Structural Risks

| Risk | Description | Deals Affected |
|------|-------------|----------------|
| **FOCC / FPI Restriction** | Foreign-owned companies face restrictions on NCD investment. May need FPI routing | Casablanca |
| **NBFC Classification** | HoldCo that on-lends may be classified as NBFC by RBI. Requires compliance framework | MPokket, Asandas |
| **CCD Mechanism** | Compulsorily Convertible Debentures add equity conversion layer. Tax and regulatory implications | Asandas |
| **Multi-Entity Exposure** | Lending to group via HoldCo but operations across multiple entities. Cross-default and guarantee structure critical | Asandas |
| **Promoter Group Complexity** | Multiple family members, trusts, offshore entities. Beneficial ownership mapping needed | Various |
| **Regulatory Approvals** | SEBI, RBI, CCI, FIPB approvals needed before disbursement | Various |
| **Step-Down Risk** | Money flows through multiple layers before reaching operating entity. Leakage risk | Complex structures |

### How to Flag Risks

For each structural risk, provide:

```
## Structural Risk: [Name]

**Issue:** [What is the risk?]
**Impact:** [What happens if it materializes?]
**Precedent:** [Has Ascertis dealt with this before? How?]
**DD Action:** [What legal/regulatory DD resolves this?]
**Mitigation:** [Structural fix if available]
```

---

## Use of Proceeds Breakdown

The IC wants to know exactly where the money goes. Break it down:

```
| Use | Amount (INR Cr) | % of Facility | Timing |
|-----|-----------------|---------------|--------|
| Capex (Line X expansion) | ___ | __% | Q1-Q2 post-disbursement |
| Acquisition (Entity Y) | ___ | __% | On completion |
| Refinancing (existing debt) | ___ | __% | Immediate |
| Working Capital | ___ | __% | As needed |
| Transaction costs | ___ | __% | Immediate |
| **Total** | **___** | **100%** | |
```

Red flags in use of proceeds:
- More than 30% going to refinance existing debt (why is existing lender exiting?)
- Vague "working capital" without sizing rationale
- Acquisition from proceeds where valuation isn't established
- No clear link between capex and projected revenue growth

---

## Exit Mechanism

Private credit is NOT permanent capital. The CP must articulate the exit path:

| Exit Route | Timeline | Likelihood | IRR Impact |
|------------|----------|------------|------------|
| **Scheduled Repayment** | Per NCD maturity schedule | Base case | Fixed coupon only |
| **Refinancing** | Before maturity (make-whole applies) | Common | Coupon + make-whole premium |
| **IPO / PE Exit** | Typically 2.5-3 years | Variable | Coupon + upside premium (highest IRR) |
| **Strategic Sale** | Opportunistic | Low probability | Coupon + upside premium |
| **Put Option** | At specified date | Contractual right | Coupon + put premium |

The IC will challenge: "What if the IPO doesn't happen?" Always have a fallback exit that doesn't depend on equity markets.

---

## Output

The structure drafter produces:
1. **Corporate structure diagram** (ownership chain, entity map)
2. **Transaction structure diagram** (flow of funds, instrument type)
3. **Indicative terms table** (all key parameters)
4. **Security package summary** with coverage ratios at multiple scenarios
5. **Structural risk register** (each risk with DD action)
6. **Use of proceeds breakdown** with timing
7. **Exit mechanism analysis** with fallback options

These feed into Document Assembly (`04-document-assembly.md`) as the Deal Terms and Structure sections of the Concept Paper.
