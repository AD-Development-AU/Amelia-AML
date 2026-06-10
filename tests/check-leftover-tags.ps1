# Template-tag reconciliation check.
#
# Walks a generated .docx (or a folder of them) and reports any leftover
# {placeholder} strings in the document body or footers. A clean run is
# required before release — any leftover tag means a wizard field is not
# being passed to docxtemplater, or a template is using a tag the wizard
# does not produce.
#
# Usage:
#   .\tests\check-leftover-tags.ps1 -Path <file-or-folder>
#
# Examples:
#   .\tests\check-leftover-tags.ps1 -Path .\generated-output\policy-document.docx
#   .\tests\check-leftover-tags.ps1 -Path .\generated-output\
#
# Exit code 0 if no leftover tags; 1 otherwise.

param(
    [Parameter(Mandatory = $true)]
    [string]$Path
)

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-DocxTextParts {
    param([string]$DocxPath)
    $zip = [System.IO.Compression.ZipFile]::OpenRead($DocxPath)
    try {
        $parts = New-Object System.Collections.Generic.List[hashtable]
        foreach ($entry in $zip.Entries) {
            $name = $entry.FullName
            if ($name -eq "word/document.xml" -or $name -like "word/footer*.xml" -or $name -like "word/header*.xml") {
                $stream = $entry.Open()
                $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
                $xml = $reader.ReadToEnd()
                $reader.Close()
                $parts.Add(@{ Name = $name; Xml = $xml })
            }
        }
        return $parts
    } finally {
        $zip.Dispose()
    }
}

function Test-DocxForLeftoverTags {
    param([string]$DocxPath)
    $issues = New-Object System.Collections.Generic.List[string]
    $parts = Get-DocxTextParts -DocxPath $DocxPath
    foreach ($part in $parts) {
        # Strip XML tags so we are matching against the visible text only.
        # docxtemplater may split a {tag} across multiple <w:t> runs in Word's
        # native XML, so we look at the joined visible-text form.
        $visible = [regex]::Replace($part.Xml, '<[^>]+>', '')
        # Look for {word} or {#word} or {/word} or {^word} patterns. These
        # are the four Mustache shapes the bundled docxtemplater recognises.
        $regex = '\{[#/^]?[A-Za-z_][A-Za-z0-9_\.]*\}'
        $matches = [regex]::Matches($visible, $regex)
        if ($matches.Count -gt 0) {
            $samples = ($matches | Select-Object -First 5 | ForEach-Object { $_.Value }) -join ", "
            $issues.Add("$($part.Name): $($matches.Count) leftover tag(s) including $samples")
        }
        # Also flag literal "undefined" and "[object Object]" which mean a
        # binding went wrong upstream of docxtemplater.
        if ($visible -match '\bundefined\b') {
            $issues.Add("$($part.Name): contains literal 'undefined' — binding issue")
        }
        if ($visible -match '\[object Object\]') {
            $issues.Add("$($part.Name): contains '[object Object]' — binding issue")
        }
    }
    return $issues
}

# Resolve input as file or folder
if (-not (Test-Path $Path)) {
    Write-Error "Path not found: $Path"
    exit 2
}

$files = @()
if ((Get-Item $Path).PSIsContainer) {
    $files = Get-ChildItem -Path $Path -Filter *.docx -Recurse
} else {
    $files = @(Get-Item $Path)
}

if ($files.Count -eq 0) {
    Write-Host "No .docx files found at $Path"
    exit 0
}

$totalIssues = 0
foreach ($file in $files) {
    Write-Host "Checking: $($file.Name)"
    $issues = Test-DocxForLeftoverTags -DocxPath $file.FullName
    if ($issues.Count -eq 0) {
        Write-Host "  OK — no leftover tags"
    } else {
        foreach ($issue in $issues) {
            Write-Host "  ISSUE: $issue" -ForegroundColor Red
        }
        $totalIssues += $issues.Count
    }
}

Write-Host ""
if ($totalIssues -eq 0) {
    Write-Host "All clean. No leftover tags across $($files.Count) file(s)."
    exit 0
} else {
    Write-Host "$totalIssues issue(s) across $($files.Count) file(s)." -ForegroundColor Red
    exit 1
}
