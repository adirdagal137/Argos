param(
  [string]$RepoRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
  $RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

$versionPath = Join-Path $RepoRoot 'ARGOS_RUNTIME\argos.version'
if (-not (Test-Path -LiteralPath $versionPath)) {
  Write-Warning "[ARGOS] No existe $versionPath. Se omite creacion de tag."
  exit 0
}

$version = (Get-Content -LiteralPath $versionPath -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') {
  Write-Warning "[ARGOS] Version invalida en argos.version: '$version'. Se omite creacion de tag."
  exit 0
}

$tag = "argos-v$version"

git -C $RepoRoot rev-parse --verify --quiet "refs/tags/$tag" | Out-Null
if ($LASTEXITCODE -eq 0) {
  Write-Output "[ARGOS] Tag ya existe: $tag"
  exit 0
}

$sha = (git -C $RepoRoot rev-parse --short HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($sha)) {
  Write-Warning '[ARGOS] No se pudo resolver HEAD. Se omite creacion de tag.'
  exit 0
}

git -C $RepoRoot tag -a $tag -m "ARGOS $tag ($sha)" | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Warning "[ARGOS] No se pudo crear el tag $tag"
  exit 0
}

Write-Output "[ARGOS] Tag creado: $tag"
