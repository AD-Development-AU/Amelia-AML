# Security policy

## Supported versions

The latest tagged release on `main` is the only supported version. There is no
backporting policy at this stage of the project (v0.x).

## Reporting a vulnerability

If you have found a security issue — for example, a way to make the wizard
exfiltrate data, a DOCX rendering path that executes attacker-controlled
content, a supply-chain concern with a vendored library, or a way to bypass the
local-only data promise — please report it privately first.

**Preferred — GitHub Security Advisory:** open a private advisory at the
repository's *Security* tab. This is the fastest route and keeps the
disclosure private until a fix ships.

**Email:** if GHSA is not available to you, write to
`ameliaaml@mailfence.com`. Use the subject prefix `[aml-starter-kit security]`.
PGP key is published alongside the maintainer's GitHub profile if you
need encrypted transport.

Please include:

- A description of the issue and the impact you observed.
- Steps to reproduce, ideally with a minimal example.
- The version (`TOOL_VERSION` constant in `aml-starter-kit-v{version}.html`,
  visible in the small mono text under the page header) and browser used.
- Any proof-of-concept code or DOCX template that triggers the issue.

## Response

We aim to:

- Acknowledge the report within 7 days.
- Confirm or dispute the issue within 14 days.
- Ship a fix or document a workaround within 30 days for confirmed issues.

This is a volunteer-maintained project; timelines are best-effort.

## Public disclosure

Once a fix is available (or 90 days have elapsed, whichever is sooner), the
issue may be disclosed publicly. Reporters are credited unless they prefer
otherwise.

## Out of scope

The following are not security issues for this project:

- Issues affecting only the user's own browser security posture (e.g. running
  on an end-of-life browser).
- Issues in third-party services the tool intentionally does not use (the tool
  is local-only and makes no network requests in normal operation).
- Issues caused by a fork that has modified the codebase.
- Lack of features that would require server-side infrastructure.

## Supply chain

Vendored JavaScript libraries are listed with SHA-256 hashes in
[`VENDOR.md`](./VENDOR.md) and as components in [`sbom.cdx.json`](./sbom.cdx.json)
(CycloneDX 1.5). If your local copy's hashes don't match, treat the
copy as untrusted. Per-release artefact checksums are recorded in
[`VERIFIED.md`](./VERIFIED.md); signed release tags are the trust anchor.

## See also

- [`PRIVACY.md`](./PRIVACY.md) — privacy posture in full.
- [`LPP.md`](./LPP.md) — solicitor confidentiality posture.
- [`RECALL.md`](./RECALL.md) — how OSS users are notified of issues.
- [`EGRESS_AUDIT.md`](./EGRESS_AUDIT.md) — network-egress audit procedure.
