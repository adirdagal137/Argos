# ============================================================
# ARGOS — argos_commit.ps1
# Script de commit compartido para toda la tripulacion.
# Uso:
#   argos_commit.ps1 -Agent <nombre> [-PacketId <id>] [-Branch] [-BranchName <rama>] [-Message <msg>]
#
# Parametros:
#   -Agent       (obligatorio) Nombre del agente: Claude, Codex, Antigravity, ChatGPT...
#   -PacketId    (opcional)    ID del work packet activo (ej. ARG-1776816000001)
#   -Branch      (switch)      Si se activa, crea/cambia a una rama de trabajo antes de commitear
#   -BranchName  (opcional)    Nombre de rama personalizado. Default: agente/packetid
#   -Message     (opcional)    Mensaje de commit personalizado. Si no, se genera automaticamente
#
# Ejemplos:
#   # Commit simple al finalizar una tarea
#   .\argos_commit.ps1 -Agent Codex -PacketId ARG-1776816000001
#
#   # Iniciar rama de trabajo para una mejora del sistema
#   .\argos_commit.ps1 -Agent Claude -PacketId ARG-1776816000042 -Branch
#
#   # Commit con mensaje manual
#   .\argos_commit.ps1 -Agent Antigravity -PacketId ARG-XXX -Message "refactor: nuevo parser de eventos"
# ============================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$Agent,

    [string]$PacketId = "",

    [switch]$Branch,

    [string]$BranchName = "",

    [string]$Message = ""
)

$RepoPath = "C:\Users\Widox\Desktop\ARGOS"
$ErrorActionPreference = "SilentlyContinue"

Set-Location $RepoPath

# ── Archivos que interesan al protocolo ──────────────────────────────────────
# Solo se commitean ficheros constitutivos del navio.
# Estado operativo (state/, events/, secrets/, views/) va en .gitignore.
$TargetPaths = @(
    "argos-api/src/",
    "argos-api/dist/index.js",
    "argos-dashboard/",
    "ARGOS_RUNTIME/ARGOS_QUICKSTART.md",
    "ARGOS_RUNTIME/INTER_AI_PROTOCOL.md",
    "ARGOS_RUNTIME/ARGOS_VECTOR.md",
    "ARGOS_RUNTIME/agents/",
    "ARGOS_RUNTIME/tools/",
    "ARGOS_RUNTIME/work_packets/inbox/"
)

# ── Comprobar si hay cambios en esos paths ───────────────────────────────────
$rawStatus = git status --porcelain 2>$null
$relevantChanges = $rawStatus | Where-Object {
    $line = $_ -replace "^.{3}", ""   # quita los 3 primeros caracteres de status (XY + espacio)
    $found = $false
    foreach ($p in $TargetPaths) {
        if ($line.StartsWith($p) -or $line -like "*$p*") {
            $found = $true
            break
        }
    }
    $found
}

if (-not $relevantChanges) {
    Write-Host "[ARGOS-COMMIT] Sin cambios constitutivos que commitear. Operacional ignorado."
    exit 0
}

Write-Host "[ARGOS-COMMIT] Cambios detectados:"
$relevantChanges | ForEach-Object { Write-Host "  $_" }

# ── Logica de rama ───────────────────────────────────────────────────────────
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

    $currentBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($currentBranch -ne $BranchName) {
        $exists = git branch --list $BranchName 2>$null
        if ($exists) {
            git checkout $BranchName 2>$null
            Write-Host "[ARGOS-COMMIT] Cambiado a rama existente: $BranchName"
        } else {
            git checkout -b $BranchName 2>$null
            Write-Host "[ARGOS-COMMIT] Rama creada: $BranchName"
        }
    } else {
        Write-Host "[ARGOS-COMMIT] Ya en rama: $BranchName"
    }
}

# ── Staging de archivos constitutivos ────────────────────────────────────────
foreach ($p in $TargetPaths) {
    $fullPath = Join-Path $RepoPath $p.Replace("/", "\")
    if (Test-Path $fullPath) {
        git add $fullPath 2>$null
    }
}

# Comprobar que hay algo en staging
$staged = git diff --cached --name-only 2>$null
if (-not $staged) {
    Write-Host "[ARGOS-COMMIT] Nada en staging. Los cambios pueden estar en paths ignorados por .gitignore."
    exit 0
}

Write-Host "[ARGOS-COMMIT] Staged:"
$staged | ForEach-Object { Write-Host "  $_" }

# ── Construir mensaje de commit ───────────────────────────────────────────────
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
if ($Message) {
    $commitMsg = "[$Agent] $Message"
} elseif ($PacketId) {
    $commitMsg = "[$Agent] $PacketId - $timestamp"
} else {
    $commitMsg = "[$Agent] auto-commit $timestamp"
}

# ── Commit ────────────────────────────────────────────────────────────────────
$result = git commit -m $commitMsg 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[ARGOS-COMMIT] OK: $commitMsg"
} else {
    Write-Host "[ARGOS-COMMIT] Sin cambios nuevos o commit fallido: $result"
}
