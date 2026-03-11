# Stage 5 Orchestrator: Financial Model

You are helping an associate build the full financial model — a 35-45 sheet Excel workbook that becomes the definitive analytical tool for the deal. The goal: **"Can this company reliably service debt under base and stress scenarios?"**

**This is NOT the screening model from Stage 0.** That was disposable. This model is built from scratch using DD-validated financials, and it drives the FDIR numbers, IC discussion, and final pricing. It must be audit-grade.

---

## Sub-Skills

| Sub-Skill | File | Purpose |
|-----------|------|---------|
| Model Architecture | `01-model-architecture.md` | Sheet structure, flow logic, assumptions framework |
| Projections & Scenarios | `02-projections-scenarios.md` | Revenue build-up, EBITDA, cases, sensitivity, covenant testing |

---

## Model Inputs (from Prior Stages)

| Source | What It Provides |
|--------|-----------------|
| Stage 0 (Screening) | NOTHING — screening model is discarded |
| Stage 2 (HoT) | Deal terms: facility size, coupon, tenor, upside premium, covenants |
| Stage 3 (Industry) | Market growth rates, peer margins, sector benchmarks |
| Stage 4 (DD) | Adjusted EBITDA, restated financials, WC analysis, capex split, RPT adjustments |

---

## Model Architecture Overview

### Sheet Groups (35-45 sheets)

```
├── Control & Assumptions
│   ├── Cover Sheet (project code, version, date, author)
│   ├── Table of Contents
│   ├── Key Assumptions
│   ├── Scenario Toggle (Management / Ascertis / Downside)
│   └── Transaction Summary
│
├── Historical Financials (DD-validated)
│   ├── Historical P&L (3-5 years)
│   ├── Historical Balance Sheet (3-5 years)
│   ├── Historical Cash Flow (3-5 years)
│   ├── Historical Ratios
│   └── Adjustments Bridge (reported → adjusted)
│
├── Projections
│   ├── Revenue Build-Up (bottom-up by segment/customer/product)
│   ├── Cost Build-Up (raw material, employee, other)
│   ├── Projected P&L (facility tenor + 1-2 years)
│   ├── Working Capital Projections
│   ├── Capex Schedule
│   ├── Projected Balance Sheet
│   ├── Projected Cash Flow
│   └── Projected Ratios
│
├── Debt & Returns
│   ├── Debt Schedule (all debt, not just this facility)
│   ├── Interest Calculation
│   ├── Principal Repayment Schedule
│   ├── Returns Analysis (IRR, MOIC)
│   ├── Upside Premium Calculation
│   └── Fee Schedule
│
├── Covenant Testing
│   ├── DSCR Schedule (quarterly)
│   ├── Leverage Schedule (quarterly)
│   ├── Net Worth Test (annual)
│   ├── Other Covenants
│   └── Covenant Compliance Dashboard
│
├── Scenarios & Sensitivity
│   ├── Management Case
│   ├── Ascertis Case (25% EBITDA haircut)
│   ├── Downside Case
│   ├── Sensitivity Tables (2D: revenue × margin)
│   └── Break-Even Analysis (at what EBITDA does DSCR = 1.0x?)
│
├── NBFC Additions (if applicable)
│   ├── Disbursement Projections
│   ├── Collection Projections
│   ├── Portfolio Build-Up
│   ├── Provision Model
│   ├── ALM Maturity Buckets
│   ├── CRAR Projections
│   └── DuPont Decomposition
│
└── Supporting
    ├── Tax Computation
    ├── Depreciation Schedule
    ├── Entity-wise Consolidation (if group)
    └── Data Validation Checks
```

---

## Model Building Sequence

