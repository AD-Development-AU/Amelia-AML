# Network egress audit

The tool's load-bearing privacy claim is: **nothing leaves your browser**.
This document records the audit process used to verify that claim before
each release.

**Last audited:** 2026-06-09 against aml-starter-kit-v0.2.0.html

## The claim, precisely

When a user opens the tool's HTML file (whether from disk via `file://`
or served over `http(s)` locally) and works through the wizard:

- No outbound network request carries any user data.
- No analytics, telemetry, error-reporting, or "phone-home" service is
  contacted.
- No external fonts, scripts, stylesheets, or CDN assets are loaded at
  runtime.
- No third-party tracking pixel, beacon, or `navigator.sendBeacon` call.

Legitimate `fetch()` calls in the code are restricted to **same-origin**
template loading (`vendor/templates/<id>.docx`) and only fire when the
user has opened the file via `http(s)` rather than `file://`. These
requests do not carry user data — they request a static template file
from the same origin as the tool itself.

## How to audit

Per release, before tagging:

1. Open the build in a fresh browser profile (or incognito with extensions
   disabled to remove third-party interference).
2. Open DevTools → Network tab. Tick "Preserve log". Set "Disable cache".
3. Filter the Network tab to "Fetch/XHR" and "Doc" categories.
4. Reload the page. Confirm the only requests are:
   - The HTML file itself
   - `vendor/templates/*.docx` (only if served over `http(s)`)
5. Work through the wizard end-to-end:
   - Suitability self-assessment, practice profile, governance, services,
     clients & risk, CDD, reporting, key dates
   - Select documents, attach an override template, generate outputs
   - Open document preview, edit form fields, download a generated `.docx`
   - Toggle Sensitive-matter mode on/off
   - Toggle Clear-on-close on/off
   - Export an encrypted snapshot; import it
6. Confirm the Network tab shows **zero** requests beyond the same-origin
   template fetches noted in step 4.
7. Save the DevTools HAR export to the release evidence bundle.
8. As a defence-in-depth check, run the build under a network proxy
   (Fiddler, Charles, mitmproxy) recording ALL outbound traffic. Confirm
   no surprise hosts.

## What would break the claim

The audit must be repeated whenever any of the following change:

- A new vendored library is added (could introduce a CDN call internally).
- An existing vendored library is upgraded (behaviour drift).
- New external resources are referenced (fonts, images, scripts, stylesheets).
- Code is added that calls `fetch`, `XMLHttpRequest`, `WebSocket`, `EventSource`,
  `navigator.sendBeacon`, `<img>` with an external src, `<script src>`,
  `<link rel="stylesheet">`, `@import` in CSS.
- The tool gains any AI/LLM integration.
- The tool starts loading remote content (e.g. dynamic regulatory updates).

## Defence in depth

- The bundled libraries are vendored, not loaded from a CDN — see
  [`VENDOR.md`](./VENDOR.md) and [`sbom.cdx.json`](./sbom.cdx.json).
- Each vendored library's SHA-256 is recorded so tampering is detectable.
- The Step 10 banner triggers only when the maintainer manually flips a
  source constant; there is no runtime fetch of AUSTRAC's library page.
- The Content Security Policy (release-engineering work item #16) will
  add a browser-enforced backstop: `connect-src 'self'`, no
  `unsafe-inline`, no `unsafe-eval`. Until that lands, the audit above
  is the only enforcement.

## Mammoth preview hyperlinks — downstream of the audit

The in-app document preview pane converts `.docx` content to HTML via
Mammoth. The bundled AUSTRAC templates contain ~202 hyperlinks to
AUSTRAC, FATF, DFAT, Basel Governance and similar reference sources
(see [`PRIVACY.md`](./PRIVACY.md) for the full posture). These survive
the `sanitizeMammothHtml()` allowlist with `target="_blank"
rel="noopener noreferrer"` attached.

The preview does **not** auto-fetch these URLs. They appear as standard
clickable `<a>` links in the preview panel. Clicking one opens the
target in a new tab — that click is the user's intentional action,
not silent egress by the tool. The `rel="noopener noreferrer"`
attributes prevent Referer leakage and any window-opener manipulation
by the link target.

This means: even within the audited "no network egress" boundary, a
user who clicks a hyperlink in a `.docx` preview will navigate to the
target URL in their browser. That is by design — AUSTRAC's own
cross-references to authoritative guidance work — and is consistent
with how Word would present the same links.

For threat models where even user-initiated egress is in scope, the
mitigation is to strip the bundled templates' external relationships
before generation; see the PRIVACY.md disclosure for that option.

## See also

- [`PRIVACY.md`](./PRIVACY.md) — privacy posture in full.
- [`LPP.md`](./LPP.md) — solicitor confidentiality posture.
- [`VENDOR.md`](./VENDOR.md) — vendored libraries and their SHA-256 hashes.
- [`sbom.cdx.json`](./sbom.cdx.json) — CycloneDX 1.5 software bill of materials.
