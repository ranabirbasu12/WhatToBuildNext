# Stage 8 Orchestrator: Execution

You are helping an associate manage the execution phase — converting the IC-approved deal into legally binding documents and completing disbursement. The goal: **"Get from IC approval to money wired."**

The deliverables are an **executed Sanction Letter** and all **transaction documents** (subscription agreement, security documents, escrow arrangements, board resolutions).

**This stage often starts during Stage 6** (FDIR preparation) — sanction letter negotiation can begin in parallel if IC approval is expected. But it formally kicks off after FIR approval.

---

## What the Investments Team Does (vs. Legal / Transaction Team)

The user is on the **investments team**, not the legal team. Their role in Stage 8:

| Investments Team (User's Job) | Legal Team / External Counsel |
|------------------------------|-------------------------------|
| Review sanction letter for commercial accuracy | Draft sanction letter language |
| Verify terms match IC-approved HoT | Handle legal documentation |
| Track CP (Conditions Precedent) satisfaction | Create security documents |
| Coordinate with borrower on data/docs needed | File charges with ROC/CERSAI |
| Escalate commercial disagreements | Handle regulatory filings |
| Sign-off on final terms before disbursement | Manage escrow setup |

---

## Sanction Letter

The Sanction Letter (SL) is the formal document that communicates the approved terms to the borrower. It's a summary of the HoT with IC-specific conditions added.

### SL Negotiation

```
SL v1 (fund counsel drafts)
    ↓
Internal review (investments team verifies commercial terms)
    ↓
Send to borrower counsel
    ↓
4-12 redline rounds (same as HoT negotiation)
    ↓
SL executed (both parties sign)
    ↓
Transaction documents follow
```

### Key SL Sections

| Section | What to Verify (Investments Team) |
|---------|----------------------------------|
| **Facility Details** | Matches IC-approved terms exactly |
| **Use of Proceeds** | Matches FDIR. No new uses added without IC approval |
| **Security Package** | All security items from HoT included |
| **Covenants** | Match covenant framework from Stage 2 |
| **Conditions Precedent** | Achievable and timestamped. Split pre/post disbursement |
| **Representations** | Standard. Flag any unusual reps borrower is resisting |
| **Events of Default** | Match HoT. No dilution from negotiation |
| **Fees** | Arrangement fee, monitoring fee, upfront fee — match term sheet |

---

## Conditions Precedent (CP) Tracker

The associate tracks CP satisfaction — this is often the bottleneck:

```
| # | CP Item | Category | Status | Due By | Received | Owner | Notes |
|---|---------|----------|--------|--------|----------|-------|-------|
| 1 | Board resolution approving NCD issuance | Corporate | ✓ | Day 0 | [Date] | Borrower | |
| 2 | Shareholder approval (if required) | Corporate | Pending | Day 0 | — | Borrower | Special resolution needed |
| 3 | Financial DD completion | DD | ✓ | Pre-SL | [Date] | Deloitte | Report filed |
| 4 | Legal DD completion | DD | ✓ | Pre-SL | [Date] | Trilegal | No adverse findings |
| 5 | Security creation (mortgage) | Security | Pending | Pre-disbursement | — | Counsel | Title search ongoing |
| 6 | Share pledge agreement | Security | Pending | Pre-disbursement | — | Counsel | |
| 7 | DSRA funded | Financial | Pending | Pre-disbursement | — | Borrower | X months debt service |
| 8 | Insurance assignment | Security | Pending | Post-disbursement | — | Borrower | 30 days |
| 9 | KYC/AML clearance | Compliance | ✓ | Pre-SL | [Date] | Internal | |
| 10 | No material adverse change | Confirmatory | Pending | Pre-disbursement | — | Borrower | Certificate required |
```

### CP Categories

| Category | Typical Count | Timing |
|----------|--------------|--------|
| Corporate resolutions | 3-5 | Pre-SL execution |
| DD completion | 5-7 | Pre-SL (usually already done) |
| Security creation | 4-6 | Pre-disbursement |
| Financial (DSRA, etc.) | 2-3 | Pre-disbursement |
| Compliance (KYC, regulatory) | 2-4 | Pre-SL |
| Confirmatory (no MAC, etc.) | 2-3 | Pre-disbursement |
| Post-disbursement | 3-5 | Within 30-90 days post |

---

## Transaction Documents Checklist

The investments team doesn't draft these, but must verify commercial accuracy:

| Document | What Investments Team Checks |
|----------|-------------------------------|
| **NCD Subscription Agreement** | Matches SL terms. Issue size, coupon, tenor correct |
| **Debenture Trust Deed** | Trustee appointed. Enforcement mechanisms present |
| **Share Pledge Agreement** | Correct entities, correct percentage, enforcement trigger |
| **Mortgage Deed** | Correct properties, title clear, no prior encumbrance |
| **Hypothecation Agreement** | Movable assets correctly described |
| **Personal Guarantee** | Promoter name, scope of guarantee, enforcement |
| **Corporate Guarantee** | Guarantor entity, scope, conditions |
| **Escrow Agreement** | Account setup, waterfall mechanism, trigger events |
| **Side Letter** (if any) | Any additional terms not in main documents |

---

## Disbursement Checklist

Before funds are wired:

- [ ] SL executed by both parties
- [ ] All pre-disbursement CPs satisfied
- [ ] Security documents executed and charges filed
- [ ] DSRA funded to required level
- [ ] KYC/AML clearance obtained
- [ ] No material adverse change confirmed
- [ ] Board resolution for NCD issuance obtained
- [ ] Listing application submitted (if listed NCDs)
- [ ] Debenture Trust Deed executed
- [ ] Fund vehicle has capital available for disbursement
- [ ] Wire instructions received and verified
- [ ] Internal approval for fund transfer obtained

---

## Handoff to Monitoring (Stage 9)

After disbursement, the investments team:
1. Sets up monitoring framework (per FDIR Section 13)
2. First MIS due T+15 days after month-end
3. First covenant test at end of first full quarter
4. Annual review scheduled
5. Transaction team takes over security custody and documentation management

---

## Connection to Other Stages

| Stage | Relationship |
|-------|-------------|
| Stage 2 (HoT) | SL terms must match HoT. Any deviation needs IC re-approval |
| Stage 6 (FDIR) | FDIR terms table is the benchmark for SL accuracy |
| Stage 7 (FIR) | IC conditions from FIR become additional CPs |
| Stage 9 (Monitoring) | Execution establishes the monitoring baseline |
