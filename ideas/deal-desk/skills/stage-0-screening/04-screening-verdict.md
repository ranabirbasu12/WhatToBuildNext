# Skill: Screening Verdict

> **Stage**: 0 — Screening
> **Input**: Working File / CMA (from `03-working-file-builder.md`)
> **Output**: Go / Maybe / Kill decision + One-Pager for pipeline meeting
> **Time budget**: 1-2 hours (AI-assisted: 30 minutes)

---

## Purpose

The Screening Verdict is the gate between "interesting deal" and "commit team resources." A Go means you're putting analyst hours, management meeting time, and partner attention behind this deal. A Kill saves everyone's time. A Maybe buys you a week to get the one piece of data that tips the decision.

This skill uses the Ascertis 8-dimension screening framework. This is not invented — it is the actual framework used at Ascertis Credit / BPEA Credit for screening private credit deals.

---

## The 8-Dimension Scorecard

### How Scoring Works

Each dimension gets a traffic light: **Green**, **Amber**, or **Red**.

- **Green**: Clear pass. No concerns on this dimension.
- **Amber**: Pass with caveats. Acceptable but needs monitoring or additional data.
- **Red**: Deal-breaker on this dimension alone, unless exceptional circumstances exist.

> **Source Citation Requirement:** Each dimension's traffic-light rating must cite the evidence source using the format `[Source: <filename>, p.<page>, "<quoted text if key>"]`. For example, Scale rated Green should cite `[Source: AR FY24, p.5, "Revenue: 612 Cr"]` and `[Source: Term Sheet v2, p.1, "Facility: 100 Cr"]`. Unsourced ratings will be challenged by IC.

### Decision Rule

| Scorecard Profile | Decision | Rationale |
|-------------------|----------|-----------|
| 6+ Green, 0 Red | **Go** | Strong deal on most dimensions |
| 4-5 Green, 0 Red, rest Amber | **Go** (with conditions) | Solid deal, amber areas need monitoring |
| Mixed with 1 Red | **Maybe** | Single red may be mitigable — investigate |
| 2+ Red | **Kill** | Multiple fundamental concerns |
| Any Red on DSCR/Scale | **Kill** | Non-negotiable screening filters |

**Real example — Asandas**: 4 Green, 4 Amber, 0 Red. Result: proceeded to full DD.

---

## Dimension 1: Scale

**Question**: Is the company large enough relative to the facility size to absorb this debt?

### Thresholds

| Rating | Revenue / Facility Size Ratio | Notes |
|--------|-------------------------------|-------|
| **Green** | > 5x | Revenue comfortably covers facility. Debt is a modest portion of business. |
| **Amber** | 3x - 5x | Facility is material to the company. Need strong cash flows. |
| **Red** | < 3x | Facility is outsized relative to the business. High concentration risk. |

### Data Sources
- Revenue from extracted financials (trailing twelve months preferred)
- Facility size from term sheet or origination team

### Sector Adjustments
- **NBFC**: Use AUM / Facility Size instead of Revenue. Thresholds: Green > 8x, Amber 5-8x, Red < 5x.
- **Infrastructure**: Use Order Book / Facility Size as a supplementary check. Green > 3x.
- **Real Estate**: Use unsold inventory value / Facility Size. Different risk profile — assess on project basis.

### What to Document
State the ratio. If Amber or Red, note what the company's growth trajectory looks like — a fast-growing company at 4x today might be at 6x in 18 months.

---

## Dimension 2: Profitability

**Question**: Does the company generate enough margin to service debt and absorb shocks?

### Thresholds

| Rating | EBITDA Margin | Notes |
|--------|---------------|-------|
| **Green** | > 20% | Strong margin cushion. Can absorb cost shocks. |
| **Amber** | 15% - 20% | Adequate but limited buffer. Sensitive to input cost changes. |
| **Red** | < 15% | Thin margins. Even small cost increases eat into debt servicing capacity. |

### Data Sources
- EBITDA margin from Working File (use trailing/annualized, not projected)
- 3-year margin trend (expanding, stable, or contracting)

### Sector Adjustments
- **NBFC**: Use ROA (Green > 2.5%, Amber 1.5-2.5%, Red < 1.5%) and ROE (Green > 15%, Amber 10-15%, Red < 10%) instead of EBITDA margin.
- **Trading/Distribution**: Lower margins are structural (Green > 8%, Amber 5-8%, Red < 5%) but offset by higher asset turns.
- **Infrastructure**: Margins vary widely by project type. EBITDA margin of 12-15% can be Green if asset-light and high-turn.
- **Food/FMCG**: Gross margin matters more than EBITDA margin due to distribution costs.

