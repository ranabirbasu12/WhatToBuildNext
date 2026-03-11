# Stage 2 Orchestrator: Head of Terms (HoT)

You are helping an associate negotiate and finalize a Head of Terms with the borrower. The goal of this stage is: **"Lock in the commercial terms before we spend on DD."**

The deliverable is a **signed HoT** — a document that captures facility size, instrument type, coupon/IRR, tenure, security package, key covenants, and conditions precedent. The HoT is non-binding on credit approval but binding on exclusivity and cost-sharing.

**This stage runs in PARALLEL with Stage 3 (Industry Research).** Neither blocks the other. HoT negotiation and industry deep-dive happen simultaneously.

---

## Sub-Skills

| Sub-Skill | File | Purpose |
|-----------|------|---------|
| Terms Design | `01-terms-design.md` | Draft the opening position — economics, structure, covenants |
| Redline Tracker | `02-redline-tracker.md` | Track 4-12 rounds of negotiation changes |
| Covenant Framework | `03-covenant-framework.md` | Design financial and portfolio covenants with testing mechanics |

---

## Inputs from Stage 1

The HoT builds on the Concept Paper's indicative terms:

| From Stage 1 | Used In |
|--------------|---------|
| Indicative terms table | Opening position for negotiation |
| Transaction structure diagram | Basis for legal structure in HoT |
| Security package summary | Starting point for security terms |
| Risk register | Informs covenant design (what risks need monitoring?) |
| IC conditions (if any) | Constraints on term flexibility |

---

## The Real Workflow

### Sequencing Varies

**Traditional sequence (Casablanca, Asandas):** CP approved → HoT issued → negotiation → signed HoT → DD begins.

**Fast-tracked (MPokket):** HoT signed (Aug 29, 2023) BEFORE CP finalized (Sep 2023). This happens when the borrower has multiple funding options and the fund needs to lock exclusivity quickly. The CP is then prepared in parallel to formalize what's already been agreed.

### The Negotiation Cycle

```
IC approves Concept Paper
    |
    v
[TERMS DESIGN] -----> Draft HoT with opening position
    |                  Internal review (SM → CIO)
    |                  Send to borrower / borrower's counsel
    |
    v
[REDLINE ROUNDS] -----> Borrower returns marked-up version
    |                    4-12 rounds typical
    |                    Track changes in Word, issue-by-issue resolution
    |                    Key negotiation points:
    |                    - Coupon / IRR (always contested)
    |                    - Security scope (what's pledged, what's excluded)
    |                    - Covenant levels (tightness vs. headroom)
    |                    - Conditions precedent (what must be true before disbursement)
    |                    - Exclusivity period and break fee
    |
    v
[COVENANT FRAMEWORK] -----> Finalize covenant suite
    |                        Financial covenants (DSCR, leverage, NW)
    |                        Information covenants (MIS frequency, audit timeline)
    |                        Negative covenants (no additional debt, no asset sale)
    |                        Portfolio covenants (NBFC: GNPA cap, CE floor, ALM)
    |
    v
Both parties sign HoT
    |
    v
DD can now proceed with terms locked (Stage 4)
```

### What Gets Negotiated Hardest

Based on real deal patterns:

| Term | Fund Position | Borrower Pushback | Resolution Pattern |
|------|--------------|-------------------|--------------------|
| **Coupon** | Higher (12-14%) | Lower (10-11%) | Meet in middle, compensate with upside premium |
| **Upside Premium** | 5-7% of exit EV | Reduce or cap | May add performance thresholds |
| **Make-Whole Period** | 36 months | 24 months or none | Compromise at 30 months |
| **Security Scope** | 1st exclusive charge on all assets | Carve out specific assets | Negotiate carve-out list |
| **DSCR Covenant** | 1.5x minimum | 1.25x or tested annually | 1.3x with cure period |
| **Information Rights** | Monthly MIS + quarterly audited | Quarterly only | Monthly MIS + quarterly financials |
| **Negative Pledge** | No additional debt without consent | Permitted debt basket (INR X Cr) | Basket with conditions |
| **Conditions Precedent** | Long list (20+ CPs) | Minimize, defer to post-disbursement | Split into pre- and post-disbursement |

