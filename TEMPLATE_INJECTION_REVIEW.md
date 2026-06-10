# Template-injection safety review

A targeted review of how user-supplied data flows into the docxtemplater
binding layer. The concern is template injection: if user input is
interpreted as template syntax (Mustache tags, loops, conditionals)
rather than as data, an attacker who controls a wizard field could
re-shape the generated document or read other fields they shouldn't
be able to read.

**Reviewed against:** aml-starter-kit-v0.2.0.html, vendored docxtemplater 3.37.11
**Last reviewed:** 2026-06-09

## docxtemplater configuration

The single call site (two locations sharing identical configuration) is
in `renderDocxForPreview()` and `renderDocx()`. The configuration is:

```js
new window.docxtemplater(zip, {
  paragraphLoop: true,
  linebreaks: true,
  nullGetter: () => ""
});
```

- **No custom `parser`.** The default parser interprets `{key}` and the
  scoped variants. User data substituted into `{key}` positions is
  treated as text, not as a sub-template.
- **No custom `modules`.** The premium docxtemplater modules (loops-pro,
  image, table, etc.) that re-interpret user input in richer ways are
  not bundled.
- **`nullGetter` is constant.** Returns `""` for any missing field;
  cannot be steered by user input.

## What "data" means in this codebase

The `data` object passed to `doc.render(data)` is built by `collectData()`.
It is a flat object whose keys are the field ids registered in the wizard
schema, and whose values are either:

- strings from `<input>` / `<textarea>` elements (string-typed); or
- booleans from checkboxes; or
- derived computed values (e.g. `data.derived.isSolePractitioner`); or
- arrays of strings (e.g. `data.selectedDocuments`).

docxtemplater receives these as values to substitute into matching
`{tagname}` positions in the template's XML. Substituted values are
emitted as plain text content — docxtemplater does not re-parse the
substituted text for further `{...}` tags. So a user who types
`{practiceName}` into a free-text field will get the literal string
`{practiceName}` in the output, not a re-substitution.

## Fields a user could attempt to weaponise

The following wizard inputs accept free-text and flow into the template
binding:

- Practice name, ABN/ACN, addresses
- Governing-body members, senior manager name, AML/CTF Compliance
  Officer name and role
- Free-text narrative fields (e.g. risk-rating rationale)
- "Other" entries in checkbox groups

For each, the value is a string and lands in a `{tag}` position. There
is no path by which a free-text value can become an opening template
delimiter that docxtemplater would interpret.

## What docxtemplater does interpret

The template's own XML can contain Mustache-syntax constructs:

- `{tag}` — substitute scalar value
- `{#section}...{/section}` — section / loop (with `paragraphLoop: true`)
- `{^section}...{/section}` — inverse section
- `{>partial}` — partial (we don't use partials)

The templates that ship in `vendor/templates/` are the AUSTRAC starter-kit
documents, which contain no user-controllable Mustache syntax. User-uploaded
override templates ARE attacker-controllable, but the user who uploads a
template controls the same browser session and therefore has at least the
same access to their own wizard data — there's no privilege boundary to cross.

## Test cases

Inputs that were tried in test fixtures (each typed into the practice
name field and confirmed to land as literal text in the generated `.docx`):

| Input | Outcome |
|---|---|
| `{governingBodyMembers}` | Literal text in output; no re-substitution |
| `{#derived}...{/derived}` | Literal text; no scope re-interpretation |
| `{` (just opening brace) | Literal text |
| `{` `}` with a newline between (Word autocorrect simulation) | Literal text |
| Emoji + RTL Unicode mix | Substituted correctly without parser distress |
| 10,000-character string | Substituted correctly; no truncation, no error |

## Recommendations followed

- User data flows only as **data**, never as template tags. Confirmed.
- The default delimiters (`{` / `}`) are not user-configurable, so an
  attacker cannot change delimiters and create a new escape vector.
- No `setOptions({ parser })` override anywhere in the codebase.

## Adjacent surface deliberately out of scope

This review covers the docxtemplater data-binding layer only. Adjacent
surfaces handled in separate work:

- **Mammoth preview HTML sanitization** — sanitised via the
  `sanitizeMammothHtml()` allowlist (see #18(b)).
- **JSON snapshot import** — sanitised via `sanitizeImportedDocInstances()`
  and identifier-pattern validation (see #18(a)).
- **Import DoS caps** — 20 MB file-size cap, 200-entry zip-entry cap (see #18(c)).
- **Inline-handler XSS** — addressed architecturally by the inline-handler
  removal + strict CSP refactor (#16).

## See also

- [`SECURITY.md`](./SECURITY.md) — vulnerability disclosure policy.
- [`sbom.cdx.json`](./sbom.cdx.json) — vendored dependencies with versions and hashes.
