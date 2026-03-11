# Stage 1.3: Risk Framework

You are building the risk section of the Concept Paper. This section answers: **"What could go wrong, and what will DD resolve?"**

The risk section is the IC's trust calibrator. An associate who hides risks loses credibility. An associate who identifies risks honestly — and connects each to a DD workstream — earns the IC's confidence.

---

## The Right Tone

**Wrong:** "The company has no significant risks and represents an attractive opportunity."
**Right:** "Entry leverage at 6.3x is above our typical comfort zone of 4.0-5.0x. However, the deleveraging trajectory to 2.7x by FY27 is supported by contracted revenue and demonstrated 39% CAGR. DD will stress-test the revenue assumptions underlying this trajectory."

Credit risk analysis is about honest assessment, not salesmanship. The IC has seen hundreds of deals — they can smell whitewash.

---

## Risk Categories

Every Concept Paper should address risks across 5 categories:

### 1. Business Risk
Does the company's operating model support reliable debt repayment?

| Risk Type | What to Check | Example |
|-----------|---------------|---------|
| Customer concentration | Top 5 customers as % of revenue | Asandas: BK India >90% wallet share |
| Revenue visibility | Order book depth, contract tenure | Manufacturing: quarterly vs. annual orders |
| Margin sustainability | One-time vs. structural margin drivers | Asandas: FY24 34% margin (one-time European supply disruption) vs. 18-20% normalized |
| Key person dependency | Promoter/founder involvement | Family business with no professional management layer |
| Technology/product obsolescence | Industry shift risk | Relevant for tech-adjacent businesses |

### 2. Financial Risk
Can the company generate enough cash to service debt?

| Risk Type | What to Check | Example |
|-----------|---------------|---------|
| Leverage at entry | Net Debt / EBITDA post-funding | Asandas: 6.3x (high). Casablanca: 4.3x (moderate) |
| DSCR adequacy | Debt Service Coverage Ratio under base and stress | Management case vs. Ascertis case (25% EBITDA haircut) |
| Working capital volatility | Net WC cycle days and seasonal swings | Asandas: 164-day cycle (single potato harvest) |
| Cash flow quality | Operating CF vs. reported EBITDA | If OCF/EBITDA < 0.7x consistently — investigate |
| Related party transactions | Inter-company flows, management fees | Check notes to accounts from Stage 0 extraction |

### 3. Structural Risk
Is the deal structure clean, or does it introduce complexity?

| Risk Type | What to Check | Example |
|-----------|---------------|---------|
| NBFC classification | HoldCo on-lending structure may trigger RBI classification | Asandas (CCD), MPokket |
| FOCC restriction | Foreign-owned companies face NCD investment limits | Casablanca (FPI routing needed) |
| Multi-entity exposure | Money flows through entities before reaching operations | Group structures with step-downs |
| Security enforceability | Can we actually realize security in a downside? | Share pledge vs. fixed asset charge |
| Regulatory approvals | SEBI, RBI, CCI, FIPB needed before disbursement | Timeline risk for deal completion |

### 4. Industry / Market Risk
Does the external environment support the thesis?

| Risk Type | What to Check | Example |
|-----------|---------------|---------|
| Competitive entry | New capacity coming online, margin pressure | Asandas: Lamb Weston entering India market |
| Regulatory change | RBI/SEBI policy shifts affecting borrower | MPokket: digital lending guidelines |
| Commodity exposure | Raw material price volatility | Asandas: potato + palm oil prices |
| Export dependency | Tariff, trade policy, FX risk | Asandas: 70% revenue from exports, China competition |
| Cyclicality | Industry cycle position | Manufacturing: capex cycle timing |

### 5. ESG Risk
Environmental, social, and governance factors.

| Rating | Description | IFC Standards |
|--------|-------------|---------------|
| **Category A** | Significant adverse impacts (avoid) | PS 1-8 all applicable |
| **Category B** | Moderate impact (most Ascertis deals) | PS 1-4 applicable |
| **Category C** | Minimal impact | PS 1 only |

For Category B (standard), flag:
- Water usage and effluent discharge
- Energy consumption and emissions
- Labor practices (factory workers, contract farmers)
- Community impact
- Data privacy (for fintech/NBFC)

---

## Risk Severity Matrix

Rate each risk on a 2x2 matrix:

```
                    HIGH PROBABILITY
                         |
            MONITOR      |     CRITICAL
         (watch closely) | (must mitigate)
                         |
LOW IMPACT ──────────────┼────────────── HIGH IMPACT
                         |
            ACCEPT       |     INVESTIGATE
         (document only) | (DD must resolve)
                         |
                    LOW PROBABILITY
```

- **CRITICAL**: Flag prominently in CP. IC will ask about these. Must have a mitigation plan
- **INVESTIGATE**: Connect to specific DD workstream. IC will want to know what DD will tell us
- **MONITOR**: Include in CP but as context, not showstopper. Track through deal lifecycle
- **ACCEPT**: Mention briefly. Standard business risks that don't differentiate this deal

---

## Building the Risk Register

For each identified risk (target 5-8 for the Concept Paper):

