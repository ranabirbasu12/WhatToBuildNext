# Decision Log — Deal Desk

> Every significant decision, with context and rationale.
> When future-you asks "why did we do it this way?" -- the answer is here.

---

## DEC-001: Markdown Skills Over Code

**Date:** 2026-03-11
**Status:** Accepted

**Context:** Need to decide how to implement Deal Desk. Options range from a full software product to simple prompt files.

**Options:**
1. Python toolkit with APIs and a web UI
2. Claude Code custom tool integrations
3. Markdown skill files that Claude Code reads natively

**Decision:** Option 3 — markdown skill files.

**Rationale:** GSD, Metaswarm, and Superpowers all proved that markdown prompts are enough to encode complex multi-step workflows. Claude Code reads them natively. No deployment, no maintenance, no dependencies. The user is not a coder — markdown is something he can read and edit.

**Consequences:**
- Good: Zero infra, zero maintenance, instant iteration. Edit a markdown file and the skill changes.
- Good: Portable — works anywhere Claude Code runs.
- Bad: No persistent state between sessions (mitigated by outputting artifacts to files).
- Bad: Constrained by Claude's context window for very large documents.

---

## DEC-002: 8-Skill Architecture

**Date:** 2026-03-11
**Status:** Accepted

**Context:** Need to decide how to decompose the deal workflow into skills.

**Options:**
1. One monolithic "deal analyst" skill that does everything
2. 3-4 broad skills (analyze, draft, review)
3. 8 skills mapping 1:1 to real deal stages

**Decision:** Option 3 — 8 skills, each mapping to a real stage in the Ascertis deal workflow.

**Rationale:** Researched 6 actual deals (Casablanca, mPokket, Asandas, Waaree, Omsairam, DP Jain). The deal lifecycle has clear, distinct stages. Each stage produces specific deliverables. A 1:1 mapping means each skill knows exactly what it's supposed to output and can be tested against real artifacts.

**Consequences:**
- Good: Each skill is focused and testable against real deal artifacts.
- Good: Can build incrementally — start with Screening Analyst, add others over time.
- Bad: 8 skills to maintain (but they're markdown, so maintenance is trivial).

---

## DEC-003: Screening Analyst Gets 5 Sub-Skills

**Date:** 2026-03-11
**Status:** Accepted

**Context:** Screening is the longest stage (4-5 weeks, 5-6 drafts). Need to decide whether to keep it as one skill or decompose further.

**Options:**
1. Single Screening Analyst skill with all logic inline
2. 5 sub-skills: PDF Extractor, Ratio Engine, Red Flag Scanner, Screening Memo Drafter, Sector Primer

**Decision:** Option 2 — 5 sub-skills.

**Rationale:** 80% of the associate's grunt work lives in screening. The stages within screening are distinct: extracting numbers from PDFs is a different task from computing ratios, which is different from writing the memo narrative. Decomposing lets you run sub-skills independently (e.g., just extract financials without writing a full memo) and test each one in isolation.

**Consequences:**
- Good: Can validate PDF extraction quality separately from memo writing quality.
- Good: Sub-skills are reusable — Ratio Engine feeds both Screening Analyst and Financial Model Builder.
- Bad: More files to manage (but each is small and focused).

---

## DEC-004: No Monitoring Analyst

**Date:** 2026-03-11
**Status:** Accepted

**Context:** Initial brainstorm included a monitoring/post-disbursement skill. Need to decide whether to include it.

**Options:**
1. Include monitoring as the 9th skill
2. Drop monitoring entirely

**Decision:** Option 2 — no monitoring analyst.

**Rationale:** The user is on the investments team. Monitoring and post-disbursement tracking is the transaction team's job. Building a skill for someone else's workflow is wasted effort. The skill tree ends at IC approval — that's where the investments team's responsibility ends.

**Consequences:**
- Good: Focused scope. Build for the actual user, not a hypothetical one.
- Good: Fewer skills to design and maintain.
- Bad: If the user's role expands to include monitoring, this decision gets revisited.

---

## DEC-005: Indian Private Credit Focus

**Date:** 2026-03-11
**Status:** Accepted

**Context:** Could build generic credit analysis skills or specialize for the user's actual domain.

**Options:**
1. Generic credit analysis (US GAAP, global markets)
2. Indian private credit specifically (Ind-AS/Indian GAAP, INR, RBI/SEBI/MCA)

**Decision:** Option 2 — Indian private credit focus.

**Rationale:** The user works at an Indian private credit fund. The financials are in Ind-AS or Indian GAAP. Amounts are in lakhs and crores. Regulatory references are RBI, SEBI, MCA. A generic skill would need constant correction. A specialized skill gets it right from the start.

**Consequences:**
- Good: Output matches fund house conventions immediately — no manual reformatting.
- Good: Terminology, regulatory context, and accounting standards are baked in.
- Bad: Skills are not directly reusable for US/European credit funds (but the architecture is).

---

## DEC-006: Based on Real Deal Artifacts

**Date:** 2026-03-11
**Status:** Accepted

**Context:** Could design skills from first principles or model them on actual deliverables.

**Options:**
1. Design skills from textbook credit analysis frameworks
2. Model skills on actual deliverables from completed Ascertis deals

**Decision:** Option 2 — based on real deal artifacts.

**Rationale:** Researched 6 deals: Casablanca, mPokket, Asandas (completed), Waaree (live), Omsairam and DP Jain (pipeline). Every skill is modeled on what was actually produced for these deals — the screening memo format, the term sheet structure, the IC memo sections. Theory produces generic output. Real artifacts produce fund-ready output.

**Consequences:**
- Good: Skills produce output that matches what the fund actually expects.
- Good: Can validate skill output by comparing against real completed deal artifacts.
- Bad: Tightly coupled to Ascertis house style (but that's the user's fund, so this is a feature).
