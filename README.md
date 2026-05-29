# Legal AML Starter Kit Assistant

A free, local-first, single-file wizard that helps a small Australian legal
practice (≤15 personnel) customise [AUSTRAC's publicly-available Legal profession
program starter kit](https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/program-starter-kits/legal-profession-program-starter-kit/legal-profession-program-starter-kit-document-library)
ahead of the Tranche 2 commencement on **1 July 2026**.

- **Version:** v0.1.0
- **Modelled on AUSTRAC starter kit release:** January 2026
- **License:** [MIT](./LICENSE)
- **Status:** alpha — usable, but template files and some catalogue titles
  still need verification against the AUSTRAC library (see [Known gaps](#known-gaps)
  and [`VERIFIED.md`](./VERIFIED.md)).

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
3. Work through the 12 wizard steps. Progress autosaves to your browser's
   `localStorage`; attached DOCX templates persist in IndexedDB.
4. On the **Templates** step, attach a `.docx` template per recommended document.
   Templates use Mustache-style tags — e.g. `{practiceName}`, `{complianceOfficer}`,
   `{overallRiskRating}`. The Templates step lists every available tag.
5. On the **Generate** step, click **Generate selected documents** — produces a
   ZIP of rendered DOCX files (or single DOCX, or a fallback `.txt` bundle if no
   templates are attached).

Everything runs on your device. No data is sent to a server. The bundled
`./vendor/` JavaScript libraries (PizZip, docxtemplater, JSZip) ensure the tool
works without an internet connection.

---

## What's in the box

```
.
├── index.html                ← the wizard (single file, run in a browser)
├── vendor/                   ← bundled third-party libraries (verify via VENDOR.md)
│   ├── pizzip.min.js
│   ├── docxtemplater.js
│   └── jszip.min.js
├── LICENSE                   ← MIT + third-party + AUSTRAC attribution notice
├── DISCLAIMER.md             ← full "not legal advice" disclaimer
├── SECURITY.md               ← how to report a security issue
├── VENDOR.md                 ← vendored library versions and SHA-256 hashes
├── VERIFIED.md               ← which catalogue entries are verified vs extrapolated
└── README.md
```

DOCX templates themselves are **not** bundled. See [Templates](#templates) below.

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