```
### Risk [N]: [Title]

**Category:** [Business / Financial / Structural / Industry / ESG]
**Severity:** [Critical / Investigate / Monitor / Accept]

**Description:**
[2-3 sentences explaining the risk in specific terms, not generic language]

**Evidence:**
[What data from screening supports this risk assessment? Cite specific sources using `[Source: <filename>, p.<page>, "<quoted text if key>"]` — e.g., `[Source: Working File v3, DSCR sheet, "Ascertis Case DSCR 1.1x FY27"]`]

**Mitigant:**
[What currently exists to offset this risk? Contractual protection, business moat, etc.]

**DD Action:**
[Which DD workstream will investigate? What specific question will DD answer?]

**IC Position:**
[How will you present this in Q&A if challenged?]
```

---

## Real Risk Registers

### Casablanca (6 Risks)
1. **FPI Structure Complexity** (Structural / Investigate) — FOCC restriction requires FPI vehicle routing for Tranche I. DD action: Legal opinion on FPI eligibility and timeline
2. **Acquisition Integration** (Business / Monitor) — BAPIPL integration post-acquisition. Mitigant: Promoter has done this before (Exal acquisitions)
3. **Post-Funding Leverage** (Financial / Monitor) — Entry at 4.3x, above comfort zone of 3.5x. Mitigant: Deleveraging trajectory to <3.5x by FY26 supported by EBITDA growth
4. **Customer Concentration** (Business / Investigate) — Top customers as % of revenue. DD action: Commercial DD to validate customer pipeline
5. **ESG Category B** (ESG / Monitor) — IFC PS 1-4 applicable. DD action: ESG assessment by external vendor
6. **Promoter Jurisdiction** (Structural / Monitor) — Spanish promoter, Dutch holding entity. Cross-border enforcement considerations

### Asandas (8 Risks)
1. **Customer Concentration** (Business / Critical) — BK India >90% wallet share. Single customer loss would be catastrophic
2. **Export Dependency** (Industry / Critical) — 70% revenue from exports. China competition + tariff risk
3. **Margin Sustainability** (Financial / Critical) — FY24 34% vs. normalized 18-20%. European supply disruption one-time
4. **Acquisition Integration** (Business / Investigate) — TFPL + IPPL acquisitions from NCD proceeds. Valuation and synergy validation needed
5. **Entry Leverage** (Financial / Investigate) — 6.3x post-funding. Highest in Ascertis portfolio. Deleveraging depends on revenue growth assumptions
6. **NBFC Classification** (Structural / Investigate) — HoldCo + CCD structure may trigger RBI classification
7. **Margin Decline to 15%** (Financial / Monitor) — Sensitivity: what happens if margins normalize below 18-20%?
8. **ESG Category B** (ESG / Monitor) — Water usage, effluent (addressed by Vihaan CETP), labor practices, farmer welfare

### MPokket (7 Risks)
1. **Regulatory Risk** (Industry / Critical) — RBI could tighten NBFC/digital lending rules
2. **Credit Model Deterioration** (Business / Critical) — If ACD model accuracy declines as company scales to new segments
3. **Segment Concentration** (Business / Investigate) — Salaried segment higher delinquency (7-8% vs. 4-5% students)
4. **Long Tail Recovery** (Financial / Investigate) — 2% of portfolio takes >12 months to recover. Unusual pattern for short-tenor loans
5. **Exit Timing** (Structural / Monitor) — IPO/PE at 2.5 years assumes favorable equity market
6. **NBFC Classification** (Structural / Investigate) — HoldCo structure needs regulatory clearance
7. **Margin Sustainability** (Financial / Monitor) — FY24 34% EBITDA margin may normalize to 18-20%

---

## Connecting Risks to DD Workstreams

Every "Investigate" and "Critical" risk must map to a specific DD workstream:

| DD Workstream | Typical Vendor | What It Resolves |
|---------------|---------------|-----------------|
| **Financial DD** | Deloitte, KPMG, EY | Revenue quality, cash flow, WC, related parties |
| **Legal DD** | Trilegal, TT&A, AZB | Structural risks, regulatory approvals, litigation |
| **Commercial DD** | EY Parthenon, McKinsey | Customer concentration, market position, competitive dynamics |
| **ESG DD** | EGP Partners, SGS | Environmental compliance, social impact, governance |
| **Background DD** | Internal / external | Promoter litigation, criminal records, reputation |
| **Valuation** | GAA Advisory, KPMG | Acquisition valuations, security coverage calculations |
| **Tax DD** | Deloitte, EY | CCD tax treatment, withholding, stamp duty |

The CP's risk section becomes the DD scope document. This is why honest risk identification at CP stage saves months of wasted effort — you're defining what DD needs to answer.

---

## Output

The risk framework produces:
1. **Risk register** (5-8 risks, each with category, severity, evidence, mitigant, DD action)
2. **Severity matrix visualization** (which risks are Critical vs. Monitor)
3. **DD scope mapping** (each risk → DD workstream → vendor → specific question)
4. **IC Q&A prep** (anticipated challenges and prepared responses for top 3-4 risks)
5. **ESG classification** with applicable IFC Performance Standards

These feed into Document Assembly (`04-document-assembly.md`) as the Risks, ESG, and Next Steps sections of the Concept Paper.
