# Legal AML Starter Kit Assistant

A free, local-first, single-file wizard that helps a small Australian legal
practice (≤15 personnel) customise [AUSTRAC's publicly-available Legal profession
program starter kit](https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/program-starter-kits/legal-profession-program-starter-kit/legal-profession-program-starter-kit-document-library)
ahead of the Tranche 2 commencement on **1 July 2026**.

- **Version:** v0.2.0
- **Modelled on AUSTRAC starter kit release:** January 2026
- **License:** [MIT](./LICENSE); bundled AUSTRAC templates © Commonwealth of
  Australia, reused under AUSTRAC's Creative Commons licence with attribution.
- **Status:** alpha — usable. The full set of 43 AUSTRAC Legal profession + Conveyancers
  templates is now bundled in [`vendor/templates/`](./vendor/templates) and auto-loads
  when the file is served (or one-click bulk-loads when opened from `file://`).

> ⚠️ **Not legal advice. Not affiliated with AUSTRAC.** This tool helps prepare
> records from your own inputs. It does not decide compliance, verify customer
> identity, screen sanctions or PEPs, monitor transactions, file SMRs/TTRs/IFTIs,
> or enrol your practice with AUSTRAC. Those obligations remain with the practice
> and are discharged through AUSTRAC Online and your own controls. See
> [`DISCLAIMER.md`](./DISCLAIMER.md) for the full disclaimer, including the
> tipping-off offence (AML/CTF Act s 123).
>
> If you are a solicitor, confirm with your professional indemnity insurer that
> use of unverified document-assembly tools is consistent with your cover.

---

## Quick start

1. Download or clone this repository.
2. Open `index.html` in a modern browser (Chrome/Edge/Firefox/Safari, last two
   versions). No server required.
3. Work through the 13 wizard steps. Progress autosaves to your browser's
   `localStorage`; attached DOCX templates persist in IndexedDB.
4. **Templates auto-load.** When the file is served over `http(s)` (e.g.
   `python -m http.server` from the repo root) the 43 bundled AUSTRAC templates
   load automatically on boot. When you open the file via `file://` most browsers
   block the auto-fetch — the Templates step shows a one-click "Load AUSTRAC
   template pack" button that lets you select all `.docx` files in
   `vendor/templates/` in one go. Templates persist in IndexedDB after either
   path, so it's a one-time action.
5. Attach your own `.docx` to override any bundled template (uses Mustache-style
   tags — `{practiceName}`, `{complianceOfficer}`, etc; full list on the
   Templates step).
6. On the **Generate** step, click **Generate selected documents** — produces a
   ZIP of rendered DOCX files (or single DOCX).
7. The **Compliance dashboard** (step 13) shows the firm's full AML state on
   one page and is the source of the point-in-time PDF report.

Everything runs on your device. No data is sent to a server. The bundled
`./vendor/` JavaScript libraries (PizZip, docxtemplater, JSZip) ensure the tool
works without an internet connection.

---

## What's in the box

```
.
├── index.html                ← the wizard (single file, run in a browser)
├── vendor/
│   ├── pizzip.min.js         ← DOCX zip handling
│   ├── docxtemplater.js      ← Mustache-style template engine
│   ├── jszip.min.js          ← ZIP bundling for multi-doc output
│   └── templates/            ← 43 AUSTRAC starter-kit .docx files (auto-loaded)
│       ├── policy-document.docx
│       ├── process-document.docx
│       ├── ra-conveyancing.docx
│       ├── (etc — see vendor/templates/manifest.json)
│       └── _bundle.ps1       ← script that copies + renames the AUSTRAC originals
├── LICENSE                   ← MIT + third-party + AUSTRAC attribution notice
├── DISCLAIMER.md             ← full "not legal advice" disclaimer
├── SECURITY.md               ← how to report a security issue
├── VENDOR.md                 ← vendored library versions and SHA-256 hashes
├── VERIFIED.md               ← which catalogue entries are verified vs extrapolated
└── README.md
```

---

## Scope

**The tool does** help the practice:

- Run a suitability self-assessment against AUSTRAC's seven criteria (≤15 personnel
  etc.) with warn-and-acknowledge if criteria aren't met.
- Capture practice profile, three-role governance (governing body, senior manager,
  AML/CTF Compliance Officer), the 9 Table 6 designated services, customer types,
  PEP exposure, and 6-dimension ML/TF/PF risk ratings.
- Capture initial/simplified/enhanced/ongoing CDD approach, beneficial-owner
  threshold, sanctions and PEP screening processes, source-of-funds approach,
  tipping-off controls and trigger-event approach.
- Capture reporting (SMR/TTR/IFTI), recordkeeping (7-year retention default),
  training cadence, and 3-yearly independent evaluation.
- Recommend the relevant AUSTRAC documents from a built-in catalogue (~35
  templated documents + 3 reference PDFs), grouped by AUSTRAC's Step 1 / Step 2 /
  Step 3 structure.
- Auto-derive deadlines (28-day enrolment, 14-day CO notification) from the dates
  you enter.
- Generate rendered DOCX outputs from your own AUSTRAC-aligned templates, or a
  fallback text bundle if no templates are attached.
- Export and import progress as JSON.

