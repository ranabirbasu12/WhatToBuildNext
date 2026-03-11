# Stage 4.1: DD Tracker

You are managing the Information Request List (IRL) and coordinating 7+ parallel DD workstreams. The tracker is the associate's project management tool — it ensures nothing falls through the cracks over a 6-10 week DD process.

---

## The Master IRL

The IRL starts as a list of information gaps identified during Stages 0-1 and grows as DD progresses. Every item has an owner, a deadline, and a status.

### IRL Structure

```
| # | Category | Item Description | Source | Owner | Status | Due Date | Received | Notes |
|---|----------|-----------------|--------|-------|--------|----------|----------|-------|
| 1 | Financial | Audited financials FY22-24 (all entities) | Borrower | Associate | ✓ | Week 1 | Week 1 | Received via data room |
| 2 | Financial | Monthly MIS Jan-Dec 2024 | Borrower | Associate | ✓ | Week 2 | Week 3 | 2 months late delivery |
| 3 | Financial | Bank statements (12 months) | Borrower | Deloitte | Pending | Week 3 | — | Requested 2x |
| 4 | Legal | Board resolutions (last 3 years) | Borrower | Trilegal | ✓ | Week 2 | Week 2 | |
| 5 | Legal | Pending litigation summary | Borrower | Trilegal | Pending | Week 3 | — | Borrower claims none |
| 6 | Commercial | Customer contracts (top 5) | Borrower | EY | Partial | Week 4 | Week 4 | 3 of 5 received |
| 7 | Tax | ITR filings (3 years) | Borrower | Deloitte | ✓ | Week 2 | Week 2 | |
| 8 | Portfolio | Data tape (all active loans) | Borrower | Internal | Pending | Week 3 | — | NBFC only |
```

### IRL Categories

| Category | Typical Items | Volume |
|----------|--------------|--------|
| **Financial** | Audited financials, MIS, bank statements, tax returns, GST returns, provisional numbers | 15-25 items |
| **Legal** | Board resolutions, shareholder agreements, material contracts, litigation history, regulatory filings | 10-20 items |
| **Commercial** | Customer contracts, order book, pricing history, supplier agreements, capacity certificates | 8-15 items |
| **Tax** | ITR, GST returns, transfer pricing documentation, tax demands/refunds | 5-10 items |
| **Operational** | Plant licenses, environmental clearances, labor records, insurance policies | 5-10 items |
| **Corporate** | MOA/AOA, share certificates, group structure charts, KYC documents | 5-10 items |
| **Portfolio** (NBFC) | Data tape, collection reports, NPA aging, ALM reports, CRAR filings | 15-25 items |
| **Total** | | **60-120 items** |

---

## Workstream Status Dashboard

Update weekly. Present to deal lead:

```
## DD Status — Week [N]

**Deal:** [Project Code]
**DD Start Date:** [DD/MM/YYYY]
**Target Completion:** [DD/MM/YYYY]

### Workstream Summary

| # | Workstream | Vendor | Start | Target | Status | % Complete | Key Issue |
|---|-----------|--------|-------|--------|--------|-----------|-----------|
| 1 | Financial DD | Deloitte | Week 1 | Week 6 | On Track | 60% | Awaiting bank statements |
| 2 | Legal DD | Trilegal | Week 1 | Week 6 | Delayed | 40% | Litigation search pending |
| 3 | Commercial DD | EY | Week 2 | Week 5 | On Track | 70% | Customer interviews scheduled |
| 4 | Tax DD | Deloitte | Week 2 | Week 5 | On Track | 50% | — |
| 5 | ESG DD | EGP | Week 3 | Week 6 | On Track | 30% | Site visit next week |
| 6 | Background | Internal | Week 1 | Week 4 | Complete | 100% | No adverse findings |
| 7 | Site Visit | Deal team | Week 4 | Week 4 | Scheduled | 0% | [Date] confirmed |

### IRL Status
- Total items: [N]
- Received: [N] ([%])
- Pending: [N] ([%])
- Overdue: [N] ([%]) — [List overdue items]

### Key Findings to Date
1. [Finding 1 — category, severity]
2. [Finding 2 — category, severity]

### Action Items
1. [Action] — Owner: [Name] — Due: [Date]
2. [Action] — Owner: [Name] — Due: [Date]

### Risks to Timeline
- [Risk 1: What could delay DD? What's the mitigation?]
```

