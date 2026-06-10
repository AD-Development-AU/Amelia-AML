# Legal professional privilege & client confidentiality

This memo records how the Legal AML Starter Kit Assistant is positioned with
respect to solicitor confidentiality duties and legal professional privilege
(LPP). It ships with the tool so solicitors and their professional indemnity
insurers can assess the posture before adopting the tool in practice.

**Tool version:** v0.2.0

## Position summary

LPP and solicitor confidentiality are treated by this tool as **a control
distinct from, and complementary to, the Australian Privacy Principles**.
The tool's architecture deliberately removes the surfaces that would put
privileged material at risk of waiver or third-party exposure.

## Specifically

1. **No network egress.** The tool fetches no external resource at runtime.
   No screening API, no AI endpoint, no telemetry, no analytics, no CDN
   font request. Verifiable by recording a full wizard session in browser
   DevTools' Network tab.

2. **No third-party processor.** No data leaves the user's browser, so no
   third party processes privileged material on the user's behalf.

3. **No cloud sync.** Wizard data lives in `localStorage` and IndexedDB on
   the user's machine. The tool does not synchronise to any service.

4. **No AI/LLM components in this release.** Future on-device LLM
   integration — if ever introduced — would be gated by an explicit user
   choice and would not introduce a third-party recipient of privileged
   material. None ships in v0.2.0.

5. **Sensitive-matter mode.** Step 1 "Privacy options" includes a
   *Sensitive-matter mode* toggle that disables autosave to `localStorage`
   entirely, so narratives related to suspicious-matter reports or other
   privileged communications can be drafted without the tool persisting
   them between page reloads.

6. **Encrypted exports by default.** JSON exports of wizard state are
   encrypted with AES-GCM-256 by default. The "Save unencrypted" option
   exists for explicit test-data use and is labelled accordingly.

## What this kit is *not* — out of scope for v0.2.0

The kit deliberately does **not** include an LPP decision-tree workflow.
Specifically, the following are out of scope:

- **Privilege test** — guided assessment of whether information attracts
  legal professional privilege (legal-advice vs litigation privilege,
  dominant-purpose test, third-party communication carve-outs).
- **Suppression logic** — automated decisions about which information
  fields are withheld or redacted from an SMR-related artefact because
  privilege applies.
- **Form structure for privileged-grounds SMRs** — distinct form variants
  for "all grounds privileged" vs "some grounds privileged" vs "no
  privilege" outcomes.
- **Versioned LPP module configs** — splitting the above into
  independently-versioned configuration rows so AUSTRAC's anticipated 2026
  Ministerial Guidelines on LPP can land partial updates.

A firm that needs these workflows should treat this kit as a document
assembly aid only and run the privilege analysis through its usual
matter-management or specialist AML-compliance system. Sole practitioners
and very small firms may find that external legal advice on each
privilege decision is the right control rather than a guided workflow.

The kit's contribution to LPP risk is **architectural** (no third-party
processor, no network egress, encrypted exports — see above) and
**informational** (tipping-off warnings + cautious framing in SMR-related
steps). It is not a substitute for a privilege-decision workflow.

If you are evaluating a tool that does include these workflows, the
parallel AML/CTF + KYC + Conflicts compliance system (referred to in this
codebase's docs as "AITL") is the maintainer's separate, operational
build for firms that need the full decision-tree posture. The starter
kit and that system are complementary, not substitutes.

## Tipping-off (AML/CTF Act 2006 s 123)

The tool surfaces an explicit tipping-off warning in Step 8 (Reporting)
and at the top of Step 10 (Documents) for the escalation, reportable-matter
and unusual-activity forms. The tool itself does not:

- decide whether to disclose;
- send any disclosure;
- analyse the substance of a suspicion;
- evaluate "tipping-off risk" of any user-drafted text.

Those decisions remain with the AML/CTF Compliance Officer and external
legal advice. The tool's contribution is to flag the obligation and to
keep the records local to the practice.

## Where the LPP risk actually sits after adopting the tool

The architecture above closes the obvious third-party leakage paths. The
surfaces that remain a solicitor's responsibility:

- **The machine the tool runs on.** Shared workstations, family laptops,
  cloud-synced folders (iCloud Drive, OneDrive, Dropbox) all expand the
  exposure surface of locally-stored material. The tool can only ensure
  it doesn't *itself* propagate the data.
- **Exported JSON snapshots.** Even encrypted, these are client-information
  artefacts that need to be stored on a controlled device.
- **Generated `.docx` outputs.** They land in the user's downloads folder.
  Where they go next is the user's responsibility.
- **Browser extensions.** A malicious or compromised browser extension
  can read the same `localStorage` and IndexedDB the tool uses. The tool
  cannot defend against an attacker who already controls the user's
  browser.

## Professional indemnity insurance

Solicitors should confirm with their professional indemnity insurer that
use of an unverified, open-source document-assembly tool sits inside
their cover. The MIT licence's "as-is" disclaimer and the absence of any
vendor warranty are usual considerations.

## See also

- [`PRIVACY.md`](./PRIVACY.md) — full privacy posture.
- [`DISCLAIMER.md`](./DISCLAIMER.md) — what the tool is and is not.
- [`SECURITY.md`](./SECURITY.md) — how to report a security issue.
