param(
    [ValidateSet('start_of_day', 'end_of_day')]
    [string]$Mode = 'end_of_day',
    [string]$Actor = 'Codex',
    [string]$Reason = 'Rollover manual de sesion',
    [switch]$DryRun,
    [switch]$SkipDonePackets,
    [switch]$SkipStateCompaction,
    [switch]$SkipLegacyReorg
)

$ErrorActionPreference = 'Stop'

$uri = 'http://localhost:8080/api/session/archive'
$body = @{
    mode = $Mode
    actor = $Actor
    reason = $Reason
    dryRun = [bool]$DryRun
    archiveDonePackets = -not [bool]$SkipDonePackets
    compactState = -not [bool]$SkipStateCompaction
    reorganizeLegacy = -not [bool]$SkipLegacyReorg
} | ConvertTo-Json -Depth 4

Write-Host "== ARGOS Session Rollover =="
Write-Host "POST $uri"
Write-Host "Mode: $Mode | DryRun: $([bool]$DryRun)"

$resp = Invoke-RestMethod -Uri $uri -Method Post -ContentType 'application/json' -Body $body -TimeoutSec 120
$resp | ConvertTo-Json -Depth 8
