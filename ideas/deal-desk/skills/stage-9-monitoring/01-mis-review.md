# Stage 9.1: MIS Review

You are reviewing the monthly Management Information System report from a portfolio company. This is a routine task, but pattern recognition across months is how you catch problems early.

---

## Monthly MIS Review Checklist

When the monthly MIS arrives:

### Step 1: Data Quality Check (2 minutes)
- [ ] MIS received within 15 days of month-end (timeliness)
- [ ] All expected sheets/sections present
- [ ] Numbers are internally consistent (P&L → BS → CF reconcile)
- [ ] Comparatives included (prior month, same month last year)

If MIS is late or incomplete → flag to deal lead. Persistent lateness is itself a warning sign (company may be struggling to close books).

### Step 2: Quick Scan (5 minutes)
Compare to prior month and model projection:

```
| Metric | Model (Month) | Actual | Prior Month | MoM Change | vs. Model |
|--------|--------------|--------|-------------|-----------|-----------|
| Revenue | ___ | ___ | ___ | ___% | ___% |
| EBITDA | ___ | ___ | ___ | ___% | ___% |
| Cash Balance | ___ | ___ | ___ | +/- ___ | |
| Debt (Total) | ___ | ___ | ___ | +/- ___ | |
| Key KPI 1 | ___ | ___ | ___ | | |
| Key KPI 2 | ___ | ___ | ___ | | |
```

### Step 3: Deep Dive (if anomalies found — 15-30 minutes)

For any metric with >10% variance from model or unusual MoM movement:

1. **Identify the driver** — what specific line item caused the variance?
2. **Classify the variance** — temporary (one-time) or structural (recurring)?
3. **Assess the impact** — does this affect covenant compliance at quarter-end?
4. **Document** — note the finding in the monitoring log

---

## Sector-Specific KPIs to Track

### Manufacturing
| KPI | Why It Matters | Warning Sign |
|-----|---------------|--------------|
| Capacity utilization (%) | Revenue ceiling | Declining below 70% |
| Order book value | Revenue visibility | Below 3 months of revenue |
| Raw material cost (% of revenue) | Margin driver | Increasing without price pass-through |
| Employee headcount | Fixed cost pressure | Rapid hiring without revenue growth |
| Capex spend (cumulative) | Cash flow impact | Significantly above/below plan |
| Customer concentration (top 5 %) | Revenue risk | Increasing dependence on single customer |

### NBFC / Fintech
| KPI | Why It Matters | Warning Sign |
|-----|---------------|--------------|
| Monthly disbursements | AUM growth driver | Declining trend |
| Collection efficiency (%) | Cash flow quality | Below 90% for 2+ months |
| GNPA (%) | Portfolio quality | Rising above 5% |
| DPD 90+ (%) | Provisioning trigger | Increasing trend |
| AUM composition | Concentration risk | Shift toward riskier segments |
| Customer acquisition cost | Unit economics | Increasing significantly |
| Borrower-level default rate | Credit model health | Rising above historical average |

### Agri / Food Processing
| KPI | Why It Matters | Warning Sign |
|-----|---------------|--------------|
| Capacity utilization (%) | Revenue + efficiency | Seasonal dips are normal; structural decline is not |
| Potato purchase price | RM cost driver | Above budget by >15% |
| Export vs. domestic mix | Revenue quality + FX risk | Shift toward lower-margin channel |
| Inventory levels (MT) | WC pressure | Building above seasonal norms |
| Farmer enrollment (contract farming) | Supply security | Declining retention rate |
| QSR customer volumes | Demand proxy | Below contracted minimums |

---

## Monthly Monitoring Note

After each MIS review, produce a brief note:

```
## Monthly Monitoring Note — [Company] — [Month/Year]

**MIS Received:** [Date] | **Timeliness:** On time / [X] days late

### Summary
[1-2 sentences: "Performance in line with expectations" OR "Revenue below
model by X% due to [reason]. EBITDA impact mitigated by [factor]."]

### Key Metrics
| Metric | Actual | Model | Variance | Status |
|--------|--------|-------|----------|--------|
| Revenue | ___ | ___ | ___% | 🟢/🟡/🔴 |
| EBITDA | ___ | ___ | ___% | 🟢/🟡/🔴 |
| Cash | ___ | ___ | | 🟢/🟡/🔴 |

### Observations
- [Any notable items — positive or negative]
- [Trend developing — reference prior months]

### Action Required
- [None / Follow up on [X] / Escalate [Y] to deal lead]

### Quarter-End Covenant Estimate
- DSCR (TTM estimate): ___x (Covenant: ___x) → Likely PASS/FAIL
- Leverage (estimate): ___x (Covenant: ___x) → Likely PASS/FAIL
```

---

## Trend Tracking (12-Month View)

Maintain a running 12-month tracker for each portfolio company:

```
| Month | Revenue | EBITDA | Margin | Cash | Debt | DSCR(TTM) | Notes |
|-------|---------|--------|--------|------|------|-----------|-------|
| Apr 25 | ___ | ___ | ___% | ___ | ___ | ___x | |
| May 25 | ___ | ___ | ___% | ___ | ___ | ___x | |
| Jun 25 | ___ | ___ | ___% | ___ | ___ | ___x | Q1 covenant test |
| ... | | | | | | | |
| Mar 26 | ___ | ___ | ___% | ___ | ___ | ___x | Annual review |
```

The trend tells the story. A single bad month is noise. Three consecutive declining months is a signal.

---

## Output

The MIS review produces:
1. **Monthly monitoring note** (1 page, templated)
2. **12-month trend tracker** (updated each month)
3. **Anomaly flags** (if any metrics warrant attention)
4. **Quarter-end covenant estimate** (early warning before formal test)