```
Step 1: Set up architecture (sheets, headers, formatting)
    ↓
Step 2: Input historical financials (from DD, not raw audited)
    ↓
Step 3: Build adjustments bridge (reported → DD-adjusted)
    ↓
Step 4: Create assumptions sheet (revenue drivers, cost assumptions, WC days)
    ↓
Step 5: Build revenue projections (bottom-up)
    ↓
Step 6: Build cost projections (linked to revenue where appropriate)
    ↓
Step 7: Complete projected P&L
    ↓
Step 8: Project working capital (using DD-validated WC days)
    ↓
Step 9: Build capex schedule (maintenance + growth, from DD findings)
    ↓
Step 10: Complete projected balance sheet
    ↓
Step 11: Build cash flow statement (indirect method from P&L + BS changes)
    ↓
Step 12: Input debt schedule (all existing debt + this facility)
    ↓
Step 13: Build returns analysis (IRR at different exit scenarios)
    ↓
Step 14: Build covenant testing (quarterly DSCR, leverage)
    ↓
Step 15: Create scenario toggle (Management / Ascertis / Downside)
    ↓
Step 16: Build sensitivity tables
    ↓
Step 17: Add data validation checks (BS must balance, CF must reconcile)
    ↓
Step 18: Review cycle (SM → CIO → lock for FDIR)
```

---

## Key Model Principles

### 1. Formula Integrity
- **No hardcoded numbers in formulas.** Every input comes from the assumptions sheet
- **No circular references.** If interest depends on debt which depends on cash which depends on interest — break the circularity with a prior-period calculation or iterative solver
- **Color coding:** Inputs (blue font), formulas (black font), links to other sheets (green font)

### 2. Three Cases

| Case | What It Assumes | Purpose |
|------|----------------|---------|
| **Management Case** | Company's projections as-is | Upper bound. What the borrower promises |
| **Ascertis Case** | Management revenue with 25% EBITDA haircut | Base case. What Ascertis underwrites to |
| **Downside Case** | Flat revenue, compressed margins, higher WC | Stress test. What happens in a bad year |

The IC decision is made on the Ascertis Case. The Management Case shows upside. The Downside Case shows survivability.

### 3. Revenue Build-Up

Never project revenue as a single growth rate. Build bottom-up:

**Manufacturing:**
```
Revenue = Σ (Product Volume × Realization per Unit)

For each product:
  Volume = Capacity × Utilization × (1 + growth assumptions)
  Realization = Current price × (1 + price escalation)
```

**NBFC:**
```
Interest Income = AUM × Yield on AUM
Fee Income = Disbursements × Fee %
Total Revenue = Interest Income + Fee Income + Other Income

AUM = Opening AUM + Disbursements - Collections - Write-offs
```

### 4. DSCR Calculation (Most Important Output)

```
DSCR = (EBITDA - Tax - Maintenance Capex) / Total Debt Service

Where:
  Total Debt Service = Interest (all debt) + Principal Repayment (all debt)

Test quarterly. Present as a schedule:

| Quarter | EBITDA | Tax | Maint Capex | Available | Debt Service | DSCR | Covenant | Pass? |
|---------|--------|-----|-------------|-----------|-------------|------|----------|-------|
| Q1 FY26 | ___ | ___ | ___ | ___ | ___ | ___x | 1.3x | ✓/✗ |
| Q2 FY26 | ___ | ___ | ___ | ___ | ___ | ___x | 1.3x | ✓/✗ |
```

---

## Connection to Other Stages

| Stage | Relationship |
|-------|-------------|
| Stage 2 (HoT) | Deal terms become model inputs (coupon, tenor, covenants) |
| Stage 3 (Industry) | Sector benchmarks inform growth and margin assumptions |
| Stage 4 (DD) | DD-adjusted financials are the historical base |
| Stage 6 (FDIR) | Model outputs populate FDIR financial tables |
| Stage 7 (FIR) | IC queries often require model re-runs with different assumptions |
| Stage 9 (Monitoring) | Model becomes the baseline for ongoing covenant monitoring |

---

## What Success Looks Like

A good model:
1. **Balances** — balance sheet balances in every period. Cash flow reconciles
2. **Is auditable** — any number can be traced back to its source (assumption, DD data, or formula)
3. **Has a clear assumptions page** — change one input, and the entire model updates correctly
4. **Passes the stress test** — DSCR remains > 1.0x even in the Downside Case
5. **Tells a story** — the IC can see the deleveraging trajectory, the cash flow build, the covenant headroom

A bad model:
1. Circular references or error values
2. Hardcoded numbers buried in formulas
3. Management Case only (no conservative case)
4. DSCR covenant trips in the base case
5. Balance sheet doesn't balance (surprisingly common)
