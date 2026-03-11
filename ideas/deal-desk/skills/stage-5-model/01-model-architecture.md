# Stage 5.1: Model Architecture

You are designing the sheet structure, formula flow, and assumption framework for the financial model. Architecture must be set up BEFORE any numbers go in — retrofitting a poorly structured model wastes weeks.

---

## Sheet Naming Convention

```
00_Cover
01_TOC
02_Assumptions
03_Transaction
10_Hist_PL
11_Hist_BS
12_Hist_CF
13_Hist_Ratios
14_Adjustments
20_Rev_Buildup
21_Cost_Buildup
22_Proj_PL
23_WC_Proj
24_Capex
25_Proj_BS
26_Proj_CF
27_Proj_Ratios
30_Debt_Schedule
31_Interest_Calc
32_Returns
33_Fee_Schedule
40_DSCR
41_Leverage
42_NW_Test
43_Covenant_Dashboard
50_Mgmt_Case
51_Ascertis_Case
52_Downside
53_Sensitivity
54_Break_Even
60_Tax_Comp
61_Depreciation
62_Consolidation (if multi-entity)
63_Validation
```

**Numbering rationale:** Groups (0x = control, 1x = historical, 2x = projections, 3x = debt/returns, 4x = covenants, 5x = scenarios, 6x = supporting). Easy to navigate in a 40+ sheet workbook.

---

## Formula Flow

Information flows in ONE direction:

```
Assumptions (02) ──→ Revenue Build-Up (20) ──→ Projected P&L (22)
                                                       │
                 ──→ Cost Build-Up (21) ──────────────┘
                                                       │
                 ──→ WC Projections (23) ──→ Projected BS (25) ──→ Projected CF (26)
                                                       │
                 ──→ Capex (24) ──────────────────────┘
                                                       │
                 ──→ Debt Schedule (30) ──→ Interest (31) ──→ (feeds back to P&L)
                                                       │
                                               ──→ DSCR (40) ──→ Dashboard (43)
                                                       │
                                               ──→ Returns (32)
```

**Critical rule:** No sheet should reference a sheet that references it back. If you see a circular arrow, restructure.

**Exception:** Interest expense depends on debt balance, which depends on cash flow, which includes interest expense. Solve by:
1. Calculate interest on opening debt balance (not average)
2. Or use a manual iteration (calculate once, paste as value, recalculate)

---

## Assumptions Sheet (02_Assumptions)

The single most important sheet. Every variable input lives here.

### Layout

```
ASSUMPTIONS SHEET

═══ SCENARIO TOGGLE ═══
Active Scenario: [Management / Ascertis / Downside]  ← dropdown

═══ REVENUE ASSUMPTIONS ═══
                          FY25E   FY26E   FY27E   FY28E   FY29E
Product A Volume (MT)     ___     ___     ___     ___     ___
Product A Realization     ___     ___     ___     ___     ___
Product B Volume          ___     ___     ___     ___     ___
Product B Realization     ___     ___     ___     ___     ___
[etc.]

═══ COST ASSUMPTIONS ═══
RM Cost (% of Revenue)    ___     ___     ___     ___     ___
Employee Cost (INR Cr)    ___     ___     ___     ___     ___
Other Expenses (INR Cr)   ___     ___     ___     ___     ___

═══ WORKING CAPITAL ASSUMPTIONS ═══
Debtor Days               ___     ___     ___     ___     ___
Inventory Days            ___     ___     ___     ___     ___
Creditor Days             ___     ___     ___     ___     ___

═══ CAPEX ASSUMPTIONS ═══
Maintenance Capex (INR Cr) ___    ___     ___     ___     ___
Growth Capex (INR Cr)     ___     ___     ___     ___     ___

═══ TAX ASSUMPTIONS ═══
Effective Tax Rate        ___     ___     ___     ___     ___
MAT Credit Available      ___     ___     ___     ___     ___

═══ DEAL ASSUMPTIONS ═══
Facility Size (INR Cr)    ___
Coupon (%)                ___
Tenor (months)            ___
Accrued Premium (%)       ___
Upside Premium (%)        ___
Exit EV/EBITDA Multiple   ___
```

### Color Coding Standard

| Color | Meaning |
|-------|---------|
| **Blue font** | Input (manually entered, from DD or assumptions) |
| **Black font** | Formula (calculated, never manually entered) |
| **Green font** | Link to another sheet |
| **Red font** | Override / hardcode that should eventually be formula |
| **Yellow highlight** | Item needing review or update |
| **Grey background** | Historical period (not editable in projection context) |

---

## Historical Section Design

### P&L Layout (10_Hist_PL)

Follow BPEA format from Stage 0 extraction, but with DD adjustments applied:

```
                              FY22    FY23    FY24    Source
Revenue from Operations        ___     ___     ___    Audited
Other Operating Income         ___     ___     ___    Audited
Total Operating Revenue        ___     ___     ___    =SUM

Raw Material Cost              ___     ___     ___    Audited
Purchase of Stock-in-Trade     ___     ___     ___    Audited
Changes in Inventory           ___     ___     ___    Audited
Employee Benefit Expense       ___     ___     ___    Audited
Other Expenses                 ___     ___     ___    Audited
Total Operating Expenses       ___     ___     ___    =SUM

EBITDA (Reported)              ___     ___     ___    =Revenue-Expenses
EBITDA Margin (%)              ___     ___     ___    =EBITDA/Revenue

QoE Adjustments:
  One-time items               ___     ___     ___    From DD
  RPT adjustments              ___     ___     ___    From DD
  Policy change impact         ___     ___     ___    From DD

Adjusted EBITDA                ___     ___     ___    =Reported+Adjustments
Adjusted EBITDA Margin (%)     ___     ___     ___

Depreciation                   ___     ___     ___    Audited
EBIT                           ___     ___     ___
Interest Expense               ___     ___     ___    Audited
Other Income                   ___     ___     ___    Audited
PBT                            ___     ___     ___
Tax                            ___     ___     ___    Audited
PAT                            ___     ___     ___
```

### Balance Sheet Layout (11_Hist_BS)

```
ASSETS                        FY22    FY23    FY24
Non-Current Assets:
  Net Fixed Assets             ___     ___     ___
  CWIP                         ___     ___     ___
  Intangible Assets            ___     ___     ___
  Investments                  ___     ___     ___
  Other Non-Current            ___     ___     ___

Current Assets:
  Inventory                    ___     ___     ___
  Trade Receivables            ___     ___     ___
  Cash & Equivalents           ___     ___     ___
  Other Current Assets         ___     ___     ___

Total Assets                   ___     ___     ___

LIABILITIES
Equity:
  Share Capital                ___     ___     ___
  Reserves & Surplus           ___     ___     ___
  Total Net Worth              ___     ___     ___

Non-Current Liabilities:
  Long-Term Borrowings         ___     ___     ___
  Other Non-Current            ___     ___     ___

Current Liabilities:
  Short-Term Borrowings        ___     ___     ___
  Trade Payables               ___     ___     ___
  Other Current                ___     ___     ___

Total Liabilities & Equity     ___     ___     ___

CHECK: Assets = Liabilities    ✓/✗    ✓/✗    ✓/✗
```

---

## Validation Sheet (63_Validation)

Automatic checks that run across the model:

```
| # | Check | Formula | Result | Status |
|---|-------|---------|--------|--------|
| 1 | BS Balances (all periods) | =Assets-Liabilities | 0 | ✓ |
| 2 | CF reconciles to BS cash | =Closing Cash - Opening Cash - CF | 0 | ✓ |
| 3 | Debt schedule = BS debt | =Debt Sheet Total - BS Total Debt | 0 | ✓ |
| 4 | Revenue build-up = PL revenue | =Rev Sheet - PL Revenue | 0 | ✓ |
| 5 | Interest calc = PL interest | =Interest Sheet - PL Interest | 0 | ✓ |
| 6 | Tax calc = PL tax | =Tax Sheet - PL Tax | ±<0.1 | ✓ |
| 7 | WC days produce BS WC | =WC Sheet Items - BS Items | 0 | ✓ |
| 8 | No negative cash balance | =MIN(all cash cells) > 0 | True | ✓ |
| 9 | DSCR > 0 (all periods) | =MIN(DSCR range) > 0 | True | ✓ |
| 10 | No #REF, #N/A, #VALUE errors | =SUMPRODUCT(ISERROR(range)) | 0 | ✓ |
```

If ANY check fails → fix before proceeding. The model is not ready for review until all validations pass.

---

## Multi-Entity Models

For group structures (like Asandas: ASPL + HAPL + HFPL + subsidiaries):

1. Build each entity's P&L and BS on separate sheets
2. Create a consolidation sheet that:
   - Sums all entity financials
   - Eliminates inter-company transactions
   - Eliminates inter-company balances
3. Present both standalone and consolidated views

The DSCR and covenant tests should be run on the entity that is the borrower/issuer — typically consolidated if the fund has visibility across the group.

---

## Output

The model architecture produces:
1. **Empty model workbook** with all sheets created, named, and color-coded
2. **Assumptions sheet** populated with structure (not values yet)
3. **Validation sheet** with all automated checks
4. **Formula flow map** (which sheet feeds which)
5. **Style guide** (color coding, naming conventions)

The Projections & Scenarios sub-skill (`02-projections-scenarios.md`) then populates the model with actual numbers.
