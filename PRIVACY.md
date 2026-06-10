# Privacy & data handling

This summary records the personal-information posture of the Legal AML Starter
Kit Assistant for the purposes of the Australian Privacy Principles (APPs) and
the Privacy Act 1988 (Cth). It ships with the tool so reviewers and users can
verify the claims against the code.

**Tool version:** v0.2.0
**Regulatory content verified:** 2026-06-09 (see `CONTENT_VERSION` in source)

## TL;DR

- The tool runs entirely in the user's browser.
- Nothing is sent to a server. No analytics, no telemetry, no error reporter,
  no font CDN call.
- Wizard data lives in the user's browser (`localStorage` + IndexedDB).
- JSON snapshots exported from the dashboard are **encrypted by default**
  (AES-GCM-256, key derived from a passphrase via PBKDF2-SHA256 600,000
  iterations). A "Save unencrypted" escape hatch exists for explicit
  test-data use.
- The tool is the wrong place for storing scanned customer identity
  documents. Use it for the structured records *about* your AML/CTF
  program, not the underlying customer evidence.

## What the tool collects

The tool prompts the user (typically the AML/CTF Compliance Officer) to enter:

- **Practice profile.** Name, ABN/ACN, structure, personnel count, addresses.
- **Governance.** Names and roles of the governing body, senior manager and
  AML/CTF Compliance Officer.
- **Designated services and risk profile.** Which Table 6 services are
  provided, customer-type mix, jurisdictional exposure, PEP and
  delivery-channel risk factors.
- **Process notes and dates.** Enrolment dates, CO appointment date, training
  cadence, evaluation cadence.

The tool does not collect customer identity documents, scanned correspondence,
bank statements, or anything outside the structured wizard fields. If a user
pastes such material into a free-text field, it lives only in their browser
per the storage model below.

## Where the data is stored

| Store | Key / database | What is in it |
|---|---|---|
| `localStorage` | `austrac_legal_starter_kit_local_mvp_v3` | Serialised wizard answers |
| `localStorage` | `austrac_starter_kit_settings_v1` | Sensitive-matter mode + clear-on-close toggles |
| `localStorage` | `austrac_starter_kit_data_loss_warning_seen_v1` | First-run modal dismissal flag |
| IndexedDB | `austrac-aml-starter-kit-v1` → `templates` | Bundled and user-uploaded `.docx` templates |
| IndexedDB | `austrac-aml-starter-kit-v1` → `sdtState` | Per-document form-field state |
| IndexedDB | `austrac-aml-starter-kit-v1` → `snapshots` | Version-history snapshots |
| IndexedDB | `austrac-aml-starter-kit-v1` → `audit` | Local-only audit log: timestamped record of material user actions (export, import, generate, clear). Small, non-sensitive metadata only — no wizard data, no document content |

No server. No cloud sync. The data never leaves the user's machine unless
the user explicitly exports a snapshot and saves the resulting file.

### Audit log

The dashboard's **Export audit log (JSON)** action exports a timestamped
record of the material actions the user has taken in this browser:
snapshot exports (plaintext or encrypted), snapshot imports, document
generations (single or ZIP), data clears, and audit-log exports
themselves. Each entry records the action type, the tool version, and a
small bag of non-sensitive metadata (e.g. a filename base, the count of
documents generated). No wizard answers, no document content, and no
personal data are included.

Like everything else in the tool, the audit log is local-only. It is
cleared when the user runs **Clear local browser save**; the clear
itself is then recorded as the first entry of the next session, so the
user has a record that the clear happened.

## Encryption posture

- **Manual exports (dashboard → "Export snapshot (JSON)"):** encrypted by
  default with AES-GCM-256, key derived from a user passphrase via
  PBKDF2-SHA256 (600,000 iterations, 16-byte random per-export salt,
  12-byte random per-export IV). All work runs in the browser via the Web
  Crypto API. A "Save unencrypted" button exists with explicit warning copy.
- **Backup-before-clear ("Save as TEST/LIVE data & clear"):** not currently
  encrypted. Use only on a machine you control; treat the file as sensitive.
- **At-rest in the browser:** not encrypted. The `localStorage` and IndexedDB
  stores are plain. Key management without a server-side anchor would
  either require a passphrase prompt every reload (which would break the
  double-click-and-go UX that makes the tool usable for non-technical
  practitioners) or store the key alongside the data (which provides no
  real protection). The tool documents the trade-off honestly and provides
  the Sensitive-matter mode and Clear-on-close options for users who need
  stricter in-browser handling.

