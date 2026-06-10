# Build the single-file distributable HTML.
#
# Self-bundling: reads the canonical bundle (default
# aml-starter-kit-v0.2.0.html), strips its existing template-script section,
# re-embeds fresh templates from vendor/templates-optimised/*.docx (falls back
# to vendor/templates/ if no optimised folder exists), and writes the result
# back to aml-starter-kit-v{TOOL_VERSION}.html. If the version constant has
# not changed since the previous build, the source file is overwritten in
# place; if TOOL_VERSION has been bumped, a new release file is produced
# next to the previous one.
#
# Re-run whenever templates in vendor/templates/ change. The HTML itself
# is edited directly in the bundle file - there is no separate "source"
# HTML to maintain.
#
# Idempotent: the strip+embed transformation produces the same result for
# the same inputs, so accidental re-runs are safe.

param(
    [string]$Source    = "aml-starter-kit-v0.2.0.html",
    [string]$Templates = "vendor\templates-optimised",
    [string]$Output    = $null,
    [switch]$KeepFilename
)

$root        = $PSScriptRoot
$sourcePath  = Join-Path $root $Source
$templatePath = Join-Path $root $Templates

if (-not (Test-Path $sourcePath)) {
    Write-Error "Source HTML not found: $sourcePath"
    exit 1
}

# Fall back to non-optimised templates if optimised folder doesn't exist.
if (-not (Test-Path $templatePath)) {
    $fallback = Join-Path $root "vendor\templates"
    if (Test-Path $fallback) {
        Write-Host "Note: optimised templates not found - using $fallback"
        Write-Host "      (run vendor\templates\_optimize.ps1 first for a smaller bundle)"
        $templatePath = $fallback
    } else {
        Write-Error "Templates folder not found at $templatePath or $fallback"
        exit 1
    }
}

# Read the source HTML.
$utf8NoBOM = New-Object System.Text.UTF8Encoding -ArgumentList $false
$html = [System.IO.File]::ReadAllText($sourcePath, $utf8NoBOM)

# Extract version from TOOL_VERSION constant via plain string search.
# Falls back to APP_VERSION for backward compat with pre-v0.3 sources.
# Plain string search avoids PS 5.1 parser quirks with bracketed regex literals.
$version = "unknown"
$dq = [char]34
foreach ($constName in @('TOOL_VERSION', 'APP_VERSION')) {
    $marker = 'const ' + $constName + ' = ' + $dq
    $markerIdx = $html.IndexOf($marker)
    if ($markerIdx -ge 0) {
        $vStart = $markerIdx + $marker.Length
        $vEnd = $html.IndexOf([char]34, $vStart)
        if ($vEnd -gt $vStart) {
            $version = $html.Substring($vStart, $vEnd - $vStart)
            break
        }
    }
}

# Auto-generate output filename if not specified.
if (-not $Output) {
    if ($KeepFilename) {
        $Output = [System.IO.Path]::GetFileNameWithoutExtension($Source) + "-bundled.html"
    } else {
        $Output = "aml-starter-kit-v$version.html"
    }
}
$outputPath = Join-Path $root $Output

Write-Host "Source     : $sourcePath"
Write-Host "Templates  : $templatePath"
Write-Host "Version    : $version"
Write-Host "Output     : $outputPath"
Write-Host ""

# === Vendor JS embedding ===
# pizzip / docxtemplater / jszip are inlined as executable <script>...</script>
# blocks so they run before the main inline script. Mammoth (700KB) is
# inlined as an inert base64 block and decoded on demand by loadMammoth() to
# avoid the parse cost on every page load.
$vendorRoot = Join-Path $root "vendor"

function Read-VendorFile {
    param([string]$VendorPath)
    if (-not (Test-Path $VendorPath)) {
        Write-Error "Vendor file not found: $VendorPath"
        exit 1
    }
    $bytes = [System.IO.File]::ReadAllBytes($VendorPath)
    return @{
        Bytes  = $bytes
        Text   = [System.Text.Encoding]::UTF8.GetString($bytes)
        Base64 = [System.Convert]::ToBase64String($bytes)
        Size   = $bytes.Length
    }
}

$eagerVendors = @(
    @{ Name = "pizzip";        File = "pizzip.min.js" },
    @{ Name = "docxtemplater"; File = "docxtemplater.js" },
    @{ Name = "jszip";         File = "jszip.min.js" },
    @{ Name = "mammoth";       File = "mammoth.browser.min.js" }
)

$vendorScriptBlocks = New-Object System.Collections.Generic.List[string]
# Also track each block's INNER content (between <script> and </script>) so we
# can hash it for the CSP step without rescanning the final HTML — vendor JS
# sources contain literal `<script>` substrings that would confuse a regex.
$vendorScriptInner = New-Object System.Collections.Generic.List[string]
$totalVendorBytes = 0
foreach ($v in $eagerVendors) {
    $vfile = Read-VendorFile (Join-Path $vendorRoot $v.File)
    # Replace </script> inside the content with <\/script> so the wrapping
    # <script> tag is not prematurely closed. Min'd JS shouldn't contain it
    # but defence-in-depth.
    $safeText = $vfile.Text.Replace("</script>", "<\/script>")
    $inner = '/* ' + $v.Name + ' */' + "`n" + $safeText + "`n"
    $vendorScriptBlocks.Add('<script>' + $inner + '</script>')
    $vendorScriptInner.Add($inner)
    $totalVendorBytes += $vfile.Size
    Write-Host ("  inline {0,-32} {1,10:N0} bytes" -f $v.File, $vfile.Size)
}

