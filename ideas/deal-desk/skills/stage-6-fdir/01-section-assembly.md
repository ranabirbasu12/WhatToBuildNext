# Stage 6.1: FDIR Section Assembly

You are assembling each section of the FDIR from prior stage outputs. This guide maps every section to its source, specifies what needs updating, and defines the quality bar for each.

---

## Section 1: Investment Recommendation Checklist (2-3 pages)

**Source:** Updated from Stage 1 CP Checklist + DD evidence.

This is the FDIR's most important section — the IC reads it first.

```
INVESTMENT RECOMMENDATION CHECKLIST

Project: [Codename] | Company: [Name]
Date: [DD/MM/YYYY] | Deal Lead: [Name] | Prepared by: [Name]

| # | Dimension | CP Assessment | FDIR Assessment | Key Evidence |
|---|-----------|--------------|-----------------|-------------|
| 1 | Sponsor/Business | Yes/TBD | Yes/No | [DD-validated evidence] |
| 2 | Financial Health | Yes/TBD | Yes/No | [Model output reference] |
| 3 | Industry & Competition | TBD | Yes/No | [Industry note + GLG findings] |
| 4 | Transaction Structure | TBD | Yes/No | [Legal DD + HoT outcome] |
| 5 | Yield | Yes | Yes/No | [Model IRR under Ascertis Case] |

Overall Recommendation: INVEST / DO NOT INVEST
Conditions (if any): [List]
```

**Key difference from CP Checklist:** Every TBD must now be resolved to Yes or No. If a TBD remains, it means DD failed to resolve the question — and that itself is a finding to discuss.

---

## Section 2: Executive Summary (1-2 pages)

**Source:** Written fresh. Do NOT copy from CP — that's 3-6 months old and based on pre-DD information.

Structure:
```
Paragraph 1: The opportunity
  - [Company name] is [what they do]. We propose investing INR [X] Cr via
    [instrument] for [purpose]. [One sentence on why this is attractive.]

Paragraph 2: Investment thesis (updated with DD evidence)
  - [2-3 thesis pillars, each with DD-validated evidence. Not assertions.]

Paragraph 3: Key terms
  - [Facility: INR X Cr. Tenor: X months. Coupon: X%. Target IRR: X%.]
  - [Security: brief summary. Covenants: DSCR ≥ Xx, Leverage ≤ Xx.]

Paragraph 4: Key risks and mitigants
  - [Top 2-3 risks from Stage 4 DD, with mitigants verified.]

Paragraph 5: Recommendation
  - [We recommend proceeding subject to [conditions].]
```

---

## Section 3: Transaction Overview (2-3 pages)

**Source:** Stage 2 (HoT — final negotiated terms).

Present the final terms table:

| Parameter | Terms |
|-----------|-------|
| Issuer | [Entity] |
| Instrument | [NCD/CCD] |
| Facility Size | INR ___ Cr |
| Tenor | ___ months |
| Coupon | ___% p.a. |
| Upside | ___% of Exit EV |
| Security | [Summary] |
| Key Covenants | DSCR ≥ ___x, Leverage ≤ ___x |
| Use of Proceeds | [Breakdown] |

Include the flow-of-funds diagram showing exactly how money moves from fund vehicle to operating entity.

---

## Section 6: Financial Analysis (5-7 pages — longest section)

**Source:** Stage 4 (Financial DD) + Stage 5 (Model).

### Historical Financials (DD-Adjusted)

Present 3-5 year historical P&L, BS, and key ratios using DD-adjusted numbers (not raw audited). Include the adjustments bridge:

```
| Item | FY22 | FY23 | FY24 |
|------|------|------|------|
| Reported EBITDA | ___ | ___ | ___ |
| QoE Adjustment 1: [Description] | (___) | (___) | (___) |
| QoE Adjustment 2: [Description] | ___ | ___ | ___ |
| Adjusted EBITDA | ___ | ___ | ___ |
| Adjusted EBITDA Margin | ___% | ___% | ___% |
```

### Working Capital Analysis

```
| Metric | FY22 | FY23 | FY24 |
|--------|------|------|------|
| Debtor Days | ___ | ___ | ___ |
| Inventory Days | ___ | ___ | ___ |
| Creditor Days | ___ | ___ | ___ |
| Net WC Cycle | ___ | ___ | ___ |
| Net WC (INR Cr) | ___ | ___ | ___ |
| Change in WC (INR Cr) | ___ | ___ | ___ |
```

### Cash Flow Bridge

```
Adjusted EBITDA → OCF → FCF → Post-Debt-Service Cash Flow
(Show the full bridge from Stage 4 Financial DD)
```

### Key Ratios

```
| Ratio | FY22 | FY23 | FY24 | Trend | Comment |
|-------|------|------|------|-------|---------|
| Revenue Growth | | | | ↑/↓/→ | |
| EBITDA Margin (Adjusted) | | | | | |
| DSCR | | | | | |
| Net Debt/EBITDA | | | | | |
| Current Ratio | | | | | |
| OCF/EBITDA | | | | | |
```

