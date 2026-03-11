# Stage 9.2: Covenant Testing

You are performing quarterly covenant compliance testing for a portfolio company. This is a formal process — the borrower submits quarterly financials and a compliance certificate, and the associate independently verifies every covenant.

---

## Covenant Testing Process

```
Quarter ends (e.g., Jun 30)
    ↓
Borrower submits quarterly financials + compliance certificate (by Jul 30)
    ↓
Associate receives and reviews (Day 1-2)
    ↓
Independent recalculation of all covenants (Day 3-5)
    ↓
Compare fund calculation vs. borrower's compliance certificate
    ↓
If discrepancy → investigate and resolve
    ↓
Prepare covenant compliance report
    ↓
File report + flag any concerns to deal lead
```

---

## Covenant Compliance Report

```
## Quarterly Covenant Compliance — [Company] — [Quarter]

**Quarter Ended:** [DD/MM/YYYY]
**Financials Received:** [DD/MM/YYYY] (On time / [X] days late)
**Compliance Certificate:** Received ✓ / Not Received ✗

═══ FINANCIAL COVENANTS ═══

| # | Covenant | Required | Actual | Headroom | Status |
|---|----------|----------|--------|----------|--------|
| 1 | DSCR | ≥ 1.30x | ___x | ___% | PASS/FAIL |
| 2 | Net Debt/EBITDA | ≤ 5.50x | ___x | ___% | PASS/FAIL |
| 3 | Minimum Net Worth | ≥ INR ___ Cr | INR ___ Cr | ___% | PASS/FAIL |
| 4 | Current Ratio | ≥ 1.10x | ___x | ___% | PASS/FAIL |

═══ INFORMATION COVENANTS ═══

| # | Covenant | Deadline | Received | Status |
|---|----------|----------|----------|--------|
| 1 | Monthly MIS (Month 1) | T+15 | [Date] | On time / Late |
| 2 | Monthly MIS (Month 2) | T+15 | [Date] | On time / Late |
| 3 | Monthly MIS (Month 3) | T+15 | [Date] | On time / Late |
| 4 | Quarterly financials | T+30 | [Date] | On time / Late |
| 5 | Compliance certificate | T+30 | [Date] | On time / Late |

═══ NEGATIVE COVENANTS ═══

| # | Covenant | Status | Notes |
|---|----------|--------|-------|
| 1 | No additional indebtedness | Compliant / Breach | |
| 2 | No dividend/distribution | Compliant / Breach | |
| 3 | No asset disposal above threshold | Compliant / Breach | |
| 4 | No change of control | Compliant / Breach | |
| 5 | No related party transactions above threshold | Compliant / Breach | |

═══ PORTFOLIO COVENANTS (NBFC only) ═══

| # | Covenant | Required | Actual | Status |
|---|----------|----------|--------|--------|
| 1 | GNPA | ≤ ___% | ___% | PASS/FAIL |
| 2 | Collection Efficiency | ≥ ___% | ___% | PASS/FAIL |
| 3 | CRAR | ≥ ___% | ___% | PASS/FAIL |
| 4 | Single Borrower Exposure | ≤ ___% | ___% | PASS/FAIL |

═══ OVERALL STATUS ═══
All covenants: COMPLIANT / BREACH (specify which)

═══ TREND ═══
| Metric | Q-2 | Q-1 | This Q | Trend |
|--------|-----|-----|--------|-------|
| DSCR | ___x | ___x | ___x | ↑/↓/→ |
| Leverage | ___x | ___x | ___x | ↑/↓/→ |
| Net Worth | ___ | ___ | ___ | ↑/↓/→ |
```

---

## Independent Recalculation

**Never rely solely on the borrower's compliance certificate.** Always recalculate independently:

### DSCR Recalculation

