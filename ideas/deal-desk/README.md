# Deal Desk

> AI skill swarm that turns Claude Code into a virtual deal team for private credit fund associates.

## Status: BUILT — awaiting battle-test

## The Problem

Private credit associates spend 80% of their time on grunt work. Extracting financials from messy PDFs. Building models in Excel. Writing screening memos. Drafting term sheets. A single screening takes 4-5 weeks and 5-6 drafts before it reaches the IC.

The workflow is highly templated — same skeleton across every deal, different meat per sector. But associates still do it manually, every time, from scratch.

## The Idea

A swarm of markdown skill files that automate each stage of the private credit deal lifecycle. Each skill teaches Claude Code how to do one job on the deal team — from initial screening to final IC memo. No code, no APIs, no infra. Just markdown prompts that encode domain expertise.

The fund context: INR 100-800 Cr NCD facilities to mid-market Indian companies. Ind-AS/Indian GAAP financials, lakhs and crores, RBI/SEBI/MCA terminology.

### The Skill Tree

| # | Skill | What It Does |
|---|-------|-------------|
| 1 | **Screening Analyst** | Extracts financials from messy PDFs, builds 3-statement model, validates and scores the lead |
| 2 | **Industry Analyst** | Credit-oriented industry notes — answers whether the sector supports reliable debt repayment |
| 3 | **Concept Paper Writer** | 14-16 slide IC deck for go/no-go decision on committing DD spend |
| 4 | **HoT Analyst** | Drafts, redlines, and tracks Head of Terms through 5-13 negotiation rounds |
| 5 | **DD Coordinator** | Manages 7 parallel DD workstreams, generates IRL, coordinates external vendors |
| 6 | **Model Builder** | 30-50 sheet credit model — debt serviceability, covenants, stress scenarios |
| 7 | **FDIR Writer** | 40-60 page IC memo synthesizing all deal work for final investment decision |
| 8 | **Call Note Taker** | Structured notes from management calls, expert calls, site visits |

#### Screening Analyst Sub-Skills (where 80% of grunt work lives)

| Sub-Skill | What It Does |
|-----------|-------------|
| Document Ingestion | Parses scanned/messy Indian PDF annual reports, OCR, table extraction, notes-to-accounts |
| Financial Statement Builder | Maps extracted data to BPEA template, builds formula-linked 3-statement model |
| Ratio Engine | Computes 25+ credit ratios (DSCR, ISCR, leverage, liquidity) with peer benchmarking |
| Red Flag Scanner | 12-category severity matrix — audit qualifications, related-party, cash flow mismatches |
| Lead Scorer | 22-dimension scorecard with Go/Maybe/Kill framework for senior handoff |

## What's NOT Included

Monitoring and post-disbursement tracking. That's the transaction team's job, not the investments team's. The skill tree ends at IC approval.

## Tech Stack

| Layer | Choice | Why |
|-------|--------|-----|
| Skills | Markdown prompt files | No code needed — Claude Code reads them natively |
| Orchestration | Claude Code (native) | Already handles multi-file workflows |
| Data | PDFs, Excel, fund templates | The artifacts associates actually work with |
| Infra | None | Zero deployment, zero maintenance |

## Prior Art

| Existing Solution | What It Does | How This Differs |
|-------------------|-------------|-----------------|
| GSD | Project planning via markdown skills | Generic — knows nothing about private credit |
| Metaswarm | Quality-gated multi-agent execution | Process framework — no domain knowledge |
| Nexus | Multi-agent orchestration (Claude + Codex) | Killed as standalone — too much ceremony for too little value |

None of these know what a screening memo looks like, how to read an Indian annual report, or what covenants matter for an NCD facility. Deal Desk is domain-specific.

## Based On

Real deal artifacts from Ascertis Credit:
- **Completed deals:** Casablanca, mPokket, Asandas
- **Live deal:** Waaree
- **Pipeline deals:** Omsairam, DP Jain
- **Fund docs:** FDIR, fund covenants, IC memo templates

Skills are modeled on actual deliverables, not theoretical templates.

## Key Decisions

| Decision | Choice | Rationale | Date |
|----------|--------|-----------|------|
| DEC-001 | Markdown skills over code | GSD/Metaswarm proved markdown prompts are enough | 2026-03-11 |
| DEC-002 | 8-skill architecture | Maps 1:1 to real deal stages from Ascertis workflow | 2026-03-11 |
| DEC-003 | 5 sub-skills for Screening Analyst | That's where 80% of grunt work lives | 2026-03-11 |
| DEC-004 | No monitoring analyst | User is investments team, not transaction team | 2026-03-11 |
| DEC-005 | Indian private credit focus | User's actual domain — Ind-AS, lakhs/crores, RBI/SEBI | 2026-03-11 |
| DEC-006 | Based on real deal artifacts | Modeled on actual Ascertis deliverables, not theory | 2026-03-11 |

## Timeline

| Phase | Description | Status |
|-------|-------------|--------|
| Spar | Brainstorm, validate the idea | Done |
| Design | Skill tree, sub-skill architecture | Done |
| Build | Write all 13 skill files (8 skills, 5 sub-skills) | Done |
| Battle-test | Run on a real deal file from Ascertis Credit | Not started |
| Iterate | Refine skills based on real-world output quality | Not started |