### The Review Chain for HoT

```
Associate drafts opening HoT (you)
    ↓
SM / Deal Lead reviews → structural and commercial adjustments
    ↓
CIO (KG) reviews → strategy and pricing sign-off
    ↓
Legal counsel reviews → legal language and enforceability
    ↓
Send to borrower → negotiation begins
    ↓
4-12 redline rounds (borrower counsel ↔ fund counsel ↔ deal team)
    ↓
SM / CIO approve final terms → sign
```

### Filename Convention

```
[Project Code]_HoT_v1.docx                 (opening position)
[Project Code]_HoT_v2_borrower.docx        (borrower markup)
[Project Code]_HoT_v3.docx                 (fund response)
[Project Code]_HoT_v4_redline.docx         (tracked changes)
...
[Project Code]_HoT_vFinal.docx             (agreed terms)
[Project Code]_HoT_executed.pdf            (signed copy)
```

---

## Key Structural Decisions at HoT Stage

These decisions are made during HoT negotiation and lock in the deal architecture:

### 1. Instrument Type
| Instrument | When Used | Key Implication |
|-----------|-----------|-----------------|
| **Senior Secured NCDs** | Standard — most deals | Fixed coupon, asset-backed, priority in waterfall |
| **CCDs (Compulsorily Convertible Debentures)** | When equity upside needed | HoldCo issues CCDs → converts to equity. NBFC classification risk |
| **Combination (NCD + CCD)** | Complex structures | Debt return + equity kicker. Tax and regulatory complexity |

### 2. Single vs. Multiple Tranches
- **Single tranche**: Simpler. All funds disbursed at once or on a draw-down schedule
- **Multiple tranches**: Different purposes (e.g., Casablanca: INR 250 Cr acquisition + INR 100 Cr refinance). Different coupon rates per tranche possible

### 3. Direct vs. HoldCo Structure
- **Direct to operating company**: Cleanest. Security on operating assets
- **Through HoldCo**: When promoter wants structural flexibility or when CCD mechanism is used. Adds NBFC classification risk. Requires robust cascade (HoldCo → OpCo flow of funds)

---

## What the HoT Does NOT Cover

The HoT is a commercial framework, not a legal document. These are deferred to Stage 8 (Execution):

- Detailed representations and warranties
- Specific security documentation (mortgage deed, pledge agreement)
- Board and shareholder resolution formats
- Escrow agreement mechanics
- Detailed condition precedent satisfaction process
- Stamp duty and registration requirements

The HoT says "1st exclusive charge on all fixed assets" — the legal documentation (Stage 8) defines exactly which assets, how the charge is created, and what happens in default.

---

## Connection to Other Stages

| Stage | Relationship |
|-------|-------------|
| Stage 1 (Concept Paper) | Indicative terms become HoT opening position |
| Stage 3 (Industry) | Runs in parallel. Industry findings may influence covenant design |
| Stage 4 (DD) | DD begins after HoT signed. HoT terms become DD assumptions |
| Stage 5 (Model) | Model uses HoT terms for returns analysis and covenant testing |
| Stage 6 (FDIR) | FDIR presents final negotiated terms from HoT |
| Stage 8 (Execution) | HoT terms converted to legal documentation |

---

## What Success Looks Like

A good HoT:
1. **Protects the fund's economics** — coupon, upside, make-whole period locked in
2. **Provides adequate security** — coverage ratio at multiple valuation scenarios
3. **Has enforceable covenants** — not so tight they trigger false alarms, not so loose they're meaningless
4. **Is commercially acceptable** — borrower will actually sign it (an unsigned HoT is worthless)
5. **Maps cleanly to legal docs** — no ambiguity that creates Stage 8 disputes

A bad HoT:
1. Over-promises on economics (borrower won't sign)
2. Under-protects on security (IC won't approve final deal)
3. Has vague covenant language (lawyers will exploit ambiguity)
4. Doesn't address structural risks identified in CP (they'll surface in DD)
5. Takes 15+ redline rounds (deal fatigue kills transactions)
