# Stage 0 Orchestrator: Screening

You are helping an associate screen a new deal opportunity. The goal of this stage is to answer one question: **"Is this worth our time and DD budget?"**

The deliverable is a screening model (Excel workbook) and a verdict (Go / Maybe / Kill) that will be presented at the Monday pipeline meeting.

**This entire stage is DISPOSABLE.** The screening model does not survive to Stage 5. When the deal progresses, the full financial model is built from scratch with DD-validated data. The screening model exists only to make the Go/Maybe/Kill decision — nothing more.

---

## Sub-Skills

This stage is broken into 4 sub-skills, executed roughly in sequence but with frequent backtracking:

| Sub-Skill | File | Purpose |
|-----------|------|---------|
| Data Triage | `01-data-triage.md` | Categorize what we received, identify gaps, seed the IRL |
| Financial Extraction | `02-financial-extraction.md` | Scanned PDFs to structured financials in BPEA format |
| Working File Builder | `03-working-file-builder.md` | Analytical layer — ratios, run-rate, cases |
| Screening Verdict | `04-screening-verdict.md` | 8-dimension scorecard + Go/Maybe/Kill recommendation |

---

## The Real Workflow

### How Data Arrives

**Channel 1 — Promoter Direct** (e.g., Omsairam, DP Jain):
The data arrives in waves. First, a few scanned PDFs of audited financials. Then some provisional numbers in a rough Excel. Then MCA filings someone pulled. Then a WhatsApp photo of a board resolution. There is no data room, no pitch book, no narrative. You are starting from raw materials.

The first job is just figuring out what you have. How many entities? What years? What's audited vs provisional vs management-prepared? What's missing that you need to request?

**Channel 2 — Investment Bank Sourced**:
You get a pitch book (30-50 slides), a virtual data room with organized folders, and sometimes a pre-built model. The pitch book gives you a narrative frame — company overview, transaction rationale, financial summary. This accelerates Stage 0 significantly because someone else has already organized the information.

But you still extract and verify everything independently. The bank's numbers are marketing materials. You rebuild from the audited financials yourself.

### The Actual Sequence

```
Data Lands
    |
    v
[DATA TRIAGE] -----> What do we have? What entities, what years, what types?
    |                 What's missing? Create Information Request List (IRL)
    |                 IRL goes to promoter/bank → wait for responses
    |
    v
[FINANCIAL EXTRACTION] -----> Scanned PDFs → Draft 1 (raw extraction)
    |                         Draft 2 (cross-check with MCA/notes)
    |                         Draft 3 (consolidation if multi-entity)
    |   ^                     Draft 4 (SM review incorporation)
    |   |                     Draft 5 (additional data incorporated)
    |   |                     Draft 6 (final extraction — "clean" numbers)
    |   |
    |   +--- New data arrives (IRL response, additional years, restated figures)
    |        GO BACK to extraction. This is normal. It happened 6 times on Omsairam.
    |
    v
[WORKING FILE BUILDER] -----> DSCR, Debt/EBITDA, Interest Coverage
    |                          Working capital days (debtor, creditor, inventory)
    |                          Revenue concentration (top 5 customers, top 5 suppliers)
    |                          Run-rate analysis (latest quarter annualized vs full year)
    |                          Two cases:
    |                            - Management Case (their projections, taken at face value)
    |                            - Ascertis Case (25% EBITDA haircut, stress WC, no growth)
    |
    v
[SCREENING VERDICT] -----> 8-dimension scorecard
                           Go / Maybe / Kill recommendation
                           One-pager for Monday pipeline meeting
```

### This Is Iterative, Not Linear

The numbered sequence above is the logical flow, but in practice you bounce back constantly:

- You're building the working file and realize the FY23 revenue doesn't tie between the P&L and the notes. Back to extraction.
- The promoter sends updated provisionals after you've already started the working file. Back to extraction, then redo the ratios.
- The SM reviews your working file and questions a related-party adjustment. Back to extraction to check the original source.
- You're drafting the verdict and the DSCR looks borderline. Back to the working file to test a different debt structure.

On the **Omsairam deal**, extraction went through 6 drafts over 5 weeks (Apr 4 to May 8). Each draft wasn't a minor tweak — it incorporated new data, cross-checks against MCA filings, entity-level breakouts that weren't in the original extraction, and SM feedback.

On the **DP Jain deal**, the more experienced associate maintained a single evolving DD-style file from the start rather than separating extraction from analysis. This is a style difference — the workflow is the same, but the file organization differs based on experience level and deal complexity.

---

## What Each Sub-Skill Does

### 01 — Data Triage

**Input**: Whatever landed — email attachments, data room access, pitch book, WhatsApp forwards.

**Process**:
1. Inventory everything received. List each document with: filename, entity it belongs to, financial year, document type (audited financial, provisional, MCA filing, board resolution, bank statement, customer contract, etc.).
2. Identify the entity structure. How many entities? What's the holdco? What are the operating entities? Is there a group structure diagram?
3. Map what's available vs what's needed. For a basic screen, you need at minimum: 3 years of audited financials for the primary borrowing entity, latest provisional/MIS, and a basic understanding of the business model.
4. Produce the IRL (Information Request List). This is a checklist sent to the promoter or bank listing every document you still need. Be specific: "FY22 audited financial statements for [Entity Name]", not "historical financials."