```
Step 1: Extract trailing 12-month EBITDA from quarterly financials
  Q-3: ___ + Q-2: ___ + Q-1: ___ + This Q: ___ = TTM EBITDA: ___

Step 2: Subtract cash taxes paid (from cash flow statement)
  TTM Tax: ___

Step 3: Subtract maintenance capex
  TTM Maintenance Capex: ___
  (Verify: total capex ___ less growth capex ___ = maintenance ___))

Step 4: Calculate available cash for debt service
  Available = TTM EBITDA - Tax - Maint Capex = ___

Step 5: Calculate total debt service
  Interest (all debt, TTM): ___
  Principal repayments (all debt, TTM): ___
  Total DS: ___

Step 6: DSCR = Available / Total DS = ___x

Step 7: Compare to covenant floor: ___x
  Headroom: (Actual DSCR - Covenant) / Covenant = ___%
```

### Common Discrepancy Sources

| Issue | Borrower May... | You Should... |
|-------|----------------|---------------|
| EBITDA definition | Include one-time gains | Exclude per covenant definition |
| Maintenance capex | Classify growth capex as maintenance | Apply DD-era split ratio |
| Cash taxes | Use provision, not actual payment | Use cash flow statement |
| Total debt | Exclude lease liabilities | Include if covenant defines "indebtedness" broadly |
| Interest | Exclude capitalized interest | Include all interest per covenant |
| DSRA | Include DSRA in cash | Exclude if covenant says "freely available" |

**Always refer to the SL/HoT definitions.** Covenants are only as good as their definitions. If the definition is ambiguous, note it and recommend clarification in the next amendment opportunity.

---

## Covenant Headroom Analysis

Beyond pass/fail, track how much headroom exists:

```
| Covenant | Actual | Required | Headroom | Quarters to Breach |
|----------|--------|----------|----------|-------------------|
| DSCR | 1.65x | 1.30x | 27% | ~6Q at current deterioration rate |
| Leverage | 4.2x | 5.5x | 24% | ~4Q if EBITDA flat, debt unchanged |
| Net Worth | INR 520 Cr | INR 400 Cr | 30% | N/A (growing) |
```

**"Quarters to Breach"** is a forward-looking estimate:
- Take the quarter-over-quarter deterioration rate (if any)
- Project forward at that rate
- Estimate when the covenant would trip

This gives early warning even when the covenant is currently passing.

---

## Breach Response Workflow

If a covenant trips:

```
Step 1: Verify (recalculate independently)
    ↓
Step 2: Classify (temporary vs. structural)
    ↓
Step 3: Brief deal lead + CIO (same day)
    ↓
Step 4: Formal breach notice sent to borrower (per SL terms)
    ↓
Step 5: Request borrower's remediation plan
    ↓
Step 6: Evaluate options:
    a. Waiver (with fee + additional protection)
    b. Amendment (permanent adjustment)
    c. Equity cure (promoter injects capital)
    d. Enforcement (accelerate debt, call security)
    ↓
Step 7: Document decision and rationale
```

### Waiver Considerations

| Factor | Grant Waiver | Don't Grant |
|--------|-------------|-------------|
| Cause | One-time / seasonal dip | Structural deterioration |
| Borrower response | Proactive, transparent | Hides or minimizes |
| Trend | Other metrics healthy | Multiple metrics declining |
| Promoter action | Willing to inject equity, accept tighter terms | Resists all remediation |
| Business outlook | Temporary disruption | Fundamental challenge |
| Security position | Adequate coverage maintained | Coverage declining |

### Waiver Conditions (Typical)

If granting a waiver, extract value:
- Waiver fee (0.25-0.50% of facility)
- Tighter covenant for next 4 quarters
- Additional security or guarantee
- Enhanced information rights (weekly MIS instead of monthly)
- Board observer seat (if not already present)
- Restriction on distributions until compliance restored

---

## Output

The covenant testing produces:
1. **Quarterly compliance report** (pass/fail for each covenant)
2. **Independent recalculation workings** (showing methodology)
3. **Headroom analysis** (how much cushion exists)
4. **Trend analysis** (quarter-over-quarter trajectory)
5. **Breach response** (if applicable — classification, options, recommendation)
