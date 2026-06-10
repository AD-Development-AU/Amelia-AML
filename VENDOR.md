# Vendored libraries

The `./vendor/` directory contains third-party JavaScript libraries bundled so
this tool runs fully offline. Hashes below let you verify your local copy was
not tampered with in transit.

## Versions

| File | Package | Version | Source |
|---|---|---|---|
| `vendor/pizzip.min.js` | [pizzip](https://www.npmjs.com/package/pizzip) | 3.1.4 | `https://cdn.jsdelivr.net/npm/pizzip@3.1.4/dist/pizzip.min.js` |
| `vendor/docxtemplater.js` | [docxtemplater](https://www.npmjs.com/package/docxtemplater) | 3.37.11 | `https://cdn.jsdelivr.net/npm/docxtemplater@3.37.11/build/docxtemplater.js` |
| `vendor/jszip.min.js` | [jszip](https://www.npmjs.com/package/jszip) | 3.10.1 | `https://cdn.jsdelivr.net/npm/jszip@3.10.1/dist/jszip.min.js` |
| `vendor/mammoth.browser.min.js` | [mammoth](https://www.npmjs.com/package/mammoth) | 1.12.0 | `https://unpkg.com/mammoth@1.12.0/mammoth.browser.min.js` |

## SHA-256 checksums

```
f79ef16b242e31de9c863fb76b618dbea5d597dac04cecd890897511d36e83cd  vendor/pizzip.min.js
0647f62d024164cea566cf9615d374edf56fec9826d94ccbc3a6e011edcf26b8  vendor/docxtemplater.js
acc7e41455a80765b5fd9c7ee1b8078a6d160bbbca455aeae854de65c947d59e  vendor/jszip.min.js
5d4c0e7c9165d70b78f789c5274a2c7846d9e1c06ec19b69afa6ef45f789a3b9  vendor/mammoth.browser.min.js
```

### Verify locally

PowerShell:
```powershell
Get-FileHash -Algorithm SHA256 -Path .\vendor\*.js
```

macOS / Linux:
```bash
shasum -a 256 vendor/*.js
```

If a hash doesn't match the table above, treat your copy as untrusted: delete
`./vendor/` and re-fetch from the source URL listed in the Versions table.

## Licenses

| Library | License |
|---|---|
| PizZip | MIT |
| docxtemplater | MIT |
| JSZip | MIT or GPL-3.0 (this project uses under the MIT option) |
| mammoth | BSD-2-Clause |

Full license text is included in each library's source file and at the linked
repository. See also [`LICENSE`](./LICENSE) for the top-level project license.

## Updating

When updating a vendored library:

1. Download the new version from the source URL.
2. Re-compute SHA-256 and update this file.
3. Bump `TOOL_VERSION` in the canonical HTML if the change is user-visible.
4. Regenerate [`sbom.cdx.json`](./sbom.cdx.json) with the new version,
   source URL, and hash.
5. Note the change in the commit message — supply-chain integrity matters.
