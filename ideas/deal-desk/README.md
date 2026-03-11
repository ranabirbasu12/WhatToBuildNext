# Deal Desk

> AI skill swarm that turns Claude Code into a virtual deal team for private credit fund associates.

## Status: BUILT — awaiting battle-test

## The Problem

Private credit associates spend 80% of their time on grunt work. Extracting financials from messy PDFs. Building models in Excel. Writing screening memos. Drafting term sheets. Negotiating redlines. Assembling 40-page IC memos from 7 parallel DD workstreams.

The workflow is highly templated — same skeleton across every deal, different meat per sector. But associates still do it manually, every time, from scratch.

## The Idea

A swarm of markdown skill files that automate each stage of the private credit deal lifecycle. Each skill teaches Claude Code how to do one job on the deal team — from initial screening to ongoing portfolio monitoring. No code, no APIs, no infra. Just markdown prompts that encode domain expertise.

The fund context: INR 100-800 Cr NCD/CCD facilities to mid-market Indian companies. Ind-AS/Indian GAAP financials, lakhs and crores, RBI/SEBI/MCA terminology.

### Architecture: 10-Stage Lifecycle

Every deal follows the same arc. Each stage centers on a **key deliverable document** — the milestone that marks completion. The pipeline orchestrator (`00-pipeline-orchestrator.md`) routes to the appropriate stage.

| Stage | Name | Key Deliverable | Skills | Duration |
|-------|------|----------------|--------|----------|
| 0 | **Screening** | Screening Model + Verdict | 5 files | 2-4 weeks |
| 1 | **Concept Paper** | IC Presentation (15-25 pages) | 5 files | 3-6 weeks |
| 2 | **Head of Terms** | Signed HoT (4-12 redline rounds) | 4 files | 3-8 weeks |
| 3 | **Industry & Expert Calls** | Industry Note + GLG Call Notes | 3 files | 3-4 weeks |
| 4 | **Due Diligence** | DD File (20-70 sheets, 30+ versions) | 4 files | 6-10 weeks |
| 5 | **Financial Model** | Credit Model (35-45 sheets) | 3 files | 4-6 weeks |
| 6 | **FDIR** | Investment Report (35-45 pages) | 3 files | 2-3 weeks |
| 7 | **FIR** | IC Query Responses | 1 file | ~1 week |
| 8 | **Execution** | Sanction Letter + Documents | 1 file | 4-8 weeks |
| 9 | **Monitoring** | MIS Review + Covenant Tests | 3 files | 72 months |

**Total: 33 skill files across 11 directories** (1 pipeline orchestrator + 10 stage folders).

### Stage Details

**Stage 0 — Screening** (`stage-0-screening/`): Data triage (file inventory, entity mapping, gap identification), financial extraction (BPEA P&L format, ~295 rows, notes-to-accounts enrichment), working file builder (DSCR, run-rate, WC analysis), screening verdict (8-dimension scorecard, Go/Maybe/Kill).

**Stage 1 — Concept Paper** (`stage-1-concept-paper/`): Thesis builder (4-6 investment pillars with evidence hierarchy), structure drafter (corporate/transaction diagrams, indicative terms, security package), risk framework (5-8 risks with severity matrix), document assembly (canonical section order, review cycle management).

**Stage 2 — HoT** (`stage-2-hot/`): Terms design (opening position, full HoT template with all sections), redline tracker (round-by-round negotiation tracking, escalation triggers), covenant framework (DSCR/leverage design, NBFC covenants, cure mechanics, testing methodology).

**Stage 3 — Industry** (`stage-3-industry/`): Industry note (credit-focused sector analysis with peer comparison, regulatory landscape), expert call manager (GLG brief, question frameworks by expert type, structured call notes, synthesis).

**Stage 4 — DD** (`stage-4-dd/`): DD tracker (master IRL, workstream dashboard, vendor coordination), financial DD (QoE analysis, WC deep dive, cash flow bridge, NBFC portfolio analysis), commercial & legal DD (customer concentration, contract analysis, litigation summary, title reports).

**Stage 5 — Financial Model** (`stage-5-model/`): Model architecture (40+ sheet structure, formula flow, color coding, validation checks), projections & scenarios (three cases — Management/Ascertis/Downside, DSCR schedule, sensitivity tables, break-even analysis).

