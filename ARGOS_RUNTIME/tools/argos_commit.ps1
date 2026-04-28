# ============================================================
# ARGOS - argos_commit.ps1
# Script de commit, ramas y merge compartido para la tripulacion.
#
# Uso:
#   argos_commit.ps1 -Agent <nombre> [-PacketId <id>] [-Branch] [-BranchName <rama>] [-Message <msg>]
#   argos_commit.ps1 -Agent <nombre> -PacketId <id> -Merge [-DeleteBranch]
#   argos_commit.ps1 -ListBranches
#   argos_commit.ps1 -CleanDesktopIniRefs
# ============================================================

param(
    [string]$Agent = "",

    [string]$PacketId = "",

    [switch]$Branch,

    [string]$BranchName = "",

    [string]$Message = "",

    [switch]$Merge,

    [switch]$DeleteBranch,

    [switch]$ListBranches,

    [switch]$AllowMain,

    [switch]$CleanDesktopIniRefs
)

$RepoPath = "C:\Users\Widox\Desktop\ARGOS"
$ErrorActionPreference = "Stop"

Set-Location $RepoPath

$TargetPaths = @(
    "argos-api/src/",
    "argos-api/dist/index.js",
    "argos-dashboard/",
    "ARGOS_RUNTIME/ARGOS_QUICKSTART.md",
    "ARGOS_RUNTIME/INTER_AI_PROTOCOL.md",
    "ARGOS_RUNTIME/ARGOS_VECTOR.md",
    "ARGOS_RUNTIME/agents/",
    "ARGOS_RUNTIME/docs/protocols/",
    "ARGOS_RUNTIME/tools/",
    "ARGOS_RUNTIME/work_packets/inbox/",
    "versions.json"
)

$BranchRequiredPaths = @(
    "argos-api/src/",
    "argos-api/dist/index.js",
    "argos-dashboard/",
    "ARGOS_RUNTIME/ARGOS_QUICKSTART.md",
    "ARGOS_RUNTIME/INTER_AI_PROTOCOL.md",
    "ARGOS_RUNTIME/agents/",
    "ARGOS_RUNTIME/tools/",
    "ARGOS_RUNTIME/docs/protocols/",
    "versions.json"
)

function Invoke-Git {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Arguments,

        [switch]$AllowFailure
    )

    $output = & git @Arguments 2>&1
    if ($LASTEXITCODE -ne 0 -and -not $AllowFailure) {
        throw "[ARGOS-COMMIT] git $($Arguments -join ' ') fallo: $output"
    }

    return $output
}

function Normalize-GitPathFromStatusLine {
    param([string]$Line)

    $path = $Line -replace "^.{3}", ""
    if ($path -match " -> ") {
        $path = ($path -split " -> ")[-1]
    }
    return ($path.Trim('"') -replace "\\", "/")
}

function Test-PathMatchesAnyPrefix {
    param(
        [string]$Path,
        [string[]]$Prefixes
    )

    foreach ($p in $Prefixes) {
        if ($Path.StartsWith($p) -or $Path -eq $p.TrimEnd("/")) {
            return $true
        }
    }
    return $false
}

function Remove-DesktopIniRefs {
    $refsPath = Join-Path $RepoPath ".git\refs"
    if (-not (Test-Path -LiteralPath $refsPath)) {
        Write-Host "[ARGOS-COMMIT] No existe .git\refs; limpieza omitida."
        return
    }

    $refs = Get-ChildItem -LiteralPath $refsPath -Recurse -Force -File -Filter "desktop.ini" -ErrorAction SilentlyContinue
    if (-not $refs) {
        Write-Host "[ARGOS-COMMIT] Sin refs desktop.ini que limpiar."
        return
    }

    foreach ($ref in $refs) {
        Remove-Item -LiteralPath $ref.FullName -Force
        Write-Host "[ARGOS-COMMIT] Ref basura eliminada: $($ref.FullName)"
    }
}

function Get-PacketIdFromBranch {
    param([string]$Branch)

    if ($Branch -notmatch "^[^/]+/(arg-.+)$") {
        return ""
    }

    $slug = $Matches[1]

    if ($slug -match "^(arg-\d{13}-\d{3})(?:-|__|$)") {
        return $Matches[1].ToUpper()
    }

    if ($slug -match "^(arg-\d{13})(?:-|__|$)") {
        return $Matches[1].ToUpper()
    }

    if ($slug -match "^(arg-reform-.+?-\d{3}(?:-[a-z0-9]+)*)(?:__|$)") {
        return $Matches[1].ToUpper()
    }

    if ($slug -match "^(arg-[a-z]+(?:-[a-z0-9]+)*-\d{3}(?:-[a-z0-9]+)*?)(?:-|__|$)") {
        return $Matches[1].ToUpper()
    }

    return $slug.ToUpper()
}