## Privacy options (Step 1)

Two toggles are exposed in the wizard's Step 1 "Privacy options" panel:

- **Sensitive-matter mode.** Pauses autosave to `localStorage` **and**
  the per-edit version-history snapshots otherwise written to IndexedDB.
  Useful for SMR-related narratives where each keystroke would otherwise
  land on disk. **Not full in-memory mode:** bundled templates and
  per-document form-field state (from open document previews) still live
  in IndexedDB. To clean those up too, use the dashboard's *Clear local
  browser save* action. The setting survives reload (stored under a
  separate `localStorage` key from the wizard data).
- **Clear local data when this tab closes.** Registers a `beforeunload`
  handler that wipes the wizard `localStorage` entry on tab close.
  IndexedDB (templates, document state) is not wiped — browsers do not
  reliably allow async cleanup at unload — and that limit is surfaced in
  the toggle's own UI copy.

## Retention

Browser data persists indefinitely unless the user clears it. The
"Clear local browser save" dashboard action wipes both `localStorage` and
IndexedDB after offering a backup download. Whether and how long the user
retains exported JSON snapshots is their decision — typically driven by
the practice's AML/CTF retention obligation (commonly 7 years), which is
the firm's responsibility, not the tool's.

## Cross-border transfer

None at the tool boundary. The tool fetches no external resource at
runtime. All vendored libraries (PizZip, docxtemplater, JSZip, Mammoth)
are loaded from the user's local copy. No fonts, no CDN, no analytics.
APP 8 is not engaged.

## Hyperlinks in generated `.docx` files (downstream of the tool)

The bundled AUSTRAC templates carry **202 external hyperlinks** across
41 of 44 templates, resolving to 60 unique targets — all references to
AUSTRAC, FATF, DFAT, Basel Governance, OAIC, the Attorney-General's
Department, ASIC, APRA, AFSA, the ABR, and similar Australian-government
and international AML bodies. These references survive into the
documents the tool generates.

Important distinctions:

- **The tool itself does not follow these links** at generation time.
  Hyperlinks are stored as plain XML inside the `.docx`; the tool never
  resolves them.
- **Word does not auto-fetch** when a user opens the generated `.docx`.
  Hyperlinks activate only when the recipient clicks them (Word prompts
  for confirmation by default for external links).
- The links are AUSTRAC's editorial choices, inherited verbatim from
  the source kit. The tool's "no network egress" claim covers the tool's
  own behaviour — it cannot bind what happens when a recipient opens a
  generated document and clicks a link in their Word client.

If your privacy posture requires generated documents with *no* outgoing
links, the only path is to scrub the external relationships in the
bundled templates before generation. That is not the default — doing so
would break the AUSTRAC source documents' own cross-references back to
authoritative guidance — but the option is documented here so a firm
with that requirement can choose.

## Breach response

Because the tool is client-side, there is no central data store to breach
and no user list to notify. The user's own machine, or their export files,
are the only surfaces of concern. If a user's machine or export file is
compromised, the user is the controller and the responsible party under
the Notifiable Data Breach scheme. The tool's contribution is to keep its
own export format encrypted by default and to keep the in-browser
footprint minimal.

If a vulnerability is found in the tool itself that affects all users
(e.g. an XSS sink in an import path), it is handled per
[`RECALL.md`](./RECALL.md).

## APP alignment

| APP | How the tool addresses it |
|---|---|
| APP 1 — open and transparent | This document; [`DISCLAIMER.md`](./DISCLAIMER.md); README |
| APP 3 — collection | Only structured wizard inputs from the user themselves; no inference, no third-party fetch |
| APP 5 — notice of collection | First-run modal + this document explain what is collected and where it lives |
| APP 8 — cross-border disclosure | N/A — no disclosure of any kind |
| APP 11 — security | Browser-local storage + encrypted-by-default exports + sensitive-matter mode + clear-on-close + no network egress |
| APP 12 — access | Direct user access via browser DevTools or the JSON export |

## What the tool is not the right place for

- Scanned customer identity documents.
- Long-term archival of AML records (use your matter-management system).
- Anything related to a specific identified client without the firm
  having its own legal basis for processing that client's personal
  information.

## See also

- [`DISCLAIMER.md`](./DISCLAIMER.md) — what the tool is and is not.
- [`LPP.md`](./LPP.md) — solicitor confidentiality and legal professional privilege.
- [`SECURITY.md`](./SECURITY.md) — how to report a security issue.
- [`RECALL.md`](./RECALL.md) — how OSS users are notified of issues.
