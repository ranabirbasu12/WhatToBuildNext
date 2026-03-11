# Stage 4 Orchestrator: Due Diligence

You are helping an associate manage the DD File — the master Excel workbook that grows over 6-10 weeks as 7+ parallel workstreams feed findings into it. The goal: **"Is this deal safe? Are the numbers real? Are the risks manageable?"**

The deliverable is a **DD File** (20-70 sheets, 30+ versions) that becomes the analytical backbone of the deal. Every finding here feeds into the Financial Model (Stage 5) and FDIR (Stage 6).

**The DD File is the deal's heartbeat.** It starts lean (v001, ~1.5 MB) and grows continuously. Casablanca had 30+ versions over months. DP Jain had a 67-sheet DD file for an NBFC deal. The associate maintains version control, coordinates external vendors, and ensures nothing falls through the cracks.

---

## Sub-Skills

| Sub-Skill | File | Purpose |
|-----------|------|---------|
| DD Tracker | `01-dd-tracker.md` | Master IRL (Information Request List), workstream status, vendor coordination |
| Financial DD | `02-financial-dd.md` | P&L deep dive, balance sheet quality, cash flow analysis, adjustments |
| Commercial & Legal DD | `03-commercial-legal-dd.md` | Revenue quality, customer analysis, litigation, regulatory compliance |

---

## The 7+ DD Workstreams

| # | Workstream | Vendor / Owner | Key Output |
|---|-----------|---------------|-----------|
| 1 | **Financial DD** | Deloitte / EY / KPMG | Restated financials, quality of earnings, WC analysis |
| 2 | **Commercial DD** | EY Parthenon / McKinsey | Market validation, customer due diligence, pipeline analysis |
| 3 | **Legal DD** | Trilegal / TT&A / AZB | Corporate structure, litigation, regulatory, title reports |
| 4 | **Tax DD** | Deloitte / EY | Tax positions, contingent liabilities, transfer pricing |
| 5 | **ESG DD** | EGP Partners / SGS | Environmental compliance, social impact, governance |
| 6 | **Background DD** | Internal / external | Promoter checks, management background, reputation |
| 7 | **Technical / Operational DD** | Sector specialist | Site visits, capacity assessment, technology review |
| 8 | **Portfolio DD** (NBFC only) | Internal + external | Cohort analysis, NPA aging, collection efficiency, ALM |

---

## The DD File Structure

The DD file is an Excel workbook. Its sheets evolve over time, but a mature DD file typically contains:

### Standard Manufacturing Deal (20-35 sheets)

```
Tab Groups:
├── Summary
│   ├── DD Summary Dashboard
│   ├── IRL Tracker
│   └── Key Findings
│
├── Financial
│   ├── P&L (audited, 3-5 years)
│   ├── Balance Sheet
│   ├── Cash Flow
│   ├── Adjustments & Restatements
│   ├── Working Capital Analysis
│   ├── Related Party Transactions
│   ├── Capex Analysis
│   └── Off-Balance Sheet Items
│
├── Commercial
│   ├── Revenue Breakdown (by customer, product, geography)
│   ├── Customer Concentration
│   ├── Order Book / Pipeline
│   ├── Pricing Analysis
│   └── Capacity Utilization
│
├── Legal & Compliance
│   ├── Corporate Structure
│   ├── Litigation Summary
│   ├── Regulatory Compliance
│   ├── Material Contracts
│   └── Title Report Summary
│
├── Tax
│   ├── Tax Positions
│   ├── Contingent Liabilities
│   └── Transfer Pricing (if applicable)
│
├── Other
│   ├── Insurance Summary
│   ├── ESG Assessment
│   ├── Background Check Summary
│   └── Site Visit Notes
```

### NBFC / Fintech Deal (40-70 sheets)

All of the above PLUS:

```
├── Portfolio
│   ├── AUM Composition (by product, segment, geography)
│   ├── Disbursement Trends
│   ├── Collection Efficiency (monthly)
│   ├── DPD Aging (0, 1-30, 31-60, 61-90, 90+)
│   ├── NPA Analysis (GNPA, NNPA, provisioning)
│   ├── Static Pool Analysis (vintage-wise)
│   ├── Roll Rate Analysis
│   ├── Cohort Analysis
│   ├── Top Borrower Concentration
│   ├── Sector Concentration
│   ├── Geographic Concentration
│   ├── Ticket Size Distribution
│   ├── Tenure Distribution
│   ├── Interest Rate Analysis
│   ├── ALM Maturity Buckets
│   ├── CRAR Computation
│   ├── Provision Coverage Ratio
│   └── RBI Compliance Checklist
```

