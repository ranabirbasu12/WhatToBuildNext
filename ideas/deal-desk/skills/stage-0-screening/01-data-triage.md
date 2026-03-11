# Skill: Data Triage

> Stage 0 — Screening | First skill in the pipeline
> Trigger: A new deal package lands (email attachment dump, Google Drive folder, zip file, WhatsApp forwards)
> Output: Structured inventory report + draft IRL (Information Requisition List)

---

## What This Skill Does

When a deal arrives, the raw data is chaos. You might get 18 folders with ALL CAPS names and duplicate copies (Omsairam), 305 PDFs totaling 2.1 GB with zero-byte junk files (DP Jain), or data trickling in across 6 numbered batches over 3 weeks plus two zip dumps (Casablanca). Your job is to turn this into a structured inventory before anyone touches a spreadsheet.

This skill produces three things:

1. **File Inventory** — every file catalogued by type, entity, year, and quality
2. **Entity Map** — all companies in the group identified with their relationships
3. **Draft IRL** — the first Information Requisition List of what we still need

---

## Step 1: Dump Assessment — What Arrived and How

Before opening a single file, understand the delivery channel. This tells you what to expect.

### Source Channel Check

| Source | What You'll Get | Quality Expectation |
|--------|----------------|---------------------|
| **Investment bank / advisor** | Pitch book (IM/CIM), CMA-format financials in Excel, maybe a model | Structured. Bank has already cleaned up. Look for their Excel model — it saves weeks. (Omsairam: Dipak at the bank sent `MKSPL financials.xlsx` which became the starting point.) |
| **Promoter directly** | Raw dump of everything they have. Annual reports, bank statements, tax filings, WhatsApp photos of plant equipment. | Messy. Duplicates guaranteed. File names will be inconsistent. Expect Indian language characters in some file names. |
| **CA / CFO office** | Audit reports, ITRs, GSTR summaries, MCA filings | Medium quality. Usually organized by year but may have naming issues. Watch for draft vs final audit reports mixed together. |
| **RBI-regulated entity (NBFC)** | Standardized folders: ALM, CRAR, DPD buckets, NPA data, RBI comms | Best organized. Regulatory formatting forces structure. (MPokket: 21 subfolders covering AUM, collections, policies, RBI comms.) |
| **Existing lender / participant** | Sanction letters, security docs, monitoring reports | Legal-heavy. Large scanned PDFs of executed agreements. |

### Delivery Format Check

- **Single zip / Drive folder**: Scan top-level structure first. Count folders, count files, note total size.
- **Multiple batches**: Track arrival dates. Label each batch (Batch 1 — 2025-04-02, Batch 2 — 2025-04-09, etc.). Casablanca had 6 numbered batches — if you don't track what arrived when, you'll re-process files you've already seen.
- **WhatsApp forwards**: Photos of plant, machinery, stock. Low priority for screening but note them. They matter later for site visit prep.

---

## Step 2: File Inventory — Catalogue Everything

Go through every file. For each one, record:

| Field | What to Capture | Example |
|-------|----------------|---------|
| **File Name** | As-is, including the messy caps and spacing | `OMSAIRAM ALLOYS PVT LTD ANNUAL REPORT FY23.pdf` |
| **Folder Path** | Where it sits in the dump | `Batch 1/Annual Reports/` |
| **File Size** | In MB | `18.4 MB` |
| **File Type** | Extension | `.pdf`, `.xlsx`, `.jpg` |
| **Category** | See classification below | `Annual Report` |
| **Entity** | Which company this belongs to | `OSAPL` |
| **Period** | Fiscal year or date range | `FY2022-23` |
| **Quality** | Digital or Scanned | `Scanned` |
| **Notes** | Anything odd | `Duplicate of file in Batch 2 folder` |

### File Classification Categories

Use these categories consistently. Every file must land in exactly one:

**1. Financial Statements**
- Annual Reports (full: Directors' Report + Auditor's Report + financials + notes)
- Standalone financial statements (just the numbers, no reports)
- Consolidated financial statements
- Provisional / management accounts (unaudited, usually for current year)
- CMA data (Credit Monitoring Arrangement — bank-formatted financials)

**2. Tax & Compliance Filings**
- GSTR returns (GST monthly/quarterly filings — useful for revenue cross-check)
- ITR (Income Tax Returns — useful for tax rate cross-check)
- MCA filings / ROC documents (Ministry of Corporate Affairs — for entity history)
- TDS returns

