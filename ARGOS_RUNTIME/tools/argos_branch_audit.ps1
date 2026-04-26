# ============================================================
# ARGOS - argos_branch_audit.ps1
# Auditoria one-shot de ramas abiertas del repositorio ARGOS.
# ============================================================

$RepoPath = "C:\Users\Widox\Desktop\ARGOS"
$CommitTool = Join-Path $RepoPath "ARGOS_RUNTIME\tools\argos_commit.ps1"

Set-Location $RepoPath

Write-Host "[ARGOS-BRANCH-AUDIT] Resumen para el Capitan"
Write-Host "[ARGOS-BRANCH-AUDIT] Repo: $RepoPath"
& $CommitTool -ListBranches
