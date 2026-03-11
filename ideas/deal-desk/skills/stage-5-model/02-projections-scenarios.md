# Stage 5.2: Projections & Scenarios

You are building the forward-looking projections, scenario analysis, and returns calculations. This is where the model goes from historical record to decision tool.

---

## The Three Cases

### Management Case
**Source:** Company's own projections (from management meetings, investor presentations, budget documents).

**Purpose:** Shows what the borrower promises. The IC uses this as the optimistic bound.

**How to build:**
- Use management's revenue growth assumptions
- Use management's margin guidance
- Use management's capex plan
- Apply management's WC improvement targets

**Caution:** Management always over-projects. Their incentive is to paint a rosy picture to get cheaper capital. Challenge every assumption.

### Ascertis Case (Base Case for IC Decision)
**Source:** Management revenue assumptions with a 25% EBITDA haircut.

**Purpose:** This is the case Ascertis underwrites to. All return calculations and covenant tests in the FDIR are based on this case.

**How to build:**
```
Revenue: Use Management Case revenue (accept top-line growth)
EBITDA:  Management EBITDA × 0.75 (25% haircut)
Margins: Recalculate margin % after EBITDA reduction
WC:      Use historical WC days (not management's improvement targets)
Capex:   Use management's capex plan (they'll spend it regardless)
```

**Why 25% EBITDA haircut?** Experience shows management projections are typically 15-30% optimistic. The 25% haircut is Ascertis's standard conservative adjustment. It's not scientific — it's a heuristic that has held up across multiple deals.

### Downside Case
**Source:** Stress scenario — what happens if things go wrong.

**How to build:**
```
Revenue: Flat from last audited year (zero growth)
EBITDA:  Historical lowest margin applied to flat revenue
WC:      Historical worst WC days (highest point in cycle)
Capex:   Maintenance only (no growth capex — company would defer)
```

**Purpose:** Tests survivability. If DSCR drops below 1.0x in the Downside Case, the deal has no margin of safety.

---

## Revenue Projection Build-Up

### Manufacturing

Build bottom-up by product × customer × geography:

```
PRODUCT A:
  Installed Capacity (MT/year):     ___
  Utilization Rate (%):             ___
  Effective Production (MT):        ___
  Internal Consumption (MT):        (__)
  Available for Sale (MT):          ___

  Domestic Sales Volume (MT):       ___  × Domestic Realization (INR/MT): ___ = Revenue: ___
  Export Sales Volume (MT):         ___  × Export Realization (INR/MT):  ___ = Revenue: ___

  Total Product A Revenue (INR Cr): ___

PRODUCT B:
  [Same structure]

TOTAL REVENUE:
  Product A:     ___
  Product B:     ___
  Other:         ___
  Total:         ___
```

**Key assumptions to document:**
- Volume growth: based on capacity expansion timeline + utilization ramp
- Realization: based on historical trend + pricing power assessment from DD
- Product mix: shift toward higher-margin products (if claimed, challenge evidence)

### NBFC / Fintech

```
OPENING AUM:                        ___
+ New Disbursements:                ___
  Monthly disbursement run rate:    ___ × 12
  Growth in monthly disbursement:   ___% p.a.
- Collections:                      (__)
  Collection rate (% of opening):   ___%
- Write-offs:                       (__)
  Write-off rate (% of AUM):        ___%
= CLOSING AUM:                      ___

INCOME:
  Interest Income = Avg AUM × Yield:     ___
  Processing Fee = Disbursements × Fee%:  ___
  Other Income:                           ___
  Total Income:                           ___
```

---

## Cost Projections

### Variable Costs (linked to revenue)

```
Raw Material:       ___% of Revenue (from historical trend, DD-validated)
Freight/Logistics:  ___% of Revenue
Commission:         ___% of Revenue
```

### Semi-Variable Costs

```
Power & Fuel:       Base ___ + Variable ___% of production volume
Repairs:            Base ___ + ___% of gross block
```

### Fixed Costs

```
Employee Cost:      ___ × (1 + annual increment ___%)
Rent:               ___ × (1 + escalation ___%)
Insurance:          ___% of gross block
Other Admin:        ___ × (1 + inflation ___%)
```

---

## DSCR Schedule (Quarterly)

The most scrutinized output in the model:

```
| Quarter | Q1 FY26 | Q2 FY26 | Q3 FY26 | Q4 FY26 | Q1 FY27 | ... |
|---------|---------|---------|---------|---------|---------|-----|
| Revenue | ___ | ___ | ___ | ___ | ___ | |
| EBITDA | ___ | ___ | ___ | ___ | ___ | |
| (-) Tax | ___ | ___ | ___ | ___ | ___ | |
| (-) Maint Capex | ___ | ___ | ___ | ___ | ___ | |
| = Available for DS | ___ | ___ | ___ | ___ | ___ | |
| | | | | | | |
| Interest (all debt) | ___ | ___ | ___ | ___ | ___ | |
| Principal (all debt) | ___ | ___ | ___ | ___ | ___ | |
| = Total DS | ___ | ___ | ___ | ___ | ___ | |
| | | | | | | |
| **DSCR** | **___x** | **___x** | **___x** | **___x** | **___x** | |
| Covenant | 1.3x | 1.3x | 1.3x | 1.3x | 1.3x | |
| **Pass?** | **✓/✗** | **✓/✗** | **✓/✗** | **✓/✗** | **✓/✗** | |

Minimum DSCR across facility life: ___x (in Quarter ___)
Average DSCR: ___x
```