---

## Vendor Coordination

### Kickoff Call Agenda

Run within first week of DD:

```
1. Deal overview (5 min — project code, company, sector, deal structure)
2. Scope of work (10 min — what we need from this workstream)
3. Key areas of focus (10 min — risks identified in CP, IC questions)
4. Data access (5 min — data room setup, IRL items for this workstream)
5. Timeline and deliverables (5 min — interim reports, final report date)
6. Communication protocol (5 min — weekly updates, escalation path)
7. Q&A (10 min)
```

### Vendor Management Rules

1. **Weekly status updates** — require written updates from each vendor (email, not just verbal)
2. **Interim findings** — ask vendors to flag material findings immediately, not wait for final report
3. **No surprises** — if a vendor finds a potential deal-breaker, you need to know within 24 hours
4. **Data room management** — maintain organized folder structure. Index every document
5. **Quality control** — review vendor drafts critically. Challenge findings that don't make sense

### Data Room Organization

```
Data Room/
├── 01_Financial/
│   ├── Audited_Financials/
│   ├── MIS/
│   ├── Bank_Statements/
│   ├── Tax_Returns/
│   └── GST_Returns/
├── 02_Legal/
│   ├── Corporate_Documents/
│   ├── Contracts/
│   ├── Litigation/
│   └── Regulatory_Filings/
├── 03_Commercial/
│   ├── Customer_Contracts/
│   ├── Order_Book/
│   └── Pricing_Data/
├── 04_Tax/
├── 05_Operational/
│   ├── Licenses/
│   ├── Environmental/
│   └── Insurance/
├── 06_Portfolio/ (NBFC only)
│   ├── Data_Tape/
│   ├── Collection_Reports/
│   └── Regulatory_Filings/
└── 07_DD_Reports/
    ├── Financial_DD/
    ├── Legal_DD/
    ├── Commercial_DD/
    └── ESG_DD/
```

---

## Escalation Framework

| Trigger | Action | Timeline |
|---------|--------|----------|
| IRL item overdue > 1 week | Escalate to deal lead for borrower follow-up | Same day |
| Vendor behind schedule > 1 week | Call vendor lead, understand blocker, propose solution | Within 2 days |
| Material finding identified | Brief deal lead verbally + written summary | Within 24 hours |
| Potential deal-breaker | Immediate call to deal lead + CIO | Same hour |
| Borrower non-responsive > 2 weeks | Deal lead calls borrower MD/CFO directly | Escalate by end of week |

---

## DD Completion Checklist

Before declaring DD substantially complete:

- [ ] All IRL items received (or formally waived with justification)
- [ ] All vendor reports received in draft or final form
- [ ] No outstanding material findings unresolved
- [ ] DD file updated to latest version with all findings incorporated
- [ ] Key findings summary prepared for deal team
- [ ] DD file version locked for Model (Stage 5) and FDIR (Stage 6) use
- [ ] Any conditions precedent identified for execution (Stage 8)

---

## Output

The DD tracker produces:
1. **Master IRL** (all items tracked with status, dates, notes)
2. **Weekly status dashboard** (workstream progress, findings, risks)
3. **Vendor coordination log** (kickoff notes, interim findings, final reports)
4. **Data room index** (what's been received, where it's stored)
5. **DD completion checklist** (all workstreams assessed)

These support the Financial DD (`02-financial-dd.md`) and Commercial/Legal DD (`03-commercial-legal-dd.md`) sub-skills.