Write-Host ""

# Build the script blocks. Plain base64, no whitespace inside - whitespace
# inflates size and is unnecessary for atob() decoding.
$blocks = New-Object System.Collections.Generic.List[string]
$totalTemplateBytes = 0
$count = 0

Get-ChildItem -Path $templatePath -Filter *.docx | Sort-Object Name | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $docId = $_.BaseName
    $blocks.Add('<script type="application/x-aml-template" data-doc-id="' + $docId + '">' + $base64 + '</script>')
    $totalTemplateBytes += $bytes.Length
    $count++
    Write-Host ("  embed {0,-50} {1,8:N0} bytes" -f $_.Name, $bytes.Length)
}

if ($count -eq 0) {
    Write-Error "No .docx files found in $templatePath"
    exit 1
}

# Insert before closing body tag. Use a marker comment so subsequent rebuilds
# can strip the previous section cleanly if we ever re-process a bundled file.
$startMarker = "<!-- AML-BUNDLED-TEMPLATES-START (auto-generated by _build-inline.ps1) -->"
$endMarker   = "<!-- AML-BUNDLED-TEMPLATES-END -->"
$nl = "`n"
$embedSection = $nl + $startMarker + $nl + ($blocks -join $nl) + $nl + $endMarker + $nl

# If the source already contains a previous bundle, remove it before inserting.
$stripPattern = '(?s)[\r\n]*' + [regex]::Escape($startMarker) + '.*?' + [regex]::Escape($endMarker) + '[\r\n]*'
$html = [regex]::Replace($html, $stripPattern, $nl)

# === Replace vendor marker block in place (head section) ===
# Mammoth is now one of the eager vendor scripts (was previously kept in an
# inert base64 block + decoded at runtime, but that strategy is incompatible
# with strict CSP — dynamic-script injection has no hash to match).
$vendorJsStart = "<!-- AML-BUNDLED-VENDOR-JS-START (auto-replaced by _build-inline.ps1) -->"
$vendorJsEnd   = "<!-- AML-BUNDLED-VENDOR-JS-END -->"

if (-not ($html.Contains($vendorJsStart))) {
    Write-Error "Source HTML missing vendor-JS marker block. Re-add the <!-- AML-BUNDLED-VENDOR-JS-START --> ... <!-- AML-BUNDLED-VENDOR-JS-END --> markers in the source."
    exit 1
}

$vendorJsSection = $vendorJsStart + $nl + ($vendorScriptBlocks -join $nl) + $nl + $vendorJsEnd

# Plain-string replace (NOT [regex]::Replace) — vendor JS source contains
# literal `$_`, `$&`, `${name}` etc. which .NET regex replacement strings
# interpret as backreferences and "entire input" expansions. That bug
# caused a ~316 MB self-referential explosion previously.
$vendorJsStartIdx = $html.IndexOf($vendorJsStart)
$vendorJsEndIdx   = $html.IndexOf($vendorJsEnd, $vendorJsStartIdx + $vendorJsStart.Length)
if ($vendorJsStartIdx -lt 0 -or $vendorJsEndIdx -lt 0) {
    Write-Error "Vendor-JS marker block boundaries not found."
    exit 1
}
$vendorJsEndIdx += $vendorJsEnd.Length
$html = $html.Substring(0, $vendorJsStartIdx) + $vendorJsSection + $html.Substring($vendorJsEndIdx)

# Strip the legacy AML-BUNDLED-VENDOR-MAMMOTH marker block from old source HTMLs.
# It no longer holds anything since mammoth is now eagerly inlined above.
$vendorMmStart = "<!-- AML-BUNDLED-VENDOR-MAMMOTH-START (auto-generated by _build-inline.ps1) -->"
$vendorMmEnd   = "<!-- AML-BUNDLED-VENDOR-MAMMOTH-END -->"
if ($html.Contains($vendorMmStart)) {
    $vendorMmPattern = '(?s)\s*' + [regex]::Escape($vendorMmStart) + '.*?' + [regex]::Escape($vendorMmEnd) + '\s*'
    $html = [regex]::Replace($html, $vendorMmPattern, $nl)
}

# Inject template block before closing body tag.
$bundled = $html -replace '</body>', ($embedSection + '</body>')

# === Recompute CSP script hashes ===
# After all substitutions, each <script>...</script> block (executable JS;
# no type attribute) gets a sha256-base64 entry in script-src so the CSP can
# stay strict (no 'unsafe-inline'). The inert template/vendor-mammoth blocks
# have type="application/x-aml-template" / "application/x-aml-vendor" so the
# browser does not execute them; CSP does not apply.
$cspStart = "<!-- AML-BUNDLED-CSP-START (auto-replaced by _build-inline.ps1) -->"
$cspEnd   = "<!-- AML-BUNDLED-CSP-END -->"
if (-not $bundled.Contains($cspStart)) {
    Write-Error "Source HTML missing CSP marker block. Re-add the <!-- AML-BUNDLED-CSP-START --> ... <!-- AML-BUNDLED-CSP-END --> markers in the source."
    exit 1
}