**3. Banking**
- Bank statements (monthly, by account, by bank)
- Sanction letters (existing facilities)
- CIBIL / credit bureau reports
- Stock statements / DP pledges

**4. Legal & Corporate**
- MOA / AOA (Memorandum and Articles of Association)
- Board resolutions
- Shareholder agreements
- Concession agreements / licenses (DP Jain: SPV concession agreements were 13-77 MB scanned legal docs)
- Land / property documents

**5. KYC & Identity**
- PAN cards (company and directors)
- TAN registration
- Aadhaar (directors)
- GST registration certificate
- DIPP / Udyam registration

**6. Operational Data**
- Stock statements (inventory by product/warehouse)
- Debtor/creditor ageing
- Order book / pipeline
- Plant photos / site images
- Capacity utilization data
- Power plant generation data (sector-specific)

**7. Regulatory (NBFC / regulated entities only)**
- ALM statements (Asset Liability Mismatch)
- CRAR computation (Capital to Risk-Weighted Assets Ratio)
- DPD / NPA classification reports
- RBI communications / inspection reports
- Policy documents (KYC, Fair Practice, Collections)

**8. Third-Party Reports**
- Investment Memorandum / CIM (from bank)
- Valuation reports
- Credit rating reports (CRISIL, ICRA, CARE, India Ratings)
- Legal due diligence reports
- Technical / lender's engineer reports

### Quality Assessment — Digital vs Scanned

File size is your fastest proxy:

| Size Range (for a single year annual report) | Likely Quality |
|----------------------------------------------|---------------|
| **200 KB - 5 MB** | Digital PDF. Text-selectable. Clean extraction possible. |
| **5 - 15 MB** | Could be either. Open and check if you can select text. |
| **15 - 70 MB** | Almost certainly scanned. Photocopied pages, possibly at an angle. Expect OCR pain. |
| **> 100 MB** | Multi-document scan dump or high-res photos embedded. (DP Jain's CIBIL report was 562 MB.) |
| **0 bytes** | Empty file. DP Jain's dump had these. Flag and request re-send. |

**Quick test**: Open the PDF, try to select a number on the P&L page. If you can highlight and copy `1,23,45,678`, it's digital. If the highlight selects the whole page as an image block, it's scanned.

---

## Step 3: Entity Mapping — Who's Who in the Group

This is where deals get complicated. Indian promoter groups rarely have just one company.

### How to Identify Entities

1. **Directors' Report**: Lists subsidiaries, associates, joint ventures. Look for the section "Details of Subsidiary/Joint Venture/Associate Companies" (usually a Form AOC-1 annexure).
2. **Consolidated financials**: The consolidation note lists every entity included, with ownership percentage.
3. **Related Party Transactions note**: Lists entities the company transacts with — group companies, key management personnel entities, trusts.
4. **CIN numbers**: Each company has a unique Corporate Identification Number. Use this to de-duplicate if the same entity appears under slightly different names.
5. **Bank sanctions**: May list group companies as co-obligors or guarantors.

### Entity Map Format

Build a table like this. **Every entity MUST include the source citation** — where in the documents you found it:

| Entity | Short Name | CIN | Relationship | Ownership % | Financials Received? | Status | Source |
|--------|-----------|-----|-------------|-------------|---------------------|--------|--------|
| Omsairam Alloys Pvt Ltd | OSAPL | U27100MH2010PTC... | **Main borrower** | — | FY21, FY22, FY23 Stdl + Consol | Active | [Consol AR FY24, p.1, cover page] |
| Shri Alloys Pvt Ltd | SAPL | U27100MH2012PTC... | Subsidiary | 100% | FY22, FY23 Stdl only | Active | [Consol AR FY24, p.6, Auditor's "Other Matter" para] |
| Kapila Metals Trading LLP | Kapila | AAB-1234 | Group company (promoter interest) | N/A | None received | Active | [Related Party note, AR FY24, p.XX, Note YY] |

**Every entity entry needs a source.** If you find an entity name in a file, cite the file, page, and the text/section where it appears. If the relationship or ownership % comes from a different page than the entity name, cite both.

**Why this matters**: Every entity that could be a borrower, guarantor, or co-obligor needs separate financials. If you miss a subsidiary at triage, you'll be chasing it 3 weeks later when the VP asks "where are SAPL's numbers?" And if you list an entity that doesn't actually exist in the AR, you've wasted everyone's time chasing a phantom.

### Common Indian Group Structures to Watch For

- **Promoter holding company** at the top (often a family trust or LLP)
- **Multiple operating companies** split by product line, geography, or legacy reasons
- **SPVs** for specific projects or concessions (DP Jain had multiple road SPVs)
- **Trading entities** that buy from manufacturing entities (transfer pricing scrutiny)
- **Real estate holding companies** that own the land/plant (lease to operating company)
- **Partnership firms** alongside Pvt Ltd companies (older promoters especially)

---

## Step 4: Year Coverage Matrix

For each entity, track what years you have. Indian fiscal year runs April to March.

| Entity | FY20-21 | FY21-22 | FY22-23 | FY23-24 | 9M FY24-25 (Prov.) |
|--------|---------|---------|---------|---------|---------------------|
| OSAPL Standalone | Annual Report | Annual Report | Annual Report | Missing | Missing |
| OSAPL Consolidated | In AR | In AR | In AR | Missing | Missing |
| SAPL Standalone | Missing | Annual Report | Annual Report | Missing | Missing |
| Kapila Metals | Missing | Missing | Missing | Missing | Missing |

**Minimum for screening**: 3 years of audited standalone financials for the main borrower. Ideally FY22, FY23, FY24 (most recent three). If FY24 audit is delayed (common through Oct-Nov of the following year), accept FY21-FY23 + provisional FY24.

**For credit paper**: You need 5 years eventually. But at screening, 3 is the floor.

---

## Step 5: Duplicate Detection

Duplicates waste time and create version confusion. Check for:

### Exact Duplicates
- Same file name in multiple folders (Omsairam had identical copies of annual reports in two directories)
- Same file size = high probability of duplicate. Different sizes with similar names = possibly different versions.

### Near Duplicates
- `OSAPL AR FY23.pdf` (18 MB) and `Omsairam Annual Report 2023.pdf` (18 MB) — same file, different name
- Draft vs final versions mixed together without labels

### Resolution
- Keep one copy. Note in inventory which copy you're using and where duplicates exist.
- If sizes differ, open both — one may be a draft, the other final. Check auditor's signature date.

---

## Step 6: Gap Identification

Compare what you have against what you need. **For every gap, document what you searched.** Don't just say "CIBIL report not received" — say "Searched all 53 directories and 339 files; no file matching CIBIL, credit bureau, TransUnion, or Experian found." This proves the gap is real, not a search failure.

Standard checklist:

### Must-Have for Screening (Priority 1)

- [ ] Audited Annual Reports — main borrower — last 3 fiscal years
- [ ] Standalone financials with notes to accounts for each year
- [ ] Consolidated financials (if group has subsidiaries)
- [ ] Auditor's Report (qualified? unqualified? emphasis of matter?)
- [ ] Latest available provisional / management accounts
- [ ] Basic KYC: PAN of company, PAN of promoter, GST registration

### Should-Have for Screening (Priority 2)

- [ ] Bank statements — last 12 months, all operating accounts
- [ ] CIBIL / credit bureau report — company and promoter
- [ ] Existing debt schedule (list of all lenders, amounts, tenors, rates)
- [ ] GSTR summary — last 12 months (cross-check against reported revenue)
- [ ] CMA data / bank model (if sourced through investment bank)
- [ ] Subsidiary financials — all entities, all available years

### Nice-to-Have at Screening (Priority 3)

- [ ] Directors' Report (governance quality signal)
- [ ] Related party transaction details
- [ ] Order book / revenue pipeline
- [ ] Debtor/creditor ageing schedule
- [ ] Stock/inventory statements
- [ ] Property/asset documents
- [ ] Rating rationale (if rated)

---

## Step 7: Draft the Information Requisition List (IRL)

The IRL is the formal request sent to the company or advisor for missing data. Structure it as follows:

### IRL Format

| S.No. | Category | Document Required | Entity | Period | Priority | Status | Remarks |
|-------|----------|-------------------|--------|--------|----------|--------|---------|
| 1 | Financial | Audited Annual Report | OSAPL | FY2023-24 | P1 | Pending | Most recent year not received |
| 2 | Financial | Standalone financials with full notes | SAPL | FY2020-21 | P2 | Pending | Only FY22 and FY23 received |
| 3 | Financial | Consolidated financials | OSAPL | FY2023-24 | P1 | Pending | — |
| 4 | Banking | Bank statements (all operating accounts) | OSAPL | Apr 2024 - Dec 2024 | P1 | Pending | Need last 9 months |
| 5 | KYC | PAN card | Kapila Metals | — | P2 | Pending | Group entity — KYC needed if guarantor |
| 6 | Financial | Provisional P&L and BS | OSAPL | 9M FY24-25 | P1 | Pending | Latest management accounts |
| 7 | Tax | GSTR-3B summary | OSAPL | Apr 2023 - Dec 2024 | P2 | Pending | Revenue cross-check |
| 8 | Debt | Complete debt schedule | All entities | Current | P1 | Pending | Lender, outstanding, tenor, rate, security |

### IRL Drafting Rules

1. **Group by category**, not by entity. Easier for the CFO/CA to action.
2. **Be specific about periods**. Don't write "recent bank statements." Write "Bank statements for HDFC Current A/c No. XXXX, April 2024 to December 2024."
3. **Mark priority clearly**. P1 = cannot proceed without this. P2 = needed before credit paper. P3 = needed before CP clearance.
4. **Include a Status column** that gets updated as items come in. This becomes a living tracker.
5. **Add Remarks** explaining why you need it (helps the company understand urgency).

---

## Step 8: Produce the Triage Report

Compile everything into a single document with these sections:

```
DEAL TRIAGE REPORT
==================

Deal Name:          [Name]
Date Received:      [Date of first data dump]
Source:             [Promoter / Investment Bank / Existing Lender]
Source Contact:     [Name, email, phone]

1. DATA RECEIVED
   - Total files: [count]
   - Total size: [X.X GB]
   - Delivery: [Single dump / Multiple batches — list dates]
   - Format quality: [Mostly digital / Mostly scanned / Mixed]

2. ENTITY MAP
   [Entity table from Step 3]

3. YEAR COVERAGE
   [Coverage matrix from Step 4]

4. KEY GAPS
   - [Bullet list of the most critical missing items]

5. DATA QUALITY FLAGS
   - [Note any zero-byte files, suspected duplicates, scanned-only docs]
   - [Note if any financials appear to be drafts vs signed/audited]

6. PRELIMINARY OBSERVATIONS
   - [Anything notable from a quick skim: qualified audit opinion,
     auditor change, restated figures, related party red flags]
   - **EVERY observation must cite source: [filename, page number, quoted text]**
   - Example: "Subsidiary with Rs 643 Cr assets audited by different auditor
     [Source: Consolidated AR 2023-24-ocr.pdf, p.6, 'total assets of Rs. 64,305.64 Lacs']"

7. RECOMMENDED NEXT STEPS
   - Send IRL to [contact] by [date]
   - Priority extraction: [which entity/years to start with]
   - Flag for senior: [anything that needs escalation before proceeding]
```

---

## Handoff to Next Skill

Once the Triage Report and IRL are complete, the deal is ready for **02-financial-extraction.md**. Pass forward:

- The file inventory (so extraction knows which PDFs to open)
- The entity map (so extraction creates the right worksheets)
- The year coverage matrix (so extraction knows which years to pull)
- The quality assessment (so extraction knows where to expect OCR issues)
- Any CMA / bank model Excel files (these become the starting point for the BPEA format workbook)

---

## Common Pitfalls

1. **Don't start extraction before triage is done.** You'll extract FY22 numbers, then discover the company sent a restated FY22 in Batch 3. Wasted work.
2. **Don't assume folder names are accurate.** A folder called "FY23" might contain FY22 documents. Check the actual document dates.
3. **Don't ignore group companies.** The promoter's other businesses are where risks hide — circular transactions, fund diversion, related party loans.
4. **Don't let the IRL sit.** Send it within 24 hours of receiving data. Every day of delay pushes the whole timeline.
5. **Don't rename the original files.** Work with copies. Keep the original dump untouched for audit trail.
6. **Watch for Indian fiscal year confusion.** "FY23" means April 2022 to March 2023. "CY23" (calendar year) means January to December 2023. Annual Reports dated March 2023 are for FY23. Confusion here cascades into every spreadsheet.