### What to Document
State the margin AND the trend. A company at 18% margin trending up from 14% is very different from one at 18% trending down from 24%.

---

## Dimension 3: Growth

**Question**: Is this a growing business or a declining one borrowing to stay afloat?

### Thresholds

| Rating | Revenue CAGR (3-year) | Notes |
|--------|----------------------|-------|
| **Green** | > 15% | Strong organic growth. Business has demand tailwind. |
| **Amber** | 10% - 15% | Moderate growth. Adequate for debt servicing if margins hold. |
| **Red** | < 10% or declining | Low/negative growth. Deleveraging will rely entirely on repayment, not EBITDA growth. |

### Data Sources
- Revenue from extracted financials (3-year historical CAGR)
- Run-rate analysis from Working File (is current year tracking to growth assumptions?)

### Nuances
- **Lumpy revenue** (infrastructure, project-based): Look at order book growth alongside revenue CAGR. Revenue can be flat while order book doubles — that's actually bullish.
- **Acquisition-driven growth**: Strip out acquisition revenue. What's organic growth? If organic growth is flat, the company is buying growth — different risk profile.
- **Inflation vs real growth**: In high-inflation environments, 10% nominal growth may be 3% real growth. Consider pricing power.

### What to Document
State the CAGR, the run-rate trajectory, and whether growth is organic or inorganic. Flag if growth is decelerating (e.g., 25% → 18% → 12%).

---

## Dimension 4: Track Record

**Question**: Has this company survived business cycles?

### Thresholds

| Rating | Operating History | Notes |
|--------|-------------------|-------|
| **Green** | > 10 years | Survived multiple cycles. Proven management capability. |
| **Amber** | 5 - 10 years | Established but may not have faced a full downturn. |
| **Red** | < 5 years | Unproven. Limited history to assess credit behavior. |

### Data Sources
- Incorporation date from MCA records
- Actual operating history (company may have been dormant or pivoted — check revenue history)

### Nuances
- **Promoter's other ventures**: A 3-year-old company run by a promoter with 25 years of industry experience and other successful ventures is different from a first-time entrepreneur. Weight the promoter's track record.
- **Group history**: If the borrowing entity is a subsidiary/SPV, assess the parent group's track record.
- **COVID disruption**: Many companies show a dip in FY21. Don't penalize this if FY22+ recovery is strong. Look at FY19 as the true pre-COVID baseline.

### What to Document
State years of operation AND what cycles the company has survived (COVID, demonetization, commodity cycles, sector downturns).

---

## Dimension 5: Promoter

**Question**: Is the promoter credible, experienced, and aligned?

### Thresholds

| Rating | Assessment | Indicators |
|--------|------------|------------|
| **Green** | Strong track record, aligned incentives | Clean background, significant skin in the game, no adverse litigation, clear succession plan, willing to provide personal guarantee |
| **Amber** | Acceptable with caveats | Limited public track record, promoter concentration (one-person show), some related party transactions (but explainable), no succession plan |
| **Red** | Material concerns | Regulatory issues, willful default history, CIBIL red flags, significant unexplained related party transactions, active serious litigation, RBI/SEBI enforcement actions |

### Data Sources
- CIBIL/credit bureau check on promoters and KMPs
- MCA records (directorships, DIN-based company search)
- Litigation search (eCourts, NCLT, SAT, High Court databases)
- News/media search for adverse findings
- Shareholding pattern (skin in the game)
- Related party transaction register

### Key Questions
- What percentage of equity does the promoter hold? (Higher = more aligned)
- Is the promoter willing to provide a personal guarantee? (Unwillingness is a red flag)
- Is there a second line of management? (Key-person risk)
- Are there significant related party transactions? (Need to understand the nature and pricing)
- Any history of default, restructuring, or one-time settlement with lenders?

### What to Document
Background summary, skin in the game %, PG willingness, key risks. This is qualitative — write 3-5 sentences, not just a color.

---

## Dimension 6: Rating

**Question**: Has an external rating agency validated the credit quality?

### Thresholds

| Rating | Credit Rating | Notes |
|--------|---------------|-------|
| **Green** | A- or above (any agency) | Investment-grade. External validation of credit quality. |
| **Amber** | BBB+ to BBB- | Sub-investment-grade but rated. Rating rationale provides useful data. |
| **Red** | Below BBB- or Unrated | High-yield or no external assessment. Need stronger security and due diligence. |

### Data Sources
- Current rating and rating history from ICRA, CRISIL, India Ratings, CARE, Brickwork, Acuite
- Rating rationale document (contains peer comparison, key risks, financial summary)