# Compute hashes from known content rather than re-scanning the final HTML.
# A regex like <script>([\s\S]*?)</script> over-matches because vendor JS
# sources contain literal `<script>` substrings inside string literals;
# we'd produce hundreds of bogus hashes. Instead, hash each vendor block's
# tracked inner content + the wizard script extracted between its markers.
$wizardStart = "<!-- AML-WIZARD-SCRIPT-START -->"
$wizardEnd   = "<!-- AML-WIZARD-SCRIPT-END -->"
$wsIdx = $bundled.IndexOf($wizardStart)
$weIdx = $bundled.IndexOf($wizardEnd, $wsIdx + $wizardStart.Length)
if ($wsIdx -lt 0 -or $weIdx -lt 0) {
    Write-Error "Wizard-script marker block boundaries not found."
    exit 1
}
$wizardBlock = $bundled.Substring($wsIdx + $wizardStart.Length, $weIdx - ($wsIdx + $wizardStart.Length))
# Strip the wrapping <script>...</script> to get the inner content
$scriptOpen = $wizardBlock.IndexOf("<script>")
$scriptClose = $wizardBlock.LastIndexOf("</script>")
if ($scriptOpen -lt 0 -or $scriptClose -lt 0) {
    Write-Error "Wizard <script> tag not found inside wizard marker block."
    exit 1
}
$wizardInner = $wizardBlock.Substring($scriptOpen + "<script>".Length, $scriptClose - ($scriptOpen + "<script>".Length))

function Get-ScriptSha {
    param([string]$content)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
    $hasher = [System.Security.Cryptography.SHA256]::Create()
    $hashBytes = $hasher.ComputeHash($bytes)
    $hasher.Dispose()
    return "'sha256-" + [Convert]::ToBase64String($hashBytes) + "'"
}

$scriptHashes = New-Object System.Collections.Generic.List[string]
foreach ($inner in $vendorScriptInner) {
    $scriptHashes.Add((Get-ScriptSha $inner))
}
$scriptHashes.Add((Get-ScriptSha $wizardInner))

$cspValue = "default-src 'self'; script-src 'self' " + ($scriptHashes -join " ") + "; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self' data:; connect-src 'self'; frame-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'"
$cspMeta = '<meta http-equiv="Content-Security-Policy" content="' + $cspValue + '" />'
$cspSection = $cspStart + $nl + "  " + $cspMeta + $nl + "  " + $cspEnd

# Plain-string Replace-Between (NOT [regex]::Replace) — defense in depth
# against `$_`-style backreference expansion in arbitrary replacement content.
$cspStartIdx = $bundled.IndexOf($cspStart)
$cspEndIdx   = $bundled.IndexOf($cspEnd, $cspStartIdx + $cspStart.Length)
$cspEndIdx  += $cspEnd.Length
$bundled = $bundled.Substring(0, $cspStartIdx) + $cspSection + $bundled.Substring($cspEndIdx)

Write-Host ("CSP                : 'sha256-...' x {0}" -f $scriptHashes.Count)

[System.IO.File]::WriteAllText($outputPath, $bundled, $utf8NoBOM)

$outSize = (Get-Item $outputPath).Length
Write-Host ""
Write-Host ("Templates embedded : {0:N0} ({1:N0} bytes raw)" -f $count, $totalTemplateBytes)
Write-Host ("Vendor libs inlined: 4 ({0:N0} bytes raw)" -f $totalVendorBytes)
Write-Host ("Bundled HTML       : {0:N0} bytes" -f $outSize)

# === Bundle the .html + Where am I.html into a release-ready ZIP ===
# v0.2.0 ships as a ZIP because the wizard's "where am I now" journey map
# is rendered via an iframe that loads `Where am I.html` from the same
# folder. Users extract the ZIP and double-click the .html inside; the
# companion is automatically picked up. Inlining the companion into the
# bundle is a v0.2.1 polish (CSP-srcdoc plumbing is non-trivial).
$companionPath = Join-Path $root "Where am I.html"
$zipPath = Join-Path $root ("aml-starter-kit-v" + $version + ".zip")
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
if (Test-Path $companionPath) {
    Compress-Archive -Path $outputPath, $companionPath -DestinationPath $zipPath -Force
    $zipSize = (Get-Item $zipPath).Length
    $zipName = Split-Path $zipPath -Leaf
    Write-Host ("Release ZIP        : {0:N0} bytes  ({1})" -f $zipSize, $zipName)
} else {
    Write-Host "WARNING: 'Where am I.html' not found in repo root - release ZIP skipped." -ForegroundColor Yellow
    Write-Host "         (Place 'Where am I.html' next to the build script and re-run.)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Ready to distribute: $Output"
Write-Host "  Recipient: download the .zip, extract, double-click the .html inside."