**Stage 6 — FDIR** (`stage-6-fdir/`): Section assembly (35-45 page modular assembly from all prior stages), IC preparation (presentation flow, anticipated Q&A, defense framework, pre-drafted IC conditions).

**Stage 7 — FIR** (`stage-7-fir/`): IC query resolution, domestic/offshore IC variants, condition tracking.

**Stage 8 — Execution** (`stage-8-execution/`): Sanction letter negotiation, CP tracker, disbursement checklist, handoff to monitoring.

**Stage 9 — Monitoring** (`stage-9-monitoring/`): Monthly MIS review (sector-specific KPIs, trend tracking), quarterly covenant testing (independent recalculation, headroom analysis, breach response workflow).

### Sector Variants

Every stage adapts for sector-specific patterns:

| Sector | Key Differences |
|--------|----------------|
| **Manufacturing** | EBITDA margin trajectory, capacity utilization, asset-backed security |
| **NBFC / Fintech** | Portfolio analytics (DPD, CRAR, ALM, vintage analysis), RBI regulatory layer, DuPont decomposition |
| **Agri / Food** | Seasonal WC (single harvest cycle), backward integration moat, farmer economics |

## What's NOT Included

Legal documentation drafting — the user is on the investments team, not the legal team. Stage 8 covers the investments team's execution responsibilities (SL review, CP tracking) but not the drafting of security documents, pledge agreements, or trust deeds.

## Tech Stack

| Layer | Choice | Why |
|-------|--------|-----|
| Skills | Markdown prompt files | No code needed — Claude Code reads them natively |
| Orchestration | Claude Code (native) | Already handles multi-file workflows |
| Data | PDFs, Excel, fund templates | The artifacts associates actually work with |
| Infra | None | Zero deployment, zero maintenance |

## Based On

Real deal artifacts from Ascertis Credit:
- **Completed deals:** Casablanca (manufacturing, 16-slide CP, 30+ DD versions), MPokket (NBFC, 67-sheet DD, 19-page CP)
- **Live deal:** Asandas (agri/food, 9 CP versions, 164-day WC cycle)
- **Completed (older):** Waaree (solar, monitoring artifacts)
- **Pipeline deals:** Omsairam (6-draft screening, promoter-direct), DP Jain (IB-sourced, Project Bolt)
- **Study guides:** 3 detailed concept paper study guides (Casablanca, MPokket, Asandas)

Skills are modeled on actual deliverables, not theoretical templates. Each skill encodes patterns observed across multiple real deals.

## Key Decisions

| Decision | Choice | Rationale | Date |
|----------|--------|-----------|------|
| DEC-001 | Markdown skills over code | GSD/Metaswarm proved markdown prompts are enough | 2026-03-11 |
| DEC-002 | 10-stage lifecycle architecture | Maps to real deal stages with document-based milestones | 2026-03-11 |
| DEC-003 | Deep sub-skills per stage | Each stage has 1-5 sub-skills based on actual workflow complexity | 2026-03-11 |
| DEC-004 | Investments team scope | User is investments team — not legal, not transaction monitoring | 2026-03-11 |
| DEC-005 | Indian private credit focus | Ind-AS, lakhs/crores, RBI/SEBI, BPEA template, NCD/CCD instruments | 2026-03-11 |
| DEC-006 | Based on real deal artifacts | Forensic analysis of 6 deals (file-level version tracing) | 2026-03-11 |
| DEC-007 | Screening model is disposable | Stage 0 model does NOT survive to Stage 5 — confirmed across all deals | 2026-03-11 |
| DEC-008 | Replaced flat 8-skill architecture | Original 8 skills were shallow and had broken handoffs. Stage-based is deeper | 2026-03-11 |

## Timeline

| Phase | Description | Status |
|-------|-------------|--------|
| Spar | Brainstorm, validate the idea | Done |
| Design v1 | Flat 8-skill architecture (superseded) | Done |
| Build v1 | Write 13 skill files (8 skills, 5 sub-skills) | Done (replaced) |
| Design v2 | 10-stage lifecycle with deep sub-skills | Done |
| Build v2 | Write 33 skill files across 10 stages | Done |
| Battle-test | Run on a real deal file from Ascertis Credit | Not started |
| Iterate | Refine skills based on real-world output quality | Not started |
