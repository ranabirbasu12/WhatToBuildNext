# Stage 2.2: Redline Tracker

You are managing the negotiation cycle between the fund and the borrower on the Head of Terms. This is an iterative process — 4-12 redline rounds is typical — and the associate's job is to track every change, understand the commercial impact, and brief the deal team on what's being conceded.

---

## How Redlining Works

The HoT is a Word document with Track Changes. Each round follows this pattern:

```
Fund sends clean v[N] to borrower
    ↓
Borrower's counsel returns marked-up v[N] (Track Changes ON)
    ↓
Associate reviews every change, categorizes by impact
    ↓
Associate briefs deal lead on material changes
    ↓
Deal team decides: accept / reject / counter-propose each change
    ↓
Fund sends clean v[N+1] to borrower
    ↓
Repeat until all issues resolved
```

### Filename Convention Through Rounds

```
Round 1: [Project]_HoT_v1.docx                    (fund opening)
Round 2: [Project]_HoT_v1_borrower_markup.docx     (borrower response)
Round 3: [Project]_HoT_v2.docx                    (fund counter)
Round 4: [Project]_HoT_v2_borrower_markup.docx     (borrower response)
...
Final:   [Project]_HoT_vFinal.docx                (agreed)
Signed:  [Project]_HoT_executed.pdf               (scanned signed copy)
```

---

## The Change Tracking Matrix

For every redline round, maintain a tracking matrix:

```
| # | Clause | Fund Position | Borrower Ask | Impact | Status |
|---|--------|--------------|-------------|--------|--------|
| 1 | Coupon | 13% | 10.5% | HIGH — IRR drops 250 bps | Negotiating |
| 2 | Make-Whole | 36 months | 24 months | MEDIUM — early exit risk | Counter at 30m |
| 3 | DSCR Floor | 1.5x | 1.25x | HIGH — weakens protection | Hold firm |
| 4 | Security Scope | All fixed assets | Exclude Plant 3 | MEDIUM — coverage drops | Need valuation |
| 5 | Info Rights | Monthly MIS | Quarterly only | LOW — visibility gap | Accept quarterly fin + monthly KPIs |
| 6 | Dividend Restriction | Full lock-up | Above 1.5x DSCR | LOW — aligned with DSCR | Accept |
```

### Impact Classification

| Category | Definition | Examples |
|----------|-----------|----------|
| **HIGH** | Materially affects fund economics or protection | Coupon reduction, security carve-out, covenant loosening |
| **MEDIUM** | Affects deal comfort but has workarounds | Make-whole reduction, CP timeline extension, information frequency |
| **LOW** | Administrative or cosmetic | Definitions, notice periods, reporting deadlines |

### Decision Framework for Each Change

For each borrower markup:

1. **Is this change material?** (Does it affect IRR, security coverage, or covenant protection?)
2. **Can we accept it?** (Is it within the IC's tolerance range?)
3. **What do we get in return?** (Never concede without getting something back)
4. **What's the BATNA?** (If we don't agree, does the deal die or does the borrower have alternatives?)

---

## Common Negotiation Patterns

### Pattern 1: Coupon Compression
Borrower always pushes for lower coupon. Standard response:
- Accept lower coupon IF upside premium increases proportionally
- Accept lower coupon IF make-whole period extends
- Accept lower coupon IF security scope expands

**Example**: Coupon drops from 13% to 11%, but upside premium increases from 5% to 6.5% of exit EV. Total IRR remains within target range.

### Pattern 2: Security Carve-Outs
Borrower wants to exclude specific assets from the charge (typically to preserve flexibility for other lenders or asset sales).

**Analysis framework:**
```
Current coverage: [All assets] / [Facility size] = ___x
After carve-out: [Remaining assets] / [Facility size] = ___x
Minimum acceptable: 1.3x coverage

If post-carve-out coverage > 1.5x → can consider accepting
If post-carve-out coverage < 1.3x → reject or require additional security
```