---

## Section 8: Projected Financials & DSCR (3-4 pages)

**Source:** Stage 5 (Model).

### Projected P&L Summary

```
| (INR Cr) | FY24 (Actual) | FY25E | FY26E | FY27E | FY28E |
|----------|--------------|-------|-------|-------|-------|
| Revenue | ___ | ___ | ___ | ___ | ___ |
| EBITDA | ___ | ___ | ___ | ___ | ___ |
| EBITDA Margin | ___% | ___% | ___% | ___% | ___% |
| PAT | ___ | ___ | ___ | ___ | ___ |
```

Present under Ascertis Case (base case for IC). Footnote Management Case numbers.

### DSCR Schedule

```
| Quarter | DSCR | Covenant | Pass? |
|---------|------|----------|-------|
| [Every quarter for facility tenor] |
| Minimum | ___x | ___x | ✓/✗ |
| Average | ___x | | |
```

### Leverage Trajectory

```
| Year | Net Debt/EBITDA | Covenant | Comment |
|------|----------------|----------|---------|
| Entry | ___x | ___x | |
| FY+1 | ___x | ___x | |
| FY+2 | ___x | ___x | |
| Exit | ___x | ___x | |
```

### Returns

```
| Scenario | IRR | MOIC |
|----------|-----|------|
| Ascertis Case (Base) | ___% | ___x |
| Management Case | ___% | ___x |
| Downside (No Upside) | ___% | ___x |
```

---

## Section 9: Sensitivity & Scenarios (2-3 pages)

**Source:** Stage 5 (Model sensitivity tables).

Include:
1. 2D sensitivity matrix (revenue growth × EBITDA margin → IRR)
2. DSCR sensitivity to EBITDA decline
3. Break-even analysis (EBITDA at DSCR = 1.0x)
4. Covenant headroom analysis

---

## Section 10: Risk Matrix (3-4 pages)

**Source:** Stage 1 (CP risks) + Stage 4 (DD findings) — evolved and validated.

### Updated Risk Register

Every CP risk now has DD evidence attached:

```
| # | Risk | CP Severity | FDIR Severity | DD Finding | Mitigant |
|---|------|------------|--------------|-----------|----------|
| 1 | Customer concentration | Critical | Critical | Confirmed: BK >90% | Diversification plan + covenant |
| 2 | Entry leverage | Investigate | Material | 6.3x confirmed | Step-down covenant + deleveraging |
| 3 | NBFC classification | Investigate | Resolved | Legal opinion obtained | Structure approved by counsel |
| 4 | Margin sustainability | Critical | Material | FY24 one-time confirmed | 18-20% used in Ascertis Case |
```

**New risks from DD** (not in CP): Add any findings that emerged during DD.

---

## Section 13: Monitoring Plan (1-2 pages)

**Source:** New — sets up Stage 9.

```
| Deliverable | Frequency | Deadline | What to Monitor |
|-------------|-----------|----------|-----------------|
| Monthly MIS | Monthly | T+15 days | Revenue, EBITDA, cash position, key KPIs |
| Covenant Test | Quarterly | T+30 days | DSCR, leverage, NW, portfolio covenants |
| Annual Financials | Annual | T+90 days | Full audit, covenant recalculation |
| Site Visit | Semi-annual | Scheduled | Operations, capacity, management meetings |
| Board Observer | Quarterly | Board meeting | Strategy, capex decisions, related parties |
```

---

> **Source Citation Requirement:** When FDIR sections pull data from prior stages, cite the ORIGINAL source document — not just the intermediate stage output. For example, write `[Source: Audited P&L FY24, p.22]` rather than "from screening model" or "per Working File." Use the format `[Source: <filename>, p.<page>, "<quoted text if key>"]`. The IC must be able to trace any number in the FDIR back to a primary document without re-reading Stage 0-5 outputs.

## Quality Checklist Before Submission

- [ ] All sections present and in correct order
- [ ] Recommendation checklist fully resolved (no TBDs)
- [ ] Executive summary is self-contained and current (not stale CP text)
- [ ] Financial numbers reconcile across sections (P&L, ratios, DSCR all consistent)
- [ ] Model outputs match FDIR tables exactly
- [ ] All risks have DD evidence and mitigants
- [ ] Terms match final HoT (not indicative CP terms)
- [ ] Page numbers, table of contents, headers/footers correct
- [ ] Company name and project code consistent throughout
- [ ] No tracked changes or comments visible in final PDF

---

## Output

The section assembly produces:
1. **Complete FDIR document** (35-45 pages, all sections populated)
2. **Source tracing document** (which section came from which stage)
3. **Reconciliation check** (numbers consistent across all sections)

This feeds into IC Preparation (`02-ic-prep.md`) for the presentation and defense strategy.