function Test-PacketFile {
    param(
        [string]$Folder,
        [string]$PacketId
    )

    if (-not $PacketId) {
        return $false
    }

    $path = Join-Path $RepoPath "ARGOS_RUNTIME\work_packets\$Folder"
    if (-not (Test-Path -LiteralPath $path)) {
        return $false
    }

    $match = Get-ChildItem -LiteralPath $path -Filter "$PacketId*" -File -ErrorAction SilentlyContinue | Select-Object -First 1
    return [bool]$match
}

function Get-PacketBranchStatus {
    param([string]$PacketId)

    if (-not $PacketId) {
        return "packet: desconocido  [HUERFANA]"
    }

    if (Test-PacketFile -Folder "done" -PacketId $PacketId) {
        return "packet: $PacketId  [DONE - MERGE PENDIENTE]"
    }

    if (Test-PacketFile -Folder "archived" -PacketId $PacketId) {
        return "packet: $PacketId  [HUERFANA]"
    }

    if (Test-PacketFile -Folder "in_progress" -PacketId $PacketId) {
        return "packet: $PacketId  [IN_PROGRESS]"
    }

    if (Test-PacketFile -Folder "inbox" -PacketId $PacketId) {
        return "packet: $PacketId  [OPEN]"
    }

    $statePath = Join-Path $RepoPath "ARGOS_RUNTIME\state\argos.state.json"
    if (Test-Path -LiteralPath $statePath) {
        try {
            $state = Get-Content -LiteralPath $statePath -Raw | ConvertFrom-Json
            $value = $state.packet_states.$PacketId
            if ($value) {
                if ($value -match "archived") {
                    return "packet: $PacketId  [HUERFANA]"
                }
                if ($value -match "done") {
                    return "packet: $PacketId  [DONE - MERGE PENDIENTE]"
                }
                if ($value -match "in_progress") {
                    return "packet: $PacketId  [IN_PROGRESS]"
                }
                if ($value -match "inbox|open") {
                    return "packet: $PacketId  [OPEN]"
                }
                return "packet: $PacketId  [$value]"
            }
        } catch {
            return "packet: $PacketId  [ESTADO NO LEGIBLE]"
        }
    }

    return "packet: $PacketId  [HUERFANA]"
}

function Show-ArgosBranches {
    $branches = Invoke-Git -Arguments @("branch", "--format=%(refname:short)") -AllowFailure
    $openBranches = @($branches | Where-Object { $_ -and $_ -ne "main" })

    Write-Host "[ARGOS-BRANCHES] Ramas abiertas:"
    if (-not $openBranches -or $openBranches.Count -eq 0) {
        Write-Host "  (ninguna)"
        return
    }

    foreach ($branch in $openBranches) {
        $packetId = Get-PacketIdFromBranch -Branch $branch
        $status = Get-PacketBranchStatus -PacketId $packetId
        Write-Host "  $branch  ->  $status"
    }
}

if ($CleanDesktopIniRefs) {
    Remove-DesktopIniRefs
    exit 0
}

function Invoke-ArgosMerge {
    if (-not $Agent) {
        throw "[ARGOS-COMMIT] -Agent es obligatorio con -Merge."
    }

    if (-not $PacketId) {
        throw "[ARGOS-COMMIT] -PacketId es obligatorio con -Merge."
    }

    $currentBranch = (Invoke-Git -Arguments @("rev-parse", "--abbrev-ref", "HEAD")).Trim()
    if ($currentBranch -eq "main") {
        Write-Host "[ARGOS-COMMIT] Ya estas en main. Nada que mergear."
        return
    }

    $dirty = Invoke-Git -Arguments @("status", "--porcelain")
    if ($dirty) {
        Write-Host "[ARGOS-COMMIT] Hay cambios sin commitear; merge cancelado para no mezclar trabajo vivo."
        $dirty | ForEach-Object { Write-Host "  $_" }
        exit 1
    }

    Invoke-Git -Arguments @("checkout", "main") | Out-Null
    Invoke-Git -Arguments @("merge", $currentBranch, "--no-ff", "-m", "[$Agent] merge ${PacketId}: $currentBranch") | Out-Null

    $origin = Invoke-Git -Arguments @("remote", "get-url", "origin") -AllowFailure
    if ($LASTEXITCODE -eq 0 -and $origin) {
        Invoke-Git -Arguments @("push", "origin", "main") | Out-Null
    } else {
        Write-Host "[ARGOS-COMMIT] Sin remote origin configurado; push omitido."
    }

    if ($DeleteBranch) {
        Invoke-Git -Arguments @("branch", "-d", $currentBranch) | Out-Null
        Write-Host "[ARGOS-COMMIT] Rama eliminada: $currentBranch"
    }

    Write-Host "[ARGOS-COMMIT] Merge completado: $currentBranch -> main"
}