### Nuances
- **Unrated is not automatically Red**: Many mid-market companies (Ascertis's sweet spot) are unrated. An unrated company with strong fundamentals can be Amber if security is strong.
- **Rating watch/outlook**: A BBB+ on rating watch negative is functionally different from a stable BBB+. Note the outlook.
- **Bank ratings vs bond ratings**: Bank facility ratings (e.g., A1+ for short-term) are different from long-term ratings. Use the long-term rating.
- **Rating upgrade trajectory**: A company recently upgraded from BBB to BBB+ signals improving credit quality.

### What to Document
Current rating, agency, date, outlook. If unrated, note why (too small, private, or deliberately avoiding rating costs) and what compensating factors exist.

---

## Dimension 7: Security

**Question**: If the company cannot pay from cash flows, can we recover from assets?

### Thresholds

| Rating | Security Coverage (Asset Value / Facility Size) | Notes |
|--------|------------------------------------------------|-------|
| **Green** | > 2.0x (after haircuts) | Strong asset backing. Recovery likely even in stress. |
| **Amber** | 1.5x - 2.0x (after haircuts) | Adequate but tight. Recovery depends on liquidation conditions. |
| **Red** | < 1.5x (after haircuts) | Insufficient asset backing. Deal is essentially cash-flow-only. |

### Standard Haircuts for Asset Valuation

| Asset Type | Haircut | Rationale |
|------------|---------|-----------|
| Land & Building (urban, clear title) | 25-30% | Liquidation discount + time value |
| Land & Building (rural/industrial) | 40-50% | Limited buyer pool |
| Plant & Machinery (general purpose) | 30-40% | Redeployable to other users |
| Plant & Machinery (specialized) | 50-70% | Limited secondary market |
| Receivables (insured/government) | 10-15% | High recovery probability |
| Receivables (private, unsecured) | 30-40% | Collection risk |
| Inventory (finished goods, non-perishable) | 20-30% | Liquidation discount |
| Inventory (raw material, perishable) | 40-60% | Spoilage and price risk |
| Share pledge (listed, liquid) | 30-40% | Market risk + block deal discount |
| Share pledge (unlisted) | 50-70% | No market, valuation uncertainty |
| Brand/IP/Goodwill | 70-90% | Near-zero liquidation value |

### Security Package Components

Typical private credit security package:
1. **First charge on fixed assets** (land, building, plant & machinery)
2. **First/second charge on current assets** (inventory, receivables)
3. **Share pledge** (promoter shares in the borrowing entity and/or holdco)
4. **Personal guarantee** of promoters
5. **Corporate guarantee** of group companies (if applicable)
6. **DSRA** (Debt Service Reserve Account) — typically 1-2 quarters of debt servicing

### What to Document
List each security component, its estimated value, applicable haircut, and post-haircut value. Sum to get total coverage ratio.

---

## Dimension 8: Exit Path

**Question**: How does the fund get its money back?

### Thresholds

| Rating | Exit Visibility | Notes |
|--------|----------------|-------|
| **Green** | Clear cash flow repayment + multiple refinancing options | DSCR > 1.3x through tenor, company is bankable, rating trajectory positive |
| **Amber** | Cash flow repayment feasible but dependent on single event | Repayment tied to IPO, PE fundraise, or single large contract. Refinancing possible but not certain. |
| **Red** | No clear repayment source | DSCR < 1.0x in outer years, no refinancing visibility, bullet repayment with no clear source |

### Exit Mechanisms (in order of reliability)

1. **Scheduled amortization from cash flows**: Most reliable. DSCR analysis from Working File directly supports this.
2. **Refinancing by banks/NBFCs**: Company gets rated/upgraded, banks take out the private credit facility at lower rates. Common and reliable if company trajectory is positive.
3. **Refinancing by another private credit fund**: Less ideal (higher cost) but provides exit. Depends on market conditions.
4. **Equity event** (IPO, PE investment, strategic sale): Provides lump-sum repayment but is event-dependent and uncertain.
5. **Asset sale**: Last resort for structured deals. Selling a plant/division to repay debt.

### What to Document
Primary exit path AND fallback. E.g., "Primary: scheduled amortization (DSCR 1.4x Ascertis Case). Fallback: bank refinancing (company likely ratable at BBB+ by FY27 given growth trajectory)."

---

## The One-Pager

The One-Pager is presented at the Monday pipeline meeting. It must fit on a single page (printed or on-screen). Senior partners spend 2-3 minutes per deal at this stage.

### Template

```
═══════════════════════════════════════════════════════════════
                    SCREENING SUMMARY
═══════════════════════════════════════════════════════════════

Company:        [Name]
Sector:         [Sector / Sub-sector]
Facility:       [INR __ Cr / Type: Term Loan / NCD / RPS / etc.]
Tenor:          [__ months]
Proposed IRR:   [__% gross]
Source:         [Origination channel]
Date:           [DD-MMM-YYYY]

───────────────────────────────────────────────────────────────
                    SCORECARD
───────────────────────────────────────────────────────────────

  Dimension       Rating    Key Data Point
  ─────────       ──────    ──────────────
  Scale           [G/A/R]   Revenue __ Cr / Facility __ Cr = __x
  Profitability   [G/A/R]   EBITDA margin __% (3Y avg: __%)
  Growth          [G/A/R]   Revenue CAGR __% (FY__-FY__)
  Track Record    [G/A/R]   __ years operating history
  Promoter        [G/A/R]   [1-line assessment]
  Rating          [G/A/R]   [Rating / Unrated]
  Security        [G/A/R]   Coverage: __x (post-haircut)
  Exit Path       [G/A/R]   [Primary exit mechanism]

───────────────────────────────────────────────────────────────
                    INVESTMENT THESIS
───────────────────────────────────────────────────────────────

[3 lines maximum. What makes this deal attractive? Why does the
company need private credit instead of bank funding? What's the
structural advantage?]

───────────────────────────────────────────────────────────────
                    KEY RISK
───────────────────────────────────────────────────────────────

[Single biggest concern in 1-2 sentences. What could go wrong?]

───────────────────────────────────────────────────────────────
                    DSCR SNAPSHOT
───────────────────────────────────────────────────────────────

              FY__  FY__  FY__  FY__  FY__
  Mgmt Case:  __x   __x   __x   __x   __x
  Ascertis:   __x   __x   __x   __x   __x

───────────────────────────────────────────────────────────────
                    RECOMMENDATION
───────────────────────────────────────────────────────────────

  [GO / MAYBE / KILL]

  [2-sentence rationale]

  Next Steps (if Go):
  - [e.g., Schedule management meeting — week of DD-MMM]
  - [e.g., Commission industry research on sector]
  - [e.g., Begin concept paper drafting]

  Additional Data Needed (if Maybe):
  - [e.g., Audited FY25 financials expected by MM-YYYY]
  - [e.g., Clarification on group structure / related parties]

  Kill Rationale (if Kill):
  - [1-line reason]

═══════════════════════════════════════════════════════════════
```

---

## Meeting Prep: First Management Meeting Questions

When the verdict is Go or Maybe, prepare a prioritized question list for the first management meeting. Questions are sourced from the Comments Column in the Working File and organized by priority.

### Priority 1: Address Red/Amber Dimensions

For each Amber or Red dimension, formulate 2-3 specific questions:

- **Scale (Amber)**: "Walk us through revenue visibility for the next 12-18 months. What gives you confidence in the growth trajectory?"
- **Profitability (Amber)**: "EBITDA margin expanded from 16% to 22% in FY24. What drove this? Is it sustainable or driven by one-off factors?"
- **Promoter (Amber)**: "We noticed [specific related party transaction / litigation / concern]. Can you walk us through this?"

### Priority 2: Validate Projections Against Run-Rate

- "Your FY25 projection is INR X Cr revenue. 9-month actuals annualized suggest INR Y Cr. What do you expect to change in Q4?"
- "You're projecting EBITDA margin of X% in FY26, up from Y% currently. What specific actions drive this improvement?"
- "Capex of INR X Cr is planned for FY26. What's the timeline, and when does the new capacity start contributing to revenue?"

### Priority 3: Use of Proceeds and Facility Structure

- "Walk us through the specific use of INR X Cr being raised. What's the deployment timeline?"
- "How does this facility fit into your overall capital structure? What's the target Debt/EBITDA post-disbursement?"
- "Are you in discussions with other lenders for this facility? What terms are being discussed?"

### Priority 4: Promoter Commitment and Governance

- "Would the promoters be willing to provide a personal guarantee?"
- "What's the succession plan? Who runs the business if the promoter is unavailable?"
- "Walk us through the group structure and the rationale for having multiple entities."

### Priority 5: Working File Flags

All `[Q-MGMT]` items from the Working File Comments Column, grouped thematically.

---

## What Feeds Forward If Go

The screening stage produces artifacts that carry into subsequent stages. Nothing is wasted — but the SPREADSHEET is disposable. What survives is KNOWLEDGE.

### Artifact Flow

| Screening Output | Feeds Into | How |
|------------------|-----------|-----|
| Clean financial extraction | Concept Paper financial tables | Numbers are reused directly |
| DSCR / IRR from Working File | CP transaction overview section | Key metrics cited in the CP |
| Run-rate analysis | CP financial analysis | Validates management projections |
| Red flags from Comments Column | CP risk section | Each flag becomes a risk to mitigate |
| `[Q-MGMT]` items | IRL (Information Request List) | Management meeting agenda items become formal data requests |
| `[FLAG]` items | DD scope definition | Flags define where DD needs to dig deeper |
| Scorecard rationale | CP investment thesis | The "why" from Green dimensions becomes the thesis |
| Peer comparison | CP market context section | Positioning vs peers |
| Security assessment | CP security section | Proposed security package and coverage |

### The Disposable Model Principle

The screening Working File is a ROUGH model. It uses management projections, limited data, and quick assumptions. The full credit model built during DD will be built from scratch with:
- Audited financials (not management-provided summaries)
- Verified assumptions (not management projections)
- Granular WC modeling (not high-level days calculations)
- Detailed capex phasing (not lump sums)
- Multiple scenarios (not just Management vs Ascertis two-case)

Do NOT try to make the screening model perfect. Its purpose is to get to a Go/Kill decision quickly. Perfectionism at screening stage is a time sink.

---

## Kill Postmortem

When the verdict is Kill, document the rationale. Deals come back. DP Jain was dropped after initial screening but returned later as "Project Bolt." Having the kill rationale on file saves significant time.

### Kill Documentation Template

```
KILL POSTMORTEM
═══════════════

Company:    [Name]
Date:       [DD-MMM-YYYY]
Screened by: [Analyst / VP]

KILL REASONS (3-5 bullets):
1. [Primary reason — the deal-breaker]
2. [Secondary reason]
3. [Supporting concern]
4. [Supporting concern]
5. [Additional context if needed]

WHAT WOULD CHANGE OUR MIND:
- [Condition 1 — e.g., "If EBITDA margin improves to >18% with audited FY26 results"]
- [Condition 2 — e.g., "If promoter resolves pending litigation"]
- [Condition 3 — e.g., "If facility size reduces to INR X Cr (bringing leverage to <4x)"]

SCORECARD AT TIME OF KILL:
[Paste the 8-dimension scorecard]

FILE LOCATION:
[Where the screening Working File is saved for reference]
```

### Why This Matters

- **Deals resurface**: Promoters come back with different structures, better numbers, or through different intermediaries. The kill postmortem provides instant context.
- **Pattern recognition**: After 20+ kill postmortems, you see patterns (e.g., "we keep killing high-leverage infra companies" or "unrated companies with thin margins never pass"). This sharpens the funnel.
- **Accountability**: If a killed deal later defaults with another lender, the kill postmortem validates the screening process. If a killed deal later succeeds spectacularly, the postmortem helps calibrate whether the fund's screening is too conservative.

---

## Common Screening Mistakes

1. **Falling in love with the sector, not the company**: "Indian NBFC sector is booming" doesn't make every NBFC a good credit. Screen the company, not the macro.

2. **Ignoring the run-rate**: Management projections are aspirational by definition. The run-rate is reality. If there's a 20%+ gap between run-rate and projection, you have a projection credibility problem.

3. **Confusing growth with creditworthiness**: A company growing 30% YoY with a 10% margin and 5x leverage is riskier than a company growing 8% with 25% margins and 2x leverage. Growth is nice; coverage is essential.

4. **Not stress-testing DSCR**: The Management Case DSCR is a feel-good number. The only DSCR that matters for credit is the Ascertis Case (25% haircut). If the deal only works in the Management Case, it doesn't work.

5. **Screening too slowly**: Screening should take 1-2 days, not 1-2 weeks. The purpose is a quick filter, not a comprehensive analysis. Save the deep work for DD.

6. **Not documenting the Kill**: Every killed deal should have a postmortem. It takes 15 minutes and saves hours when the deal inevitably comes back.

---

## Checklist Before Issuing Verdict

- [ ] All 8 dimensions scored with supporting data
- [ ] DSCR checked in both Management and Ascertis cases
- [ ] Run-rate analysis completed and gap assessed
- [ ] One-Pager drafted for pipeline meeting
- [ ] If Go: Management meeting questions prepared
- [ ] If Go: Next steps defined with timeline
- [ ] If Maybe: Specific data/conditions identified that would tip the decision
- [ ] If Kill: Postmortem documented with 3-5 reasons and reversal conditions
- [ ] Comments Column items from Working File categorized and routed
- [ ] Senior (VP/Principal) has reviewed and aligned on the recommendation
