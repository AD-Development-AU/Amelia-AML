# Optimise AUSTRAC .docx files for inline embedding.
#
# A .docx is a ZIP of XML files. Word auto-generates revision-tracking
# attributes (w:rsidR, w14:paraId, etc.) on virtually every paragraph, run,
# and section — they help Word detect concurrent edits but serve no purpose
# for rendering or for this wizard's pipeline. They typically account for
# 25-45% of document.xml. Stripping them and re-zipping at maximum deflate
# typically yields 40-55% size reduction per file.
#
# Inputs:  ./templates/*.docx       (originals, untouched)
# Outputs: ./templates-optimised/*.docx
#
# Safe to re-run — attributes already stripped become no-ops.

$srcDir = $PSScriptRoot                                    # vendor/templates
$dstDir = Join-Path (Split-Path $PSScriptRoot -Parent) "templates-optimised"

if (-not (Test-Path $srcDir)) {
    Write-Error "Source folder not found: $srcDir"
    exit 1
}
if (Test-Path $dstDir) {
    Remove-Item -Recurse -Force $dstDir
}
New-Item -ItemType Directory -Path $dstDir | Out-Null

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Patterns to strip from each XML part. The leading space captures the
# attribute as a complete unit (e.g. ` w:rsidR="00ABCDEF"`).
$stripPatterns = @(
    ' w:rsidR="[^"]*"',
    ' w:rsidRPr="[^"]*"',
    ' w:rsidRDefault="[^"]*"',
    ' w:rsidP="[^"]*"',
    ' w:rsidTr="[^"]*"',
    ' w:rsidSect="[^"]*"',
    ' w:rsidDel="[^"]*"',
    ' w14:paraId="[^"]*"',
    ' w14:textId="[^"]*"',
    '<w:proofErr[^/>]*/>',
    '<w:proofState\s[^>]*/?>',
    '<w:rsids>[\s\S]*?</w:rsids>'
)

$utf8 = New-Object System.Text.UTF8Encoding -ArgumentList $false

$origTotal = 0
$newTotal  = 0
$count     = 0

Get-ChildItem -Path $srcDir -Filter *.docx | Sort-Object Name | ForEach-Object {
    $srcFile = $_.FullName
    $dstFile = Join-Path $dstDir $_.Name
    $origSize = (Get-Item $srcFile).Length
    $origTotal += $origSize
    $count++

    $srcZip = [System.IO.Compression.ZipFile]::OpenRead($srcFile)
    $dstStream = [System.IO.File]::Create($dstFile)
    $dstZip = New-Object System.IO.Compression.ZipArchive($dstStream, [System.IO.Compression.ZipArchiveMode]::Create)

    try {
        foreach ($entry in $srcZip.Entries) {
            $name = $entry.FullName
            # Read entry into a byte array (handles binary parts too)
            $ms = New-Object System.IO.MemoryStream
            $entry.Open().CopyTo($ms)
            $bytes = $ms.ToArray()
            $ms.Dispose()

            # XML / rels — strip noise from the text representation
            $isText = $name -match '\.(xml|rels)$'
            if ($isText) {
                $content = $utf8.GetString($bytes)
                foreach ($p in $stripPatterns) {
                    $content = $content -replace $p, ''
                }
                $bytes = $utf8.GetBytes($content)
            }

            # Write to destination ZIP at maximum compression
            $newEntry = $dstZip.CreateEntry($name, [System.IO.Compression.CompressionLevel]::Optimal)
            $outStream = $newEntry.Open()
            $outStream.Write($bytes, 0, $bytes.Length)
            $outStream.Close()
        }
    }
    finally {
        $dstZip.Dispose()
        $dstStream.Close()
        $srcZip.Dispose()
    }

    $newSize = (Get-Item $dstFile).Length
    $newTotal += $newSize
    $saved = if ($origSize -gt 0) { [Math]::Round(100 - ($newSize / $origSize * 100), 1) } else { 0 }
    Write-Host ("{0,-55} {1,8:N0} -> {2,8:N0}  ({3,4}% saved)" -f $_.Name, $origSize, $newSize, $saved)
}

Write-Host ""
$totalSaved = if ($origTotal -gt 0) { [Math]::Round(100 - ($newTotal / $origTotal * 100), 1) } else { 0 }
Write-Host ("Optimised $count file(s)")
Write-Host ("Total bytes  {0,12:N0}  ->  {1,12:N0}   ({2}% saved)" -f $origTotal, $newTotal, $totalSaved)
Write-Host ("Output: $dstDir")
