# Stage 7 Orchestrator: FIR & IC Query Resolution

You are helping an associate respond to Investment Committee queries raised after the FDIR presentation. The goal: **"Resolve every IC condition so the deal gets final approval."**

The deliverable is a **FIR (Final Investment Recommendation)** — a concise document that addresses all IC queries with evidence, presents the final recommendation, and obtains sign-off.

**This is typically the shortest stage** (~1 week). The analytical heavy lifting is done. Stage 7 is about clarity, precision, and closing the loop.

---

## What the FIR Contains

The FIR is NOT another FDIR. It's a focused response document:

```
FIR — FINAL INVESTMENT RECOMMENDATION

Project: [Code] | Date: [DD/MM/YYYY]

═══ IC QUERIES AND RESPONSES ═══

Query 1: [Exact question from IC]
Response: [Evidence-based answer, 1-2 paragraphs]
Source: [What data/analysis supports this answer]
Status: RESOLVED / PARTIALLY RESOLVED / OUTSTANDING

Query 2: [Exact question]
Response: [Answer]
Source: [Supporting evidence]
Status: RESOLVED

[... for each query]

═══ UPDATED RECOMMENDATION ═══
[Restate recommendation with any modifications based on IC feedback]

═══ CONDITIONS SATISFIED ═══
| # | Condition | Status | Evidence |
|---|-----------|--------|----------|
| 1 | [IC condition] | Satisfied / Pending | [Reference] |

═══ FINAL TERMS (if modified) ═══
[Any changes from FDIR terms table]
```

---

## IC Query Types and How to Handle Them

### Type 1: Factual Queries
**Example:** "What's the exact DSCR in Q3 FY27 under Downside Case?"
**Response:** Pull from model. State the number. No narrative needed.

### Type 2: Analytical Queries
**Example:** "What happens to leverage if the acquisition is delayed by 6 months?"
**Response:** Run the scenario in the model. Present results with comparison to base case. May require a new sensitivity table.

### Type 3: Judgment Queries
**Example:** "Are you comfortable with the margin sustainability?"
**Response:** State your assessment with evidence. Reference DD findings, industry benchmarks, and expert call insights. Be honest about residual uncertainty.

### Type 4: Structural Queries
**Example:** "Can we get a better security position on the HoldCo?"
**Response:** Discuss with legal counsel. Present options with pros/cons. This may require going back to the borrower — which takes time.

### Type 5: Process Queries
**Example:** "Has the background check on the promoter's family been completed?"
**Response:** Status update. If complete, summarize findings. If pending, give timeline and interim assessment.

---

## FIR Versions

### Domestic IC vs. Offshore IC

Some deals require approval from both a domestic IC and an offshore IC (for funds with offshore investors):

```
[Project]_FIR_[DDMMYY].docx        (Domestic IC)
[Project]_FIR_[DDMMYY]_offshore.docx  (Offshore IC — may include additional context
                                        on India-specific regulatory elements)
```

**Casablanca example:**
- `Project Aerosol_FIR_221024.docx` — Domestic IC (Oct 22, 2024)
- `Project Aerosol_FIR_231024.docx` — Offshore IC (Oct 23, 2024 — next day)

### Format

- **Word/PDF** (not PowerPoint) — this is a document, not a presentation
- Concise: 5-15 pages depending on number of queries
- Each query clearly numbered and cross-referenced to IC meeting minutes
- Evidence cited with specific page/section references to FDIR, DD reports, or model

---

## Timeline

```
Day 1: IC meeting → queries raised (captured in meeting minutes)
Day 2: Associate categorizes queries, identifies what needs additional work
Day 3-4: Run model scenarios, obtain legal opinions, verify DD findings
Day 5: Draft FIR responses
Day 6: SM/Deal Lead reviews
Day 7: CIO reviews → circulate to IC
→ IC signs off (written or in follow-up meeting)
```

---

## Outcome

| IC Decision | Next Step |
|------------|-----------|
| **Final Approval** | Stage 8 (Execution). Sanction letter issued |
| **Conditional Approval** | Resolve remaining conditions. May need another FIR round |
| **Request Re-Presentation** | Update FDIR with IC feedback. Re-present (rare) |
| **Reject** | Deal dies. Kill postmortem + learnings |

---

## Connection to Other Stages

| Stage | Relationship |
|-------|-------------|
| Stage 5 (Model) | IC queries often require model re-runs with different assumptions |
| Stage 6 (FDIR) | FIR references FDIR sections. May trigger FDIR amendments |
| Stage 8 (Execution) | FIR approval triggers sanction letter. Final terms locked |