**Seasonal adjustment:** For seasonal businesses (agri), DSCR will swing dramatically by quarter. Consider testing on trailing 12-month basis or allowing quarterly DSCR to dip below covenant if annual DSCR is adequate (negotiate in HoT).

---

## Returns Analysis

### Fund Returns (IRR Calculation)

```
| Period | Cash Flow (INR Cr) | Description |
|--------|-------------------|-------------|
| T0 | (___) | Investment (negative) |
| Q1 | ___ | Coupon payment |
| Q2 | ___ | Coupon payment |
| ... | ... | ... |
| T_exit | ___ | Principal + Accrued Premium |
| T_exit | ___ | Upside Premium (if equity exit) |

XIRR = ___% (based on actual dates)
MOIC = Total Cash Received / Investment = ___x
```

### Returns at Different Exit Scenarios

```
| Scenario | Exit Timing | Exit EV/EBITDA | Upside Premium | Total IRR | MOIC |
|----------|-------------|---------------|---------------|-----------|------|
| Base (Ascertis Case) | Year 3 | ___x | INR ___ Cr | ___% | ___x |
| Early Exit (Make-Whole) | Year 2 | N/A | None | ___% | ___x |
| Late Exit (Maturity) | Year 5 | ___x | INR ___ Cr | ___% | ___x |
| No Upside (Scheduled) | Maturity | N/A | None | ___% | ___x |
| Downside (Stressed) | Year 5 | ___x | Reduced | ___% | ___x |
```

---

## Sensitivity Tables

### 2D Sensitivity Matrix

```
IRR Sensitivity to Revenue Growth × EBITDA Margin:

                    EBITDA Margin
Revenue     │  14%    16%    18%    20%    22%
Growth      │
────────────┼────────────────────────────────
  0%        │  ___%   ___%   ___%   ___%   ___%
  5%        │  ___%   ___%   ___%   ___%   ___%
 10%        │  ___%   ___%   ___%   ___%   ___%
 15%        │  ___%   ___%   ___%   ___%   ___%
 20%        │  ___%   ___%   ___%   ___%   ___%
```

### Break-Even Analysis

```
At what EBITDA does DSCR = 1.0x?

Break-Even EBITDA: INR ___ Cr
Current EBITDA: INR ___ Cr
Cushion: ___% decline before covenant breach
Cushion: ___% decline before cash flow default (DSCR < 1.0x)
```

### Covenant Sensitivity

```
DSCR Sensitivity to EBITDA Change:

| EBITDA Change | DSCR (Min) | Covenant | Breach? |
|--------------|-----------|----------|---------|
| +10% | ___x | 1.3x | No |
| Base | ___x | 1.3x | No |
| -10% | ___x | 1.3x | ? |
| -20% | ___x | 1.3x | ? |
| -25% (Ascertis haircut) | ___x | 1.3x | ? |
| -30% | ___x | 1.3x | ? |
| -40% | ___x | 1.3x | ? |
```

---

## Leverage Trajectory

Show the deleveraging story:

```
| Year | EBITDA | Net Debt | Net Debt/EBITDA | Change | Covenant |
|------|--------|----------|----------------|--------|----------|
| Entry | ___ | ___ | ___x | — | ___x |
| FY+1 | ___ | ___ | ___x | ___x ↓ | ___x |
| FY+2 | ___ | ___ | ___x | ___x ↓ | ___x |
| FY+3 | ___ | ___ | ___x | ___x ↓ | ___x |
| Exit | ___ | ___ | ___x | ___x ↓ | ___x |
```

The IC wants to see a clear downward trajectory. If leverage stays flat or increases, the model needs to explain why (e.g., growth capex front-loaded, revenue ramp expected).

---

## Output

The projections & scenarios sub-skill produces:
1. **Complete projected financials** (P&L, BS, CF for facility tenor + 1-2 years)
2. **Three cases** (Management, Ascertis, Downside) with scenario toggle
3. **Quarterly DSCR schedule** with covenant compliance flags
4. **Returns analysis** (IRR, MOIC at multiple exit scenarios)
5. **Sensitivity tables** (revenue × margin, EBITDA decline × DSCR)
6. **Break-even analysis** (at what point does DSCR = 1.0x?)
7. **Leverage trajectory** (entry → exit deleveraging path)

These outputs are the primary inputs for the FDIR (Stage 6). The IC makes its investment decision based on these numbers.
