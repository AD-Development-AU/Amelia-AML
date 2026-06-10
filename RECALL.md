# OSS recall and broadcast plan

This document records how users of an open-source AML/CTF compliance tool
get told when something has gone wrong, and how the tool maintains currency
against the law and AUSTRAC's published materials. It exists because an OSS
tool has no user list and no telemetry — the maintainer has no way to push
a hotfix or email a warning — so reaching users requires a deliberate
broadcast strategy.

## Channels

A four-channel approach, in order of preference:

1. **GitHub Security Advisories (GHSA).** Primary channel for any issue
   that could affect a deployed copy: stored-XSS in an import path,
   template-injection vector, dependency vulnerability, etc. Users
   watching the repo for security advisories will be notified by GitHub.

2. **GitHub Discussions "Announcements" category (RSS).** Non-security
   but consequential news: regulatory-content updates, bundled-template
   re-verifications, breaking changes. RSS-able for users who subscribe
   to the feed.

3. **In-app Step 10 banner.** When AUSTRAC's published document library
   has been updated since the kit's last verification, an amber banner
   appears at the top of Step 10 (Documents). The maintainer triggers
   this by setting `AUSTRAC_LIBRARY_OBSERVED_UPDATE` to the observed
   date in source and shipping a release. The banner is the only channel
   that reaches every active user regardless of repo-watch state.

4. **Voluntary, opt-in, Australia-only mailing list.** For users who
   want push notifications. The first three channels carry the full
   content; the list is optional. See "Mailing list" below.

## Severity and response time

| Severity | Examples | Channels | Target time |
|---|---|---|---|
| Critical | Stored XSS exploitable from a malicious snapshot; bundled-template vulnerability that ships in generated `.docx`; supply-chain compromise of a vendored library | GHSA + Discussions + in-app banner + mailing list | 24 hours of confirmation |
| High | Regulatory-content drift requiring a content-only release; non-exploitable XSS sink; AUSTRAC library update that supersedes bundled templates | GHSA (if security-relevant) + Discussions + in-app banner + mailing list | 7 days |
| Medium | Documentation contradictions; dependency advisories not affecting the OSS code path; deprecated configuration | Discussions + release notes | Next release cycle |
| Low | Cosmetic, typo, internal refactor | Release notes only | Next release |

## Quarterly AUSTRAC verification process

Every quarter, the maintainer:

1. Opens [AUSTRAC's document library page](https://www.austrac.gov.au/industry-and-business/obligations-and-guidance/program-starter-kits/legal-profession-program-starter-kit/legal-profession-program-starter-kit-document-library).
2. Compares the page's last-updated date against the source-code constant
   `AUSTRAC_LIBRARY_VERIFIED_AS_AT`.
3. **If unchanged:** bump `AUSTRAC_LIBRARY_VERIFIED_AS_AT` to today; if also
   re-verified against the AML/CTF Act 2006 and Rules 2025, bump
   `CONTENT_VERSION.asAt` to today. Ship a content-only release.
4. **If changed**, one of two paths:
   - **(a) Re-verify and ship.** Compare AUSTRAC's new versions against the
     bundled `.docx` files. If they match, bump the constants as in step 3.
     If they differ, refresh `vendor/templates/`, update
     [`VERIFIED.md`](./VERIFIED.md) with new filenames and source URLs,
     bump `AUSTRAC_KIT_RELEASE` if appropriate, ship the release.
   - **(b) Flag-only release.** If a full re-verify can't be done
     immediately, ship a release that just sets
     `AUSTRAC_LIBRARY_OBSERVED_UPDATE` to the observation date. The Step 10
     banner lights up so users know to consult AUSTRAC's canonical source
     before relying on the kit's outputs.

The quarterly cadence is a minimum, not a maximum — material AUSTRAC
updates between cycles should trigger an out-of-cycle release.

## Mailing list (optional)

A voluntary, opt-in mailing list is available for users who want push
notifications of security advisories and regulatory-content updates. The
first three channels carry the full content; the list is a convenience.

**Conditions of the list:**

- **Australia-only by self-declaration.** Signup requires a tick-box
  ("I confirm I am physically located in Australia at the time of
  subscribing"). Geolocation is not enforced technically — VPN users
  and travellers would defeat it — so enforcement is by attestation, and
  that limitation is disclosed in the signup notice. The list collects
  email address + signup timestamp + signup IP (for breach forensics).

- **APP 5 collection notice at signup**, covering:
  - Identity of the entity collecting the information.
  - Purpose: security advisories and AUSTRAC content-update notices only.
  - How to access, correct, and unsubscribe.
  - Explicit no-commercial-use undertaking.

- **AU-resident hosting.** Self-hosted Listmonk on an AU-region VPS (AWS
  Sydney, DigitalOcean Sydney, Vultr Sydney) is the cleanest path. A SaaS
  list hosted outside Australia would trigger APP 8 cross-border disclosure
  obligations in the collection notice; doable but adds policy text.

- **Spam Act 2003 position.** As long as the list stays genuinely
  non-commercial (free OSS, no paid tier, advisories only), the Act
  arguably does not bind. The list operates as if it did anyway: sender
  identified, functional unsubscribe within five business days, consent
  recorded with each subscriber.

The mailing list **is not** part of the v0.2.0 launch artefact. It is a
deferred deliverable — to be stood up only if the GHSA / Discussions /
in-app channels prove insufficient in practice.

## Anti-impersonation / canonical source

A user who downloads a single-file copy of this tool must be able to
verify the file is the genuine maintainer's release rather than a hostile
fork that has been backdoored. The canonical source is the
maintainer-controlled GitHub releases page; per-release SHA-256 checksums
are recorded in [`VERIFIED.md`](./VERIFIED.md). Signed release tags close
the remaining gap (release-engineering work item).

## See also

- [`SECURITY.md`](./SECURITY.md) — vulnerability disclosure policy.
- [`PRIVACY.md`](./PRIVACY.md) — what data the tool itself handles.
- [`VERIFIED.md`](./VERIFIED.md) — per-template provenance and verification status.