**The tool does not** (and won't) attempt:

- Customer identity verification or document authentication.
- Live sanctions screening (DFAT Consolidated List) or PEP screening.
- Transaction monitoring.
- Submission of any report (SMR / TTR / IFTI / annual compliance report) to AUSTRAC.
- Enrolment of the practice with AUSTRAC Online.
- Provision of legal advice.

---

## Templates

The AUSTRAC starter kit is published as Word (.docx) documents. This tool
*renders* templates; it does not bundle them. You can:

- **Recommended:** Download AUSTRAC's official Word documents from the
  [Legal profession program starter kit document library](https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/program-starter-kits/legal-profession-program-starter-kit/legal-profession-program-starter-kit-document-library)
  and add `{tag}` placeholders where blanks appear. Tag names match the field
  ids in the wizard (the Templates step lists them all).
- Or write your own DOCX templates from scratch using the same tag contract.

Tag tips:

- Type braces as plain `{` `}` — if Word autocorrects to curly quotes the tag
  will fail to render.
- Tags with no matching field render as empty (a friendly default for
  half-completed drafts).
- The Templates step has a collapsible "Show all available tags" list with every
  field id currently in the data model.

---

## Known gaps

These are the spots where the tool's structure is in place but content needs
verification before relying on it:

- **Catalogue titles.** Several form titles in `DOCUMENT_CATALOGUE` were
  extrapolated from the parallel AUSTRAC Accountants and Conveyancers kits
  (identical filename pattern, "Legal profession" substituted). Re-verify against
  the actual AUSTRAC library, especially: general-staff personnel due diligence
  form, training records form, final onboarding checks form, reportable matter
  working form, ongoing CDD/monitoring form, and the effectiveness-check suite.
- **DOCX templates.** None are bundled. The fallback text bundle proves the
  wizard flow works, but practices need real AUSTRAC-aligned `.docx` files to
  use the output.
- **Verification mapping.** [`VERIFIED.md`](./VERIFIED.md) lists which catalogue
  entries are verified vs extrapolated. Contributions to move entries from
  "extrapolated" to "verified" are the highest-value PRs.
- **Accessibility audit.** Keyboard navigation works; full ARIA + screen-reader
  audit hasn't been done.

---

## How the catalogue maps to AUSTRAC

The catalogue follows AUSTRAC's published structure:

| AUSTRAC section | Catalogue category |
|---|---|
| Spine documents (Customise guide, Risk assessments, Policy, Process) | `Step 1 — Spine documents` |
| Personnel forms | `Step 1 — Personnel forms` |
| Customer forms — onboarding (per service line × customer type) | `Step 2 — Customer forms — Onboarding` |
| Customer forms — initial CDD (per service line × customer type) | `Step 2 — Customer forms — Initial CDD` |
| Customer forms — lifecycle (escalation, ongoing, trigger event, etc.) | `Step 2 — Customer forms — Lifecycle` |
| Maintain program forms (effectiveness checks, independent evaluation) | `Step 3 — Maintain program forms` |
| Companion PDFs (quick guides, factsheets) | `Reference (PDF)` |

Conditional documents resolve from the practice's answers:

- Conveyancing risk assessment + conveyancing form set → enabled when designated
  service 1 (real estate) is selected.
- Other-professional-services risk assessment + other form set → enabled when
  any of designated services 2–9 is selected.
- Sole-practitioner branch — the "CO equals governing body" PDD form is included
  and the Escalation form is suppressed (per AUSTRAC guidance that one-person
  practices don't use escalation forms).
- TTR effectiveness check → only when the practice may receive physical currency
  ≥ A$10,000.
- IFTI effectiveness check → only when the practice may send/receive
  international funds transfer instructions.

---

## Contributing

Issues and PRs welcome. Useful contributions in priority order:

1. **Verifying catalogue titles** against the actual AUSTRAC library and fixing
   any drift.
2. **Authoring or contributing DOCX templates** that match the tag contract.
3. **Extending [`VERIFIED.md`](./VERIFIED.md)** — moving catalogue entries from
   "extrapolated" to "verified" with the AUSTRAC source URL.
4. **Accessibility** — keyboard navigation, ARIA labels, screen-reader testing.
5. **Catalogue maintenance** as AUSTRAC publishes new releases (update
   `AUSTRAC_KIT_RELEASE` constant + bump version).
6. **Optional / later:** on-device AI drafting (Chrome Prompt API / WebLLM) for
   narrative fields; local DFAT Consolidated List sanctions matching.

Please don't commit any real client data into issues or test fixtures.

---

## Sources

- [AUSTRAC — Legal profession program starter kit document library](https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/program-starter-kits/legal-profession-program-starter-kit/legal-profession-program-starter-kit-document-library)
- [AUSTRAC — Step 1: Customise your legal profession program](https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/program-starter-kits/legal-profession-program-starter-kit/step-1-customise-your-legal-profession-program-using-starter-kit)
- [AUSTRAC — Step 2: Use your legal profession program](https://www.austrac.gov.au/reforms/sector-specific-guidance/legal-profession-guidance/legal-profession-program-starter-kit/step-2-use-your-legal-profession-program)
- [AUSTRAC — Step 3: Maintain and review your legal profession program](https://www.austrac.gov.au/reforms/sector-specific-guidance/legal-profession-guidance/legal-profession-program-starter-kit/step-3-maintain-and-review-your-legal-profession-program)
- [AUSTRAC — Program starter kits hub](https://www.austrac.gov.au/reforms/program-starter-kits)
- [AML/CTF Act 2006](https://www.legislation.gov.au/Series/C2006A00169) (s 6(5B) Table 6 designated services)
- [AML/CTF Rules 2025](https://www.legislation.gov.au/F2025L01023/latest/text)