---

## Version Control

The associate is the custodian of the DD file. Version control is manual but critical:

```
[Project]_DD File_v001.xlsx    (initial structure, headers only)
[Project]_DD File_v002.xlsx    (financial data populated)
[Project]_DD File_v003.xlsx    (first vendor report incorporated)
...
[Project]_DD File_v015.xlsx    (mid-DD checkpoint)
...
[Project]_DD File_v030.xlsx    (substantially complete)
[Project]_DD File_CP.xlsx      (version at Concept Paper stage — if DD started early)
[Project]_DD File_FINAL.xlsx   (locked for FDIR use)
```

**Version frequency:** 2-4 versions per week during active DD. More during screen-share sessions with vendors or deal lead.

**File size trajectory:** Starts at ~1-2 MB (structure only). Grows to 3-5 MB (manufacturing) or 8-15 MB (NBFC with portfolio data). A 67-sheet NBFC DD file is not unusual.

---

## The Actual Workflow

```
HoT Signed (Stage 2)
    |
    v
[DD TRACKER] -----> Create master IRL from CP risk register
    |                Engage external vendors (Deloitte, Trilegal, etc.)
    |                Set up DD file structure (empty tabs)
    |                Schedule vendor kickoff calls
    |
    v
[7+ WORKSTREAMS IN PARALLEL]
    |
    |   Financial DD vendor starts ──→ monthly data requests → findings
    |   Legal DD vendor starts ──→ searches, filings review → findings
    |   Commercial DD vendor starts ──→ interviews, market data → findings
    |   Tax DD vendor starts ──→ filings review → findings
    |   ESG vendor starts ──→ site visit, assessment → findings
    |   Background checks ──→ database searches → findings
    |   Site visit scheduled ──→ operational assessment → findings
    |   [Portfolio DD if NBFC] ──→ data tape analysis → findings
    |
    v
[ONGOING: Associate integrates findings into DD file]
    |
    |   Weekly: Update DD tracker (what's done, what's pending)
    |   Bi-weekly: Status call with all vendors
    |   As needed: Screen-share with deal lead (DD file deep dive)
    |   As needed: Follow-up data requests to borrower
    |
    v
DD substantially complete
    |
    v
[FINANCIAL DD] -----> Deep dive on quality of earnings
    |                  Restatements and adjustments
    |                  Working capital normalization
    |                  Cash flow bridge (EBITDA → OCF → FCF)
    |
    v
DD File locked → Stage 5 (Model) and Stage 6 (FDIR)
```

---

## Key DD Findings Categories

Every finding should be classified:

| Category | Implication | Action |
|----------|------------|--------|
| **Deal Breaker** | Fundamental issue that makes the deal uninvestable | Escalate immediately to CIO. May kill the deal |
| **Material Finding** | Significant issue but potentially manageable | Requires structural mitigation (covenant, security, pricing adjustment) |
| **Moderate Finding** | Noteworthy issue for monitoring | Include in FDIR risk section. Add to monitoring plan |
| **Informational** | Context for understanding the business | Document in DD file. No action required |

**Examples of Deal Breakers:**
- Fraud or financial misrepresentation
- Undisclosed material litigation
- Regulatory non-compliance that threatens the business license
- Actual debt-to-EBITDA significantly higher than represented
- Security assets don't exist or have prior encumbrances

**Examples of Material Findings:**
- Revenue quality issues (one-time items inflating EBITDA)
- Related party transactions that distort margins
- Working capital cycle significantly longer than presented
- Environmental non-compliance requiring remediation capex
- Promoter has undisclosed personal guarantees elsewhere

---

## Connection to Other Stages

| Stage | Relationship |
|-------|-------------|
| Stage 1 (Concept Paper) | CP's preliminary DD checklist becomes the starting IRL |
| Stage 2 (HoT) | HoT terms become DD assumptions. DD findings may trigger HoT amendments |
| Stage 3 (Industry) | Industry note provides context for commercial DD findings |
| Stage 5 (Model) | DD-validated financials become model inputs. Restatements affect base case |
| Stage 6 (FDIR) | DD findings summarized in dedicated FDIR section |
| Stage 8 (Execution) | DD CPs (conditions precedent) must be satisfied before disbursement |
