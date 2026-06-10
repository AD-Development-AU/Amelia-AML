# Glossary of defined terms

This glossary records the load-bearing defined terms from the AML/CTF Act 2006
(Cth) and AUSTRAC's published guidance, and notes how the wizard uses each
one. The goal is *terminological conformance* — using the Act's exact defined
terms rather than near-synonyms — so that generated documents read as the
regulator's drafting reads, and so a user searching for an Act term lands on
the same words in the tool.

**Last reviewed:** 2026-06-09
**Scope of this review:** the high-impact terms below. A line-by-line audit
of every UI string against the Act's defined terms is a deferred work item.

## Core terms

| Term | Authority | How the wizard uses it |
|---|---|---|
| **designated service** | AML/CTF Act s 6(5B) — Table 6 (legal profession items 1–9) | Step 5 ("Designated services") is named for, and uses, this term throughout. Catalogue logic treats "real estate / conveyancing" and "other professional services" as the two branches of designated-service capture per Table 6. |
| **reporting entity** | AML/CTF Act s 5 (definition) | The wizard refers to the practice as a *reporting entity* when an obligation flows from that capacity (enrolment, AML/CTF program, reporting). Avoid "your firm" / "your business" in obligation copy where "reporting entity" is the operative term. |
| **customer** | AML/CTF Act s 5 | Used consistently for the person to whom the designated service is provided. Avoid "client" in CDD copy — Australian law uses "customer" specifically. |
| **AML/CTF program** | AML/CTF Act Part 7 | The artefact the tool helps produce. Use the full term — not "compliance program" or "AML program" alone — when referring to the Part 7 obligation. |
| **AML/CTF Compliance Officer** | AML/CTF Rules 2025 | The named role at the practice. Always include "AML/CTF" prefix — "Compliance Officer" alone is ambiguous in firms with broader compliance roles. |
| **customer due diligence (CDD)** | AML/CTF Act Part 2 | Step 7 uses "CDD" with the long form on first use per page. Sub-types — initial CDD, simplified CDD, enhanced CDD, ongoing CDD — each carry their own Act definition. |
| **enhanced customer due diligence (EDD)** | AML/CTF Act s 36 + Rules | Used when the wizard refers to the higher-risk customer treatment. Don't say "enhanced CDD" when the substantive obligation is EDD; the wizard treats them as distinct. |
| **ML/TF/PF risk** | AML/CTF Act Part 2; AUSTRAC guidance on proliferation financing | The full triple — money-laundering, terrorism-financing, and proliferation-financing risk — is what the program must address. Step 6 enumerates all three. PF in particular is new in the 2024 reforms; don't use "ML/TF" alone where PF is also captured. |
| **politically exposed person (PEP)** | AML/CTF Rules 2025 | Capture foreign / domestic / international-organisation PEPs as distinct categories per the Rules' definition; not collapsed into a single "PEP yes/no" field. |
| **suspicious matter report (SMR)** | AML/CTF Act s 41 | Always the full term on first use per page. SMR-related artefacts have their own confidentiality posture — see LPP.md. |
| **threshold transaction report (TTR)** | AML/CTF Act s 43 | A$10,000 physical-currency reporting threshold. Don't shorthand to "cash report". |
| **international funds transfer instruction (IFTI)** | AML/CTF Act s 45 | Only relevant when the practice sends/receives international funds-transfer instructions; the wizard conditions this on a yes/no input. |
| **beneficial owner** | AML/CTF Act s 5 + Rules | 25% threshold is a working AUSTRAC-guidance threshold, not a Rules-codified hard line. The wizard surfaces this as a working threshold with risk-based discretion. |
| **source of funds** / **source of wealth** | AML/CTF Rules 2025 | Distinct concepts. Source of funds = the specific funds for a transaction; source of wealth = the customer's overall financial position. Don't conflate. |
| **tipping off** | AML/CTF Act s 123 | The specific offence. Always reference s 123 when warning about it; "don't tell the customer" is the lay version but the legal hook is s 123. |
| **independent evaluation** | AML/CTF Act Part 7, Rules | Three-yearly review of the AML/CTF program. Not "audit" — the Act uses "independent evaluation". |
| **enrolment** | AML/CTF Act + AUSTRAC Online | The act of being on AUSTRAC's reporting-entity roll. Use "enrol with AUSTRAC" not "register with AUSTRAC" — AUSTRAC's own copy is "enrol". |

## Status flags the wizard uses with care

| Wizard term | Why it is worded the way it is |
|---|---|
| "Your answers indicate the AUSTRAC suitability criteria are satisfied" | Not "the kit is suitable" — the kit's suitability is the user's determination, not the tool's. The wizard reports the input state; the user decides. |
| "Likely suitable" (pill) | Softens the badge text so the visual cue is "the inputs look right" rather than "you are compliant". |
| "Verify before relying" | Recurring qualifier on any wizard output. The tool is an aid; the user is responsible for verification. |
| "Modelled on AUSTRAC's January 2026 release" | Not "AUSTRAC-approved" or "AUSTRAC-endorsed". AUSTRAC has not endorsed this tool. |
| "Not approved by AUSTRAC" | The active footer-disclaimer wording — stronger than "Not affiliated with AUSTRAC", which is the older copy. "Not approved" matches the regulator's own neutrality stance. |

## Phrases the wizard avoids

| Avoid | Use instead |
|---|---|
| "Compliant" / "non-compliant" as a tool determination | "Your answers indicate X may be satisfied" / "may not be fully satisfied" |
| "Client" in CDD copy | "Customer" |
| "AML program" alone | "AML/CTF program" |
| "Money-laundering and terrorism-financing risk" | "ML/TF/PF risk" (include proliferation financing) |
| "Registered with AUSTRAC" | "Enrolled with AUSTRAC" |
| "Audit" (of the program) | "Independent evaluation" |
| "Compliance Officer" alone | "AML/CTF Compliance Officer" |

## Deferred work

A line-by-line conformance audit of every UI string and every bundled
template paragraph against this glossary remains outstanding. The
immediate Finding 5 fix in [Item 6 task] ("Kit appears suitable" →
cautious framing) closed the most severe determinative-language issue,
but other near-synonyms likely remain across the wizard's narrative copy.

## See also

- [AML/CTF Act 2006](https://www.legislation.gov.au/Series/C2006A00169)
- [AML/CTF Rules 2025](https://www.legislation.gov.au/F2025L01026/latest/text)
- [`DISCLAIMER.md`](./DISCLAIMER.md)
- [`PRIVACY.md`](./PRIVACY.md)
- [`LPP.md`](./LPP.md)
