# Copy AUSTRAC starter-kit templates from the staging /austrac/ folder into
# /vendor/templates/ with canonical {id}.docx filenames keyed to the wizard
# catalogue. Also writes manifest.json recording the original AUSTRAC filename
# for each id (provenance + attribution).

$src = Join-Path $PSScriptRoot '..\..\austrac'
$dst = $PSScriptRoot

if (-not (Test-Path $src)) {
    Write-Error "Source folder not found: $src"
    exit 1
}

# Map: id -> source filename (without .docx extension).
# Mirrors AUSTRAC's actual published filenames (typos included where AUSTRAC
# has them, e.g. missing space, lowercase 'trust').
$map = [ordered]@{
    'policy-document'                              = 'Legal profession - Policy document - January 2026'
    'process-document'                             = 'Legal profession - Process document - January 2026'
    'ra-conveyancing'                              = 'Legal profession - Risk assessment - Conveyancing for the legal profession - January 2026'
    'ra-other-prof-services'                       = 'Legal profession - Risk assessment - Other professional services - January 2026'
    'assign-responsibilities'                      = 'Legal profession - Personnel forms - Assign responsibilities form - January 2026'
    'amlctf-roles'                                 = 'Legal profession - Personnel forms - AMLCTF roles form - January 2026'
    'pdd-compliance-officer'                       = 'Legal profession - Personnel forms - Personnel due diligence for AMLCTF compliance officer form - January 2026'
    'pdd-general-staff'                            = 'Legal profession - Personnel forms - Personnel due diligence form - January 2026'
    'pdd-co-equals-governing-body'                 = 'Legal profession - Personnel forms - Personnel due diligence where the compliance officer and governing body are the same person form - January 2026'
    'escalation-form'                              = 'Legal profession - Customer forms - Escalation form - January 2026'
    'escalations-register'                         = 'Legal profession - Customer forms - Escalations register - January 2026'
    'enhanced-cdd-form'                            = 'Legal profession - Customer forms - Enhanced CDD form - January 2026'
    'unusual-activity-info'                        = 'Legal profession - Customer forms - Unusual activity report information form - January 2026'
    'unusual-activity-review'                      = 'Legal profession - Customer forms - Unusual activity report review form - January 2026'
    'trigger-event-review'                         = 'Legal profession - Customer forms - Trigger event review and update form - January 2026'
    'periodic-review'                              = 'Legal profession - Customer forms - Periodic review and update form - January 2026'
    'onboarding-other-IndividualSoleTrader'        = 'Legal profession - Customer forms - Onboarding form - Individual or sole trader - January 2026'
    'onboarding-other-BodyCorporatePartnershipAssoc' = 'Legal profession - Customer forms - Onboarding form - Body corporate, partnership or unincorporated association -January 2026'
    'onboarding-other-Trust'                       = 'Legal profession - Customer forms - Onboarding form - Trust - January 2026'
    'onboarding-other-Government'                  = 'Legal profession - Customer forms - Onboarding form - Government body - January 2026'
    'initial-cdd-other-IndividualSoleTrader'       = 'Legal profession - Customer forms - Initial customer due diligence form - Individual or sole trader - January 2026'
    'initial-cdd-other-BodyCorporatePartnershipAssoc' = 'Legal profession - Customer forms - Initial customer due diligence form - Body corporate, partnership or association - January 2026'
    'initial-cdd-other-Trust'                      = 'Legal profession - Customer forms - Initial customer due diligence form - Trust - January 2026'
    'initial-cdd-other-Government'                 = 'Legal profession - Customer forms - Initial customer due diligence form - Government body - January 2026'
    'onboarding-conv-IndividualSoleTrader'         = 'Conveyancers - Customer forms - Onboarding form - Individual or sole trader - January 2026'
    'onboarding-conv-BodyCorporatePartnershipAssoc' = 'Conveyancers - Customer forms - Onboarding form - Body corporate, partnership or unincorporated association - January 2026'
    'onboarding-conv-Trust'                        = 'Conveyancers - Customer forms - Onboarding form - trust - January 2026'
    'onboarding-conv-Government'                   = 'Conveyancers - Customer forms - Onboarding form - Government body - January 2026'
    'initial-cdd-conv-IndividualSoleTrader'        = 'Conveyancers - Customer forms - Initial customer due diligence form - Individual or sole trader - January 2026'
    'initial-cdd-conv-BodyCorporatePartnershipAssoc' = 'Conveyancers - Customer forms - Initial customer due diligence form - Body corporate, partnership or association - January 2026'
    'initial-cdd-conv-Trust'                       = 'Conveyancers - Customer forms - Initial customer due diligence form - Trust - January 2026'
    'initial-cdd-conv-Government'                  = 'Conveyancers - Customer forms - Initial customer due diligence form - Government body - January 2026'
    'request-to-verify'                            = 'Conveyancers - Customer forms - Request to verify information - January 2026'
    'effectiveness-onboarding'                     = 'Legal profession - Maintain program forms - Client onboarding effectiveness check form - January 2026'
    'effectiveness-enhanced-cdd'                   = 'Legal profession - Maintain program forms - Enhanced CDD effectiveness check form - January 2026'
    'effectiveness-smr'                            = 'Legal profession - Maintain program forms - SMR effectiveness check form - January 2026'
    'effectiveness-ttr'                            = 'Legal profession - Maintain program forms - TTR effectiveness check form - January 2026'
    'effectiveness-cbm'                            = 'Legal profession - Maintain program forms - CBM reporting effectiveness check form - January 2026'
    'effectiveness-co-sm'                          = 'Legal profession - Maintain program forms - Compliance officer and senior manager effectiveness check form - January 2026'
    'effectiveness-periodic-summary'               = 'Legal profession - Maintain program forms - Periodic effectiveness testing summary form - January 2026'
    'maintain-program'                             = 'Legal profession - Maintain program forms - Maintain your AMLCTF program form - January 2026'
    'annual-governing-report'                      = 'Legal profession - Maintain program forms - Annual report to the governing body form - January 2026'
    'independent-evaluation'                       = 'Legal profession - Maintain program forms - Independent evaluation response form - January 2026'
}

$ok = 0; $fail = 0
$manifest = @{}
foreach ($id in $map.Keys) {
    $srcPath = Join-Path $src "$($map[$id]).docx"
    $dstPath = Join-Path $dst "$id.docx"
    if (-not (Test-Path $srcPath)) {
        Write-Host "MISSING $id <- $($map[$id]).docx"
        $fail++
        continue
    }
    Copy-Item -LiteralPath $srcPath -Destination $dstPath -Force
    $size = (Get-Item -LiteralPath $dstPath).Length
    $manifest[$id] = @{ source = "$($map[$id]).docx"; bytes = $size }
    Write-Host "OK   $id ($size bytes)"
    $ok++
}

# Write manifest.json for provenance.
$manifestPath = Join-Path $dst 'manifest.json'
$manifest | ConvertTo-Json -Depth 4 | Out-File -FilePath $manifestPath -Encoding utf8

Write-Host ""
Write-Host "Done. OK=$ok FAIL=$fail. Manifest: $manifestPath"
