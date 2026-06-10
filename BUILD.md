# Building and verifying the distributable

This file documents how the shipping single-file HTML artefact is produced
and how anyone can rebuild it themselves to verify the maintainer-published
file has not been tampered with.

**Tool version:** v0.2.0
**Canonical artefact filename:** `aml-starter-kit-v0.2.0.html`

## Workflow

The maintainer edits the bundled HTML file directly
(`aml-starter-kit-v{TOOL_VERSION}.html`). When AUSTRAC publishes new
templates and `vendor/templates/` is refreshed, `_build-inline.ps1`
re-embeds them into the bundle. The build script is self-bundling — it
treats the bundle as its own source, strips the previous embedded
template block, and writes the result back to the same file (or to a
new file if `TOOL_VERSION` has been bumped).

## Two-step build pipeline

### Step 1 — `vendor/templates/_optimize.ps1`

Strips Word `rsid` and proofing-language metadata from each bundled `.docx`,
then re-zips at maximum compression. Output lands in
`vendor/templates-optimised/` (gitignored). Reduces total template bundle
size by ~20%. Only re-run when source `.docx` files in `vendor/templates/`
change.

### Step 2 — `_build-inline.ps1`

Reads:
- The bundled HTML (default `aml-starter-kit-v0.2.0.html`) — the canonical
  source.
- `vendor/templates-optimised/*.docx` (falls back to `vendor/templates/`
  if the optimised folder doesn't exist).

Produces:
- `aml-starter-kit-v{TOOL_VERSION}.html` — the bundled single-file artefact,
  with every template base64-embedded in an inert
  `<script type="application/x-aml-template" data-doc-id="…">` block before
  `</body>`. If `TOOL_VERSION` matches the source filename, the file is
  overwritten in place. If `TOOL_VERSION` has been bumped, the new file
  is created next to the previous one.

The script's behaviour is **idempotent** — strip-and-re-embed of the same
templates produces the same output, so accidental re-runs are safe.

The version is extracted from the bundle's `TOOL_VERSION` constant (with
a fallback to the legacy `APP_VERSION` for pre-v0.3 sources).

### Step 3 (built into Step 2) — strict CSP hash computation

After embedding templates and vendor JS, the build script computes a
SHA-256 of each executable inline `<script>` block's content (the 4
vendored libraries: pizzip, docxtemplater, jszip, mammoth; plus the
wizard script extracted between `<!-- AML-WIZARD-SCRIPT-START -->` /
`END` markers) and writes them into the
`<meta http-equiv="Content-Security-Policy">` tag as
`script-src 'self' 'sha256-…' …`. The hashes are recomputed on every
build so they stay in sync with the wizard code as it evolves. Without
this step the strict CSP would reject the inline scripts and the wizard
would not run.

## Reproducible build (when the pipeline is in use)

Anyone with the source repository can rebuild the artefact and verify the
hash matches the published one:

### PowerShell (Windows)

```powershell
cd path\to\amlaustrac
# Optional first step — strip Word metadata for a smaller bundle
& .\vendor\templates\_optimize.ps1

# Build (re-embeds templates into the bundled HTML in place)
& .\_build-inline.ps1

# Verify
Get-FileHash -Algorithm SHA256 -Path .\aml-starter-kit-v0.2.0.html
```

To target a different bundle file (e.g. when working on v0.3.0):
```powershell
& .\_build-inline.ps1 -Source .\aml-starter-kit-v0.3.0.html
```

### Bash (Linux/macOS) — equivalent

A bash equivalent is not currently shipped. To rebuild on a non-Windows
system, port `_build-inline.ps1` (it is a straightforward base64-and-embed
operation):

1. Read `aml-starter-kit-v0.2.0.html` as UTF-8 (no BOM).
2. Strip any existing `<!-- AML-BUNDLED-TEMPLATES-START -->...<!-- AML-BUNDLED-TEMPLATES-END -->`
   section from the source.
3. For each `.docx` in `vendor/templates/`, base64-encode and wrap as:
   `<script type="application/x-aml-template" data-doc-id="{basename}">{base64}</script>`
4. Insert the new wrapped block (with the start/end markers) immediately
   before `</body>`.
5. Write the result back to `aml-starter-kit-v{TOOL_VERSION}.html` (UTF-8,
   no BOM).
6. Compare `shasum -a 256` of the result against the published checksum.

Cross-platform reproducibility verification is a release-engineering item
(see [`RECALL.md`](./RECALL.md)).

## Published checksums

Per-release SHA-256 checksums are recorded in [`VERIFIED.md`](./VERIFIED.md).
Signed release tags (the GPG / SSH signing key) are the trust anchor for
the published checksums — see [`SECURITY.md`](./SECURITY.md) for the
signing-key identity.

## SLSA provenance

Tagged releases (`vX.Y.Z`) trigger
[`.github/workflows/release-provenance.yml`](./.github/workflows/release-provenance.yml),
which generates a SLSA Level 3 provenance attestation via the
[`slsa-framework/slsa-github-generator`](https://github.com/slsa-framework/slsa-github-generator)
generic generator and attaches the following to the GitHub Release:

- `aml-starter-kit-v{version}.html` — the single-file artefact
- `SHA256SUMS.txt` — human-readable SHA-256 of the artefact
- `multiple.intoto.jsonl` — signed SLSA provenance attestation

A downstream user can verify the attestation with the
[slsa-verifier](https://github.com/slsa-framework/slsa-verifier):

```bash
slsa-verifier verify-artifact \
  --provenance-path multiple.intoto.jsonl \
  --source-uri github.com/<owner>/<repo> \
  --source-tag v0.2.0 \
  aml-starter-kit-v0.2.0.html
```

The maintainer runs `_build-inline.ps1` locally **before** tagging, so the
artefact present in the tagged commit is exactly what gets attested — the
workflow stages the already-built file rather than rebuilding it. This keeps
the build deterministic and lets the maintainer verify the file by hand
before publishing.

## Manifest reference

`vendor/templates/manifest.json` records the original AUSTRAC filename for
each bundled template (the `docId` used inside the kit is a normalised
catalogue identifier, not the AUSTRAC filename). When refreshing templates
against an AUSTRAC update, the manifest is the authoritative mapping.

## See also

- [`VENDOR.md`](./VENDOR.md) — vendored JavaScript libraries and their hashes.
- [`sbom.cdx.json`](./sbom.cdx.json) — CycloneDX 1.5 software bill of materials.
- [`VERIFIED.md`](./VERIFIED.md) — per-template provenance and release checksums.
- [`RECALL.md`](./RECALL.md) — release / re-verification cadence.
