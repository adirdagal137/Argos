param(
    [string]$RuntimeDir = 'c:\Users\Widox\Desktop\ARGOS\ARGOS_RUNTIME'
)

$ErrorActionPreference = 'Stop'

function Get-WorkPacketMeta {
    param(
        [string]$FilePath,
        [string]$Zone
    )

    $content = Get-Content -LiteralPath $FilePath -Raw
    if ($content -notmatch '\[WORK_PACKET\]') { return $null }

    $id = [regex]::Match($content, '(?m)^ID:\s*(.+)$').Groups[1].Value.Trim()
    if ([string]::IsNullOrWhiteSpace($id)) {
        $id = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    }

    $status = [regex]::Match($content, '(?m)^STATUS:\s*(.+)$').Groups[1].Value.Trim().ToLowerInvariant()
    if ([string]::IsNullOrWhiteSpace($status)) {
        $status = if ($Zone -eq 'done') { 'done' } elseif ($Zone -eq 'in_progress') { 'in_progress' } else { 'open' }
    }

    $type = [regex]::Match($content, '(?m)^TYPE:\s*(.+)$').Groups[1].Value.Trim().ToLowerInvariant()
    $tag = [regex]::Match($content, '(?m)^TAG:\s*(.+)$').Groups[1].Value.Trim().ToLowerInvariant()

    return [pscustomobject]@{
        id = $id
        zone = $Zone
        status = $status
        type = $type
        tag = $tag
        isBug = ($type -eq 'bug' -or $tag -eq 'bug')
    }
}

function Get-WorkPacketsFromZone {
    param(
        [string]$RuntimeDir,
        [string]$Zone
    )

    $zonePath = Join-Path $RuntimeDir ("work_packets\" + $Zone)
    if (-not (Test-Path -LiteralPath $zonePath)) { return @() }

    $items = @()
    Get-ChildItem -LiteralPath $zonePath -File -Filter *.md | ForEach-Object {
        if ($_.Name -like '*__RESULTADO*') { return }
        $meta = Get-WorkPacketMeta -FilePath $_.FullName -Zone $Zone
        if ($null -ne $meta) { $items += $meta }
    }
    return $items
}

function New-DefaultState {
    return [ordered]@{
        module = 'argos_core'
        updated_at = (Get-Date -Format 'o')
        current_focus = ''
        status = 'active'
        open_packets = @()
        in_progress_packets = @()
        active_risks = @()
        next_step = ''
        owner_hint = 'Codex / Antigravity / Capitan'
    }
}

function Read-StateOrDefault {
    param([string]$StatePath)

    $defaultState = New-DefaultState

    if (-not (Test-Path -LiteralPath $StatePath)) {
        return $defaultState
    }

    $fileInfo = Get-Item -LiteralPath $StatePath
    if ($fileInfo.Length -gt 5MB) {
        # Guardrail: corrupted or runaway snapshots should not block state sync.
        return $defaultState
    }

    try {
        $raw = [System.IO.File]::ReadAllText($StatePath)
        if ($raw.Length -gt 0 -and $raw[0] -eq [char]0xFEFF) {
            $raw = $raw.Substring(1)
        }
        $obj = $raw | ConvertFrom-Json
        $state = Convert-ObjectToHashtable -InputObject $obj
    }
    catch {
        return $defaultState
    }

    foreach ($key in $defaultState.Keys) {
        if (-not $state.ContainsKey($key)) {
            $state[$key] = $defaultState[$key]
        }
    }

    return $state
}

function Convert-ObjectToHashtable {
    param([object]$InputObject)

    if ($null -eq $InputObject) { return $null }
    if ($InputObject -is [hashtable]) { return $InputObject }
    if ($InputObject -is [System.Collections.IDictionary]) {
        $ht = @{}
        foreach ($k in $InputObject.Keys) {
            $ht[$k] = Convert-ObjectToHashtable -InputObject $InputObject[$k]
        }
        return $ht
    }
    if ($InputObject -is [System.Collections.IEnumerable] -and -not ($InputObject -is [string])) {
        $arr = @()
        foreach ($item in $InputObject) {
            $arr += ,(Convert-ObjectToHashtable -InputObject $item)
        }
        return $arr
    }
    if ($InputObject -is [psobject]) {
        $ht = @{}
        foreach ($prop in $InputObject.PSObject.Properties) {
            $ht[$prop.Name] = Convert-ObjectToHashtable -InputObject $prop.Value
        }
        return $ht
    }
    return $InputObject
}

function Write-FileTextWithRetry {
    param(
        [string]$Path,
        [string]$Content,
        [System.Text.Encoding]$Encoding,
        [int]$MaxAttempts = 8,
        [int]$DelayMs = 150
    )

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            [System.IO.File]::WriteAllText($Path, $Content, $Encoding)
            return
        }
        catch [System.IO.IOException] {
            if ($attempt -eq $MaxAttempts) { throw }
            Start-Sleep -Milliseconds $DelayMs
        }
    }
}

function Ensure-ArrayValue {
    param([object]$Value)

    if ($null -eq $Value) { return @() }
    if ($Value -is [string]) { return @($Value) }
    if ($Value -is [hashtable]) { return @() }
    if ($Value -is [System.Collections.IEnumerable]) { return @($Value) }
    return @($Value)
}

$statePath = Join-Path $RuntimeDir 'state\argos.state.json'
$state = Read-StateOrDefault -StatePath $statePath

$inbox = Get-WorkPacketsFromZone -RuntimeDir $RuntimeDir -Zone 'inbox'
$inProgress = Get-WorkPacketsFromZone -RuntimeDir $RuntimeDir -Zone 'in_progress'
$done = Get-WorkPacketsFromZone -RuntimeDir $RuntimeDir -Zone 'done'

# Inbox abierto para estado global = paquetes no-bug (los bugs viven en su carril propio).
$openPackets = $inbox | Where-Object { -not $_.isBug } | ForEach-Object { $_.id } | Sort-Object -Unique
$inProgressPackets = $inProgress | ForEach-Object { $_.id } | Sort-Object -Unique

$doneAll = $done | ForEach-Object { $_.id } | Sort-Object -Unique
$doneTasks = $done | Where-Object { -not $_.isBug } | ForEach-Object { $_.id } | Sort-Object -Unique
$doneBugs = $done | Where-Object { $_.isBug } | ForEach-Object { $_.id } | Sort-Object -Unique

$state['updated_at'] = (Get-Date -Format 'o')
$state['open_packets'] = @($openPackets)
$state['in_progress_packets'] = @($inProgressPackets)
$state['active_risks'] = @(Ensure-ArrayValue -Value $state['active_risks'])
$state['done_packets_summary'] = [ordered]@{
    total = @($doneAll).Count
    tasks = @($doneTasks).Count
    bugs = @($doneBugs).Count
    latest_ids = @($doneAll | Select-Object -Last 10)
}

$json = $state | ConvertTo-Json -Depth 8
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
Write-FileTextWithRetry -Path $statePath -Content $json -Encoding $utf8NoBom

Write-Output ("synced_state=" + $statePath)
Write-Output ("open_packets=" + (@($openPackets).Count))
Write-Output ("in_progress_packets=" + (@($inProgressPackets).Count))
Write-Output ("done_packets=" + (@($doneAll).Count))