### Pattern 3: Covenant Headroom
Borrower argues covenants are too tight and will trigger technical defaults even when the business is healthy.

**Analysis framework:**
```
Proposed DSCR covenant: 1.5x
Borrower's current DSCR: 1.8x
Headroom: 0.3x (17%)

Industry DSCR in downside: ~1.3x (from Stage 3 industry research)
Proposed floor should be: below downside scenario → 1.2-1.3x
But should provide early warning → 1.3-1.4x

Counter: 1.35x with 30-day cure period
```

### Pattern 4: Conditions Precedent Reduction
Borrower wants fewer pre-disbursement CPs to speed up closing.

**Classify CPs as:**
- **Non-negotiable**: DD completion, legal opinion, security creation, KYC
- **Can defer to post-disbursement**: Mortgage registration, insurance assignment, minor administrative items
- **Can remove**: Items already satisfied or redundant

### Pattern 5: Permitted Debt Basket
Borrower wants ability to raise additional debt without fund consent.

**Analysis:**
```
Facility size: INR ___ Cr
Proposed additional debt limit: INR ___ Cr
Total potential debt: INR ___ Cr
Maximum leverage (covenant): ___x EBITDA
EBITDA (current): INR ___ Cr

If total potential debt / EBITDA > covenant level → reject basket
If basket is <15% of facility → likely acceptable with conditions
```

---

## Escalation Triggers

Certain borrower requests must be escalated to the deal lead / CIO immediately:

| Trigger | Why Escalate |
|---------|-------------|
| Coupon reduction > 200 bps | Below fund hurdle rate risk |
| Security scope reduced > 30% | Coverage ratio compromised |
| DSCR covenant below 1.2x | Insufficient early warning |
| Removal of personal guarantee | Promoter skin-in-game removed |
| Change of control consent removed | No protection against ownership change |
| Exclusivity period shortened < 30 days | Not enough time for DD |
| New structural complexity introduced | May require IC re-approval |

---

## Round-by-Round Status Report

After each redline round, produce a status summary for the deal team:

```
## HoT Negotiation — Round [N] Summary

**Date:** [DD/MM/YYYY]
**Outstanding Issues:** [X] of [Total]

### Resolved This Round
| # | Clause | Resolution | Impact on Returns |
|---|--------|-----------|-------------------|
| _ | ______ | _________ | _________________ |

### Still Open
| # | Clause | Gap | Recommended Position |
|---|--------|-----|---------------------|
| _ | ______ | ___ | ___________________ |

### Returns Impact
| Scenario | Original IRR | Current IRR | Change |
|----------|-------------|-------------|--------|
| Base Case | ___% | ___% | ___bps |
| Downside | ___% | ___% | ___bps |

### Recommendation
[Accept current position / Push back on [specific items] / Escalate to CIO]
```

---

## When Negotiation Stalls

If negotiations exceed 8 rounds without convergence:

1. **Identify the blocker** — what specific clause is stuck?
2. **Propose creative solutions** — can the issue be solved structurally? (e.g., step-down coupon instead of flat rate, performance-linked covenant instead of fixed)
3. **Assess walk-away value** — is this deal worth the remaining gap?
4. **Escalate** — deal lead / CIO call with borrower's decision-maker (not just lawyers)

Deal fatigue is real. After 10+ rounds, both sides become entrenched. Sometimes a principals-level call resolves in 30 minutes what lawyers couldn't in 3 weeks.

---

## Output

The redline tracker produces:
1. **Change tracking matrix** (updated each round)
2. **Status summary** (after each round)
3. **Running IRR impact analysis** (how concessions affect returns)
4. **Escalation flags** (when to involve deal lead / CIO)
5. **Final agreed terms summary** (when negotiation concludes)

The final agreed terms feed into the Covenant Framework (`03-covenant-framework.md`) for detailed design and into Stage 8 (Execution) for legal documentation.
