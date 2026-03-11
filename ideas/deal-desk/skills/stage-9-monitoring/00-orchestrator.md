# Stage 9 Orchestrator: Monitoring

You are helping an associate with ongoing portfolio monitoring — reviewing MIS reports, testing covenants, and flagging deterioration. The goal: **"Detect problems early enough to act on them."**

This is NOT a project stage — it's an **ongoing responsibility** for the 72-month facility life (or until exit). The associate reviews monthly MIS, tests covenants quarterly, and prepares annual reviews.

---

## Sub-Skills

| Sub-Skill | File | Purpose |
|-----------|------|---------|
| MIS Review | `01-mis-review.md` | Monthly MIS analysis and trend tracking |
| Covenant Testing | `02-covenant-testing.md` | Quarterly covenant compliance and early warning |

---

## What the Investments Team Monitors (vs. Transaction Team)

| Investments Team (User's Job) | Transaction Team |
|------------------------------|------------------|
| Monthly MIS review and analysis | Security trustee management |
| Quarterly covenant testing | Document custody |
| Annual financial review | Charge renewal and maintenance |
| Covenant breach response | Insurance policy tracking |
| Waiver / amendment negotiations | Regulatory filings |
| Portfolio-level reporting | Escrow account management |

---

## Monitoring Calendar

```
Monthly (by 15th of following month):
  - Receive MIS from borrower
  - Review key metrics (revenue, EBITDA, cash position, WC)
  - Flag any anomalies or trends
  - For NBFC: portfolio MIS (AUM, disbursements, collections, DPD)

Quarterly (by 30 days after quarter-end):
  - Receive quarterly financials
  - Test all financial covenants (DSCR, leverage, NW, current ratio)
  - Receive compliance certificate signed by CFO
  - For NBFC: test portfolio covenants (GNPA, CE, CRAR, ALM)

Semi-annually:
  - Management meeting or call
  - Site visit (for manufacturing/operational businesses)
  - Portfolio review meeting (internal)

Annually:
  - Receive audited financials (by 90 days after FY-end)
  - Comprehensive annual review
  - Update financial model with actuals
  - Assess against original investment thesis
  - Credit rating review (if rated)

As Needed:
  - Covenant breach response
  - Waiver requests
  - Amendment negotiations
  - Material event analysis
```

---

## Monitoring vs. Original Model

The FDIR model (Stage 5) becomes the **baseline** for monitoring:

```
| Metric | Model Projection | Actual | Variance | Concern? |
|--------|-----------------|--------|----------|----------|
| Revenue (Q1 FY26) | INR ___ Cr | INR ___ Cr | ___% | [Yes/No] |
| EBITDA (Q1 FY26) | INR ___ Cr | INR ___ Cr | ___% | [Yes/No] |
| DSCR (Q1 FY26) | ___x | ___x | ___x | [Yes/No] |
| Leverage | ___x | ___x | ___x | [Yes/No] |
| WC Days | ___ | ___ | ___ | [Yes/No] |
```

Track actuals vs. projections over time. Persistent negative variance is an early warning signal.

---

## Early Warning Framework

### Traffic Light System

| Indicator | Green | Amber | Red |
|-----------|-------|-------|-----|
| **DSCR** | > Covenant + 20% | Covenant to +20% | Below covenant |
| **Leverage** | < Covenant - 20% | Covenant to -20% | Above covenant |
| **Revenue vs. Model** | Within ±10% | -10% to -20% | Below -20% |
| **EBITDA Margin** | Within ±200 bps | -200 to -400 bps | Below -400 bps |
| **MIS Timeliness** | On time | 1-2 weeks late | >2 weeks late |
| **Payment** | On time | Within grace period | Past grace period |

### Escalation Protocol

| Signal | Action | Owner |
|--------|--------|-------|
| **Single Amber** | Monitor closely. Note in quarterly report | Associate |
| **Multiple Amber** | Brief deal lead. Discuss in portfolio review | Associate + SM |
| **Any Red** | Immediate escalation to deal lead and CIO | SM/VP |
| **Covenant Breach** | Formal breach notice process. Waiver evaluation | CIO + Legal |
| **Payment Default** | Immediate escalation. Enforcement assessment | CIO + Board |

---

## Covenant Breach Response

If a covenant trips:

```
1. Verify the breach (recalculate independently — don't rely on borrower's numbers)
2. Assess severity (technical breach vs. fundamental deterioration)
3. Classify the cause:
   a. Temporary / one-time → likely waiver with conditions
   b. Structural / persistent → deeper investigation needed
   c. Deliberate / fraud → enforcement action
4. Options:
   a. Grant waiver (with additional protections: fee, tighter covenant, more security)
   b. Grant amendment (permanently adjust covenant — only if thesis still holds)
   c. Enforce remedies (accelerate, call security — last resort)
```

---

## NBFC Portfolio Monitoring

For NBFC/fintech deals, additional monthly monitoring:

| Metric | Target | Watch Level | Breach |
|--------|--------|-------------|--------|
| GNPA | < ___% | > ___% | > ___% |
| Collection Efficiency | > ___% | < ___% | < ___% |
| CRAR | > ___% | < ___% | < ___% (RBI minimum) |
| AUM Growth | Per model ±10% | Below -10% | Below -20% |
| Credit Cost | < ___% | > ___% | > ___% |
| Top Borrower Concentration | < ___% | > ___% | > ___% |

Track vintage performance monthly — if newer vintages show deteriorating collection rates, the credit model may be weakening.

---

## Annual Review Report

Once per year, produce a comprehensive review:

```
## Annual Review — [Company] — [FY__]

### 1. Performance Summary
- Revenue: Actual vs. Model (___% variance)
- EBITDA: Actual vs. Model (___% variance)
- Key operational metrics: [sector-specific]

### 2. Covenant Compliance
- All covenants: [Compliant / Breach history]
- DSCR trend: [Improving / Stable / Deteriorating]
- Leverage trend: [Deleveraging / Stable / Increasing]

### 3. Thesis Validation
| Original Thesis Pillar | Status | Evidence |
|----------------------|--------|----------|
| [Pillar 1] | Intact / Weakened / Broken | [Data] |
| [Pillar 2] | Intact / Weakened / Broken | [Data] |

### 4. Key Developments
- [Material events during the year]
- [Management changes]
- [Industry shifts]

### 5. Outlook
- Expected performance next year
- Risks to monitor
- Any action required (waiver, amendment, additional security)

### 6. Recommendation
- HOLD (performing as expected)
- WATCH (concerns identified, increase monitoring frequency)
- ACTION (covenant breach or deterioration, engage borrower)
```

---

## Connection to Other Stages

| Stage | Relationship |
|-------|-------------|
| Stage 5 (Model) | Model projections are the monitoring baseline |
| Stage 6 (FDIR) | FDIR monitoring plan defines the framework |
| Stage 2 (HoT) | Covenant framework from HoT is tested quarterly |
| Stage 4 (DD) | DD findings set the risk areas to watch |
