param([switch]$DryRun)

# Downloads AUSTRAC Legal profession program starter kit templates into this dir.
# Source: https://www.austrac.gov.au/sites/default/files/2026-01/
# Filenames mirror the published library naming convention.

$ProgressPreference = 'SilentlyContinue'
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

$base = 'https://www.austrac.gov.au/sites/default/files/2026-01/'
$outDir = $PSScriptRoot

# Map of catalogue id -> remote filename (without .docx). Same prefix every time.
$prefix = 'Legal profession - '
$files = @(
    @{ id = 'customise-guide';               name = 'Customise guide' }
    @{ id = 'policy-document';               name = 'Policy document' }
    @{ id = 'process-document';              name = 'Process document' }
    @{ id = 'ra-conveyancing';               name = 'Risk assessment - Conveyancing for the legal profession' }
    @{ id = 'ra-other-prof-services';        name = 'Risk assessment - Other professional services' }
    @{ id = 'assign-responsibilities';       name = 'Personnel forms - Assign responsibilities' }
    @{ id = 'pdd-compliance-officer';        name = 'Personnel forms - Personnel due diligence for AML CTF Compliance Officer' }
    @{ id = 'pdd-co-equals-governing-body';  name = 'Personnel forms - Personnel due diligence where the compliance officer and governing body are the same person' }
    @{ id = 'pdd-general-staff';             name = 'Personnel forms - Personnel due diligence - general staff' }
    @{ id = 'training-records';              name = 'Personnel forms - Training records and acknowledgement' }
    @{ id = 'final-onboarding-checks';       name = 'Customer forms - Final onboarding checks' }
    @{ id = 'escalation-form';               name = 'Customer forms - Escalation form' }
    @{ id = 'unusual-activity-review';       name = 'Customer forms - Unusual activity report review form' }
    @{ id = 'trigger-event-review';          name = 'Customer forms - Trigger event review and update form' }
    @{ id = 'ongoing-cdd-monitoring';        name = 'Customer forms - Ongoing CDD and monitoring' }
    @{ id = 'reportable-matter-working';     name = 'Customer forms - Reportable matter working form' }
    @{ id = 'effectiveness-onboarding';      name = 'Maintain program forms - Client onboarding effectiveness check' }
    @{ id = 'effectiveness-cdd';             name = 'Maintain program forms - CDD effectiveness check' }
    @{ id = 'effectiveness-ongoing-monitoring'; name = 'Maintain program forms - Ongoing monitoring effectiveness check' }
    @{ id = 'effectiveness-smr';             name = 'Maintain program forms - SMR effectiveness check' }
    @{ id = 'effectiveness-ttr';             name = 'Maintain program forms - TTR effectiveness check' }
    @{ id = 'effectiveness-ifti';            name = 'Maintain program forms - IFTI effectiveness check' }
    @{ id = 'effectiveness-training';        name = 'Maintain program forms - Training effectiveness check' }
    @{ id = 'effectiveness-recordkeeping';   name = 'Maintain program forms - Recordkeeping effectiveness check' }
    @{ id = 'effectiveness-governance';      name = 'Maintain program forms - Governance and Compliance Officer effectiveness check' }
    @{ id = 'independent-evaluation-checklist'; name = 'Maintain program forms - Independent evaluation scope and checklist' }
)

# Client x service matrix (4 client types x 2 service lines x 2 kinds = 16 forms)
$clientLabels = @(
    @{ k='IndividualSoleTrader';          l='Individual or sole trader' }
    @{ k='BodyCorporatePartnershipAssoc'; l='Body corporate, partnership or association' }
    @{ k='Trust';                          l='Trust' }
    @{ k='Government';                     l='Government body' }
)
$serviceLabels = @(
    @{ k='conv';  l='Conveyancing' }
    @{ k='other'; l='Other professional services' }
)
$kinds = @(
    @{ k='onboarding';   l='Onboarding form' }
    @{ k='initial-cdd';  l='Initial customer due diligence form' }
)

foreach ($s in $serviceLabels) {
    foreach ($kn in $kinds) {
        foreach ($c in $clientLabels) {
            $id = "$($kn.k)-$($s.k)-$($c.k)"
            $name = "Customer forms - $($kn.l) - $($c.l) - $($s.l)"
            $files += @{ id = $id; name = $name }
        }
    }
}

$ok = 0; $fail = 0; $skipped = 0
$wc = New-Object System.Net.WebClient
$wc.Headers.Add('User-Agent','Mozilla/5.0 (compatible; LegalAMLStarterKit/0.2)')

foreach ($f in $files) {
    $remoteName = "$prefix$($f.name) - January 2026.docx"
    $urlPath = [uri]::EscapeDataString($remoteName) -replace '%20',' ' -replace ' ','%20'
    $url = $base + $urlPath
    $localPath = Join-Path $outDir "$($f.id).docx"

    if (Test-Path $localPath) {
        Write-Host "SKIP $($f.id) (already present)"
        $skipped++
        continue
    }
    if ($DryRun) {
        Write-Host "DRY  $($f.id) <- $url"
        continue
    }

    try {
        $wc.DownloadFile($url, $localPath)
        $size = (Get-Item $localPath).Length
        if ($size -lt 5000) {
            Remove-Item $localPath -Force
            Write-Host "FAIL $($f.id) (suspicious size $size)"
            $fail++
        } else {
            Write-Host "OK   $($f.id) ($size bytes)"
            $ok++
        }
    } catch {
        Write-Host "FAIL $($f.id): $($_.Exception.Message)"
        $fail++
    }
}

Write-Host ""
Write-Host "Done. OK=$ok FAIL=$fail SKIPPED=$skipped"