**Output**: A categorized document inventory and an IRL. The IRL is sent immediately — the clock on data gaps starts now.

**NBFC/Fintech addition**: Also request portfolio data tape, ALM statement, CRAR computation, RBI return filings, cohort-wise disbursement and collection data.

### 02 — Financial Extraction

**Input**: Audited financials (usually scanned PDFs), provisional MIS, MCA filings.

**Process**:
This is the most labor-intensive part of screening. You are converting scanned PDFs into structured Excel data in BPEA's standard format.

The extraction goes through multiple drafts. Based on the Omsairam workflow:

- **Draft 1** (Day 1-3): Raw extraction. Pull P&L, Balance Sheet, and Cash Flow from audited financials for each available year. Numbers go into BPEA template columns. Don't worry about perfect formatting — get the numbers in.
- **Draft 2** (Day 3-5): Cross-check. Compare extracted numbers against notes to accounts, director's report, MCA filings (Form AOC-4). Fix discrepancies. This is where you catch extraction errors.
- **Draft 3** (Day 5-8): Entity-level breakout. If multi-entity group, ensure each entity's standalone financials are separated. Start a consolidated view if needed (elimination of intercompany transactions).
- **Draft 4** (Day 8-12): SM review incorporation. The senior member reviews the extraction, flags questionable items (unusual related-party transactions, one-time items that should be adjusted, classification questions). Associate addresses each comment.
- **Draft 5** (Day 12-20): Additional data incorporation. By now, the IRL responses start arriving. New years' data, restated figures, management explanations for anomalies — all get incorporated.
- **Draft 6** (Day 20-25): Final extraction. Numbers are "clean" — cross-checked, adjusted for one-time items, entity-level views complete. This is what feeds the working file.

**Output**: Entity-level standalone financials (P&L, BS, CF) in BPEA format, plus a consolidated view if applicable. Each line item traceable to a source document.

**NBFC/Fintech addition**: Portfolio-level extraction is a separate workstream — AUM breakdown by product/vintage/geography, disbursement and collection trends, NPA staging, provisioning schedule.

### 03 — Working File Builder