if ($ListBranches) {
    Show-ArgosBranches
    exit 0
}

if ($Merge) {
    Invoke-ArgosMerge
    exit 0
}

if (-not $Agent) {
    throw "[ARGOS-COMMIT] -Agent es obligatorio para commitear o crear rama."
}

$rawStatus = Invoke-Git -Arguments @("status", "--porcelain")
$relevantChanges = $rawStatus | Where-Object {
    $line = Normalize-GitPathFromStatusLine -Line $_
    Test-PathMatchesAnyPrefix -Path $line -Prefixes $TargetPaths
}

if (-not $relevantChanges) {
    Write-Host "[ARGOS-COMMIT] Sin cambios constitutivos que commitear. Operacional ignorado."
    exit 0
}

Write-Host "[ARGOS-COMMIT] Cambios detectados:"
$relevantChanges | ForEach-Object { Write-Host "  $_" }

if ($Branch) {
    if (-not $BranchName) {
        $agentSlug = $Agent.ToLower() -replace "[^a-z0-9]", ""
        if ($PacketId) {
            $packetSlug = $PacketId.ToLower() -replace "[^a-z0-9-]", ""
            $BranchName = "$agentSlug/$packetSlug"
        } else {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
            $BranchName = "$agentSlug/work-$timestamp"
        }
    }

    $currentBranch = (Invoke-Git -Arguments @("rev-parse", "--abbrev-ref", "HEAD")).Trim()
    if ($currentBranch -ne $BranchName) {
        $exists = Invoke-Git -Arguments @("branch", "--list", $BranchName)
        if ($exists) {
            Invoke-Git -Arguments @("checkout", $BranchName) | Out-Null
            Write-Host "[ARGOS-COMMIT] Cambiado a rama existente: $BranchName"
        } else {
            Invoke-Git -Arguments @("checkout", "-b", $BranchName) | Out-Null
            Write-Host "[ARGOS-COMMIT] Rama creada: $BranchName"
        }
    } else {
        Write-Host "[ARGOS-COMMIT] Ya en rama: $BranchName"
    }
}

$currentBranch = (Invoke-Git -Arguments @("rev-parse", "--abbrev-ref", "HEAD")).Trim()
$branchRequiredChanges = @($relevantChanges | Where-Object {
    $line = Normalize-GitPathFromStatusLine -Line $_
    Test-PathMatchesAnyPrefix -Path $line -Prefixes $BranchRequiredPaths
})

if ($currentBranch -eq "main" -and $branchRequiredChanges.Count -gt 0 -and -not $AllowMain) {
    Write-Host "[ARGOS-COMMIT] Rama obligatoria: se detectaron cambios protegidos estando en main."
    $branchRequiredChanges | ForEach-Object { Write-Host "  $_" }
    Write-Host "[ARGOS-COMMIT] Ejecuta con -Branch antes de commitear, o usa -AllowMain solo para una excepcion documentada."
    exit 1
}

foreach ($p in $TargetPaths) {
    $fullPath = Join-Path $RepoPath $p.Replace("/", "\")
    if (Test-Path -LiteralPath $fullPath) {
        Invoke-Git -Arguments @("add", $fullPath) | Out-Null
    }
}

$staged = Invoke-Git -Arguments @("diff", "--cached", "--name-only")
if (-not $staged) {
    Write-Host "[ARGOS-COMMIT] Nada en staging. Los cambios pueden estar en paths ignorados por .gitignore."
    exit 0
}

Write-Host "[ARGOS-COMMIT] Staged:"
$staged | ForEach-Object { Write-Host "  $_" }

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
if ($Message) {
    $commitMsg = "[$Agent] $Message"
} elseif ($PacketId) {
    $commitMsg = "[$Agent] $PacketId - $timestamp"
} else {
    $commitMsg = "[$Agent] auto-commit $timestamp"
}

$result = Invoke-Git -Arguments @("commit", "-m", $commitMsg) -AllowFailure
if ($LASTEXITCODE -eq 0) {
    Write-Host "[ARGOS-COMMIT] OK: $commitMsg"
} else {
    Write-Host "[ARGOS-COMMIT] Sin cambios nuevos o commit fallido: $result"
}
