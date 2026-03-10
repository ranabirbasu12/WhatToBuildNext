# Brainstorm — Deal Desk

> Raw thinking, unfiltered ideas, questions, and exploration.

## Session 1 — 2026-03-11

**Participants:** Ranabir, Claude

### What came up

- Ranabir is joining a private credit firm (Ascertis Credit) as an associate
- Wants AI to handle the grunt work so he can focus on judgment calls
- The associate role is 80% templated work: extract financials, build models, write memos
- A single screening takes 4-5 weeks and 5-6 drafts — absurd for something this repeatable

### Research done

- 5 parallel agents explored the entire Ascertis Credit folder
- Covered 3 completed deals (Casablanca, mPokket, Asandas), 1 live deal (Waaree), 2 pipeline deals (Omsairam, DP Jain)
- Also reviewed FDIR docs, fund covenants, IC memo templates
- Mapped out the full deal lifecycle from initial screening to IC approval

### Key insights

1. **The entire deal workflow is highly templated and repeatable.** Same skeleton across all deals, different meat per sector. Screening memos follow the same structure. Term sheets have the same clauses. IC memos hit the same sections. This is exactly the kind of work AI can eat.

2. **Screening Analyst is the deepest pain point.** 4-5 weeks, 5-6 drafts, mostly spent fighting with messy Indian PDF annual reports to extract financials. This is where the most time is wasted and where automation hits hardest.

3. **Monitoring is NOT the investments team's job.** The transaction team handles post-disbursement monitoring. The investments team's job ends at IC approval. Kill the monitoring skill — it's not the user's problem to solve.

4. **Skills are just markdown.** GSD, Metaswarm, and the Superpowers collection all proved that markdown prompt files are enough to encode complex workflows. No code needed. Claude Code reads them natively.

### The skill tree that was designed

8 main skills mapping 1:1 to real deal stages:

1. Screening Analyst (with 5 sub-skills — the deepest one)
2. Term Sheet Drafter
3. Due Diligence Coordinator
4. Financial Model Builder
5. Legal Review Analyst
6. IC Memo Writer
7. Comparables Analyst
8. Deal Tracker

Screening Analyst sub-skills: PDF Extractor, Ratio Engine, Red Flag Scanner, Screening Memo Drafter, Sector Primer.

### Questions raised

- How well can Claude handle messy Indian PDF annual reports? (the PDF extraction quality is the make-or-break)
- Should the financial model be built in-context or output to Excel?
- How much fund-specific convention (Ascertis house style) should be baked into the skills vs. kept as configurable templates?
- Can Claude reliably compute DSCR/ICR/leverage from extracted Indian GAAP financials, or will it hallucinate numbers?

### Ideas killed

- **Monitoring Analyst** — not the investments team's job. Transaction team handles that. Don't build skills for someone else's workflow.
- **Complex code-based tools** — markdown is enough. GSD and Metaswarm proved this. Adding Python/APIs would create maintenance burden for zero gain.
- **Generic "financial analyst" skill** — too broad. The power is in specificity: Indian private credit, NCD facilities, INR 100-800 Cr, mid-market. Generic skills produce generic output.

---

## Parking Lot

Ideas that don't fit anywhere yet but shouldn't be lost:

- Could the Comparables Analyst pull from MCA filings directly? (Ministry of Corporate Affairs has public financials)
- Sector Primer could eventually become its own knowledge base — sector-specific credit risk patterns
- Deal Tracker could integrate with a simple SQLite database (like Nexus) for pipeline management
- The PDF Extractor sub-skill might need to handle multiple formats: standalone financials, annual reports, CA-certified extracts, bank statements