**Input**: Clean extracted financials from Draft 6 (or latest available draft — don't wait for perfection).

**Process**:
Build the analytical layer that turns raw financials into a credit assessment. Key analyses:

1. **Profitability**: Revenue growth, EBITDA margins, PAT margins, trends over 3-5 years. Adjustments for one-time items to get "normalized" EBITDA.
2. **Leverage**: Total Debt / EBITDA, Net Debt / EBITDA, Debt / Tangible Net Worth. Current and pro-forma (after proposed facility).
3. **Debt Service**: DSCR (Debt Service Coverage Ratio) — historical and projected. This is the single most important metric. If DSCR < 1.2x on the Ascertis Case, the deal is almost certainly a Kill.
4. **Working Capital**: Debtor days, creditor days, inventory days, cash conversion cycle. Trend matters — deteriorating WC days signal stress.
5. **Concentration**: Top 5 customer revenue share, top 5 supplier share, single-customer dependency. >25% single customer concentration is a yellow flag.
6. **Run-Rate**: Latest quarter annualized vs last full year. Are things improving or deteriorating right now?
7. **Cash Flow Quality**: Operating cash flow vs EBITDA. Persistent divergence (EBITDA positive, OCF negative) is a red flag — it means profits aren't converting to cash.

**Two Cases**:
- **Management Case**: Take the promoter's projections at face value. Apply their growth assumptions, their margin guidance, their capex plans. This is the optimistic scenario.
- **Ascertis Case**: Haircut EBITDA by ~25% from Management Case. Assume no revenue growth (flat or declining). Stress working capital (add 15-20 days to debtor cycle). Assume capex overruns by 20%. If the deal still works under the Ascertis Case, the credit is robust.

**Output**: A working file with ratio analysis, trend charts, and both cases modeled. This is NOT the full financial model (that's Stage 5) — it's a quick-and-dirty analytical overlay sufficient for a Go/Maybe/Kill decision.

**NBFC/Fintech addition**: Replace standard WC analysis with portfolio analytics — collection efficiency trends, GNPA/NNPA over time, vintage-wise default curves, ALM gap analysis, CRAR headroom.

### 04 — Screening Verdict

**Input**: Completed working file with both cases.

**Process**:
Score the deal across 8 dimensions. Each dimension gets a Pass / Caution / Fail:

| # | Dimension | Pass | Caution | Fail |
|---|-----------|------|---------|------|
| 1 | **DSCR (Ascertis Case)** | > 1.5x | 1.2-1.5x | < 1.2x |
| 2 | **Leverage** | Net Debt/EBITDA < 3.0x | 3.0-4.5x | > 4.5x |
| 3 | **Promoter Quality** | Clean track record, skin in the game | Minor concerns, manageable | Litigation, defaults, governance red flags |
| 4 | **Business Stability** | Recurring revenue, diversified, 10+ yr track record | Some cyclicality, moderate concentration | Project-based, high concentration, short history |
| 5 | **Security Package** | Hard assets > 1.5x cover, liquid, enforceable | Mixed collateral, 1.0-1.5x cover | Weak security, < 1.0x cover, enforcement risk |
| 6 | **Cash Flow Quality** | OCF/EBITDA > 80% consistently | 50-80%, some WC volatility | < 50%, persistent cash burn despite profits |
| 7 | **Industry Outlook** | Structural tailwind, regulatory clarity | Stable but mature, some headwinds | Declining, regulatory overhang, disruption risk |
| 8 | **Sizing vs Capacity** | Proposed facility < 40% of EBITDA (annual service) | 40-60% of EBITDA | > 60% of EBITDA, stretched |

**Verdict Logic**:
- **Go**: No Fails, at most 2 Cautions. Clear investment thesis. Worth committing DD resources.
- **Maybe**: 1 Fail that might be mitigable, or 3+ Cautions. Need more data or a structural fix (higher coupon, stronger security, shorter tenor) to convert to Go.
- **Kill**: 2+ Fails, or 1 Fail on DSCR/Leverage (these are non-negotiable). Don't waste DD budget.

**Output**: One-pager with the 8-dimension scorecard, the verdict, and a 3-4 sentence rationale. This is what the associate presents at the Monday pipeline meeting.

---

## The Monday Pipeline Meeting

This is a 30-60 minute weekly meeting where the investment team reviews all active pipeline opportunities. For Stage 0 deals, the format is:

1. **Associate presents** (2-3 minutes per deal):
   - Company name, sector, what they do in one sentence
   - Proposed facility: INR [X] Cr, [NCD/CCD], [tenor], [indicative coupon]
   - Source: promoter direct or [bank name]
   - Key numbers: Revenue, EBITDA, DSCR (Management Case and Ascertis Case), leverage
   - Scorecard summary: "5 Pass, 2 Caution, 1 Fail on [dimension]"
   - Verdict: Go / Maybe (with what's needed to convert) / Kill (with why)

2. **Senior discussion** (2-5 minutes):
   - KG or senior team asks questions, challenges assumptions
   - Decision: proceed to Concept Paper, request more data, or pass

3. **The one-pager stays on file**. Even Kill decisions are documented — they're useful when the same deal resurfaces through a different bank 6 months later.

When the user says "prep for pipeline meeting" or "Monday meeting", help them prepare this one-pager and anticipate likely questions from seniors.

---

## What Feeds Into Stage 1 (Concept Paper)

If the verdict is **Go**, the following from Stage 0 carries forward into the Concept Paper:

- Company and business description (refined from triage notes)
- Key financial metrics (from the working file — Revenue, EBITDA, DSCR, leverage)
- Proposed transaction structure (facility size, instrument, tenor, indicative coupon)
- Key risks identified during screening (these become the "Risks & Mitigants" section)
- Industry context (preliminary, to be expanded in Stage 3)

What does NOT carry forward:
- The screening model itself (disposable — the full model in Stage 5 is built from scratch)
- Detailed ratio calculations (these get rebuilt with more rigor in DD)
- Any provisional numbers that haven't been verified against audited financials

The Concept Paper takes the screening verdict's "yes, this is interesting" and builds the narrative around WHY it's interesting, WHO the company is, and WHAT the proposed terms should be. The Concept Paper is a persuasion document — the screening verdict is a filter.

---

## Workflow Patterns From Real Deals

### Omsairam Pattern (Less Experienced Associate / Complex Group)
- 6 extraction drafts over 5 weeks
- Separate files for extraction vs working file vs verdict
- Multiple entities requiring standalone + consolidated views
- Heavy back-and-forth on IRL (data arrived in 3-4 tranches)
- SM review triggered significant rework at Draft 4

### DP Jain Pattern (More Experienced Associate / Simpler Structure)
- Single evolving file from day one (extraction + analysis in one workbook)
- Fewer drafts because the associate pre-empted common issues
- Faster cycle — tighter entity structure, cleaner data from promoter
- Still followed the same logical steps, just compressed into fewer file iterations

Both patterns are valid. The sub-skills below support either approach. When the user starts working, ask whether they prefer separate files (Omsairam pattern) or a single evolving workbook (DP Jain pattern), and adapt accordingly.

---

## When to Invoke This Stage

Invoke Stage 0 when the user says any of:
- "New deal came in"
- "Got a teaser / pitch book / IM"
- "Evaluate [company name]"
- "Should we look at this?"
- "Pipeline meeting prep"
- "Screen this"
- "What do we have on [company]?"
- "Promoter sent financials"
- "[Bank name] shared a deal"

Start with **01 — Data Triage** unless the user already has organized financials, in which case skip to **02 — Financial Extraction**.
