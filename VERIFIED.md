# Verification status

This file records what has been verified against the live AUSTRAC Legal
profession program starter kit document library, and what has not.

**Last verification attempt:** 2026-05-29
**AUSTRAC release modelled on:** January 2026

## Verified — confirmed against AUSTRAC sources or filename pattern

| Catalogue id | Source of verification |
|---|---|
| `customise-guide` | AUSTRAC starter kit overview page |
| `policy-document` | AUSTRAC document library — `Legal profession - Policy document - January 2026.docx` (URL confirmed) |
| `process-document` | AUSTRAC document library |
| `ra-conveyancing` | AUSTRAC document library URL confirmed |
| `ra-other-prof-services` | AUSTRAC document library URL confirmed |
| `pdd-compliance-officer` | AUSTRAC filename confirmed |
| `unusual-activity-review` | AUSTRAC filename confirmed |

## Extrapolated — title pattern inferred from parallel Accountants/Conveyancers kits

These catalogue entries follow the same filename pattern AUSTRAC uses for the
sister Accountants and Conveyancers starter kits (which were directly
accessible at the time of writing). The legal-kit equivalents almost certainly
exist with "Legal profession" substituted, but the titles below should be
re-verified against the live library when it loads reliably.

| Catalogue id | Notes |
|---|---|
| `assign-responsibilities` | Confirmed in Accountants kit |
| `pdd-co-equals-governing-body` | Confirmed in Accountants kit |
| `pdd-general-staff` | Pattern only |
| `training-records` | Pattern only |
| `final-onboarding-checks` | Pattern only — referenced in AUSTRAC Step 2 prose |
| `escalation-form` | Pattern only — referenced in AUSTRAC policy doc |
| `trigger-event-review` | Confirmed in Accountants kit |
| `ongoing-cdd-monitoring` | Pattern only |
| `reportable-matter-working` | Pattern only |
| `effectiveness-onboarding` | Confirmed in Accountants kit |
| `effectiveness-ttr` | Confirmed in Accountants kit |
| `effectiveness-cdd` | Pattern only |
| `effectiveness-ongoing-monitoring` | Pattern only |
| `effectiveness-smr` | Pattern only |
| `effectiveness-ifti` | Pattern only |
| `effectiveness-training` | Pattern only |
| `effectiveness-recordkeeping` | Pattern only |
| `effectiveness-governance` | Pattern only |
| `independent-evaluation-checklist` | Pattern only |
| All 16 `onboarding-{conv,other}-*` and `initial-cdd-{conv,other}-*` entries | Pattern only — AUSTRAC splits forms by service line × customer type |

## Defaults requiring re-verification on Rules amendment

These values are baked into the wizard as defaults. They should be re-checked
on every AML/CTF Rules amendment.

| Default | Value | Source |
|---|---|---|
| Beneficial-owner threshold | 25% | AML/CTF Rules 2025 |
| SMR window — terrorism financing | Within 24 hours | AML/CTF Act 2006 |
| SMR window — other suspicions | Within 3 business days | AML/CTF Act 2006 |
| TTR window | Within 10 business days | AML/CTF Act 2006 |
| IFTI window | Within 10 business days | AML/CTF Act 2006 |
| TTR threshold | A$10,000 in physical currency | AML/CTF Act 2006 |
| Record retention | 7 years | AML/CTF Rules 2025 |
| Compliance Officer appointment window | 28 days from first designated service | AML/CTF Rules 2025 |
| AUSTRAC CO notification window | 14 days from appointment | AML/CTF Rules 2025 |
| Compliance Officer reporting cadence | At least every 12 months | AML/CTF Rules 2025 |
| Independent evaluation cadence | At least every 3 years | AML/CTF Rules 2025 |
| First independent evaluation deadline window | 30 June 2029 – 30 June 2030 | Transitional Rules 2025 |
| Tranche 2 commencement | 1 July 2026 | AML/CTF Amendment Act 2024 |

## How to contribute verification

1. Open the AUSTRAC document library URL listed in `README.md`.
2. For each catalogue entry in the table above, confirm the exact title and
   record the AUSTRAC URL where it appears.
3. Update `DOCUMENT_CATALOGUE` in `index.html` with the verified title.
4. Move the catalogue id from "Extrapolated" to "Verified" in this file.
5. Open a PR with both changes.
