param(
  [string]$TunnelName = 'argos-remote',
  [string]$Hostname = '',
  [string]$ConfigPath = 'C:\Users\Widox\Desktop\ARGOS\ARGOS_RUNTIME\tools\cloudflared_config.example.yml',
  [switch]$InstallService,
  [switch]$Quick
)

$ErrorActionPreference = 'Stop'

function Resolve-CloudflaredPath {
  $candidates = @(
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Cloudflare.cloudflared_Microsoft.Winget.Source_8wekyb3d8bbwe\cloudflared.exe",
    'cloudflared'
  )

  foreach ($candidate in $candidates) {
    if ($candidate -eq 'cloudflared') {
      $cmd = Get-Command cloudflared -ErrorAction SilentlyContinue
      if ($cmd) { return $cmd.Source }
      continue
    }
    if (Test-Path $candidate) { return $candidate }
  }

  throw 'cloudflared no encontrado. Instalar con: winget install --id Cloudflare.cloudflared -e'
}

$cloudflared = Resolve-CloudflaredPath
Write-Host "[cloudflared] Using: $cloudflared"

if ($Quick) {
  Write-Host '[cloudflared] Starting quick tunnel (temporary URL)...'
  & $cloudflared tunnel --url http://localhost:8080
  exit $LASTEXITCODE
}

if ([string]::IsNullOrWhiteSpace($Hostname)) {
  throw 'Debes indicar -Hostname argos.<tu-dominio> para named tunnel.'
}

Write-Host '[cloudflared] Login (browser flow)...'
& $cloudflared tunnel login

Write-Host "[cloudflared] Create tunnel: $TunnelName"
& $cloudflared tunnel create $TunnelName

Write-Host "[cloudflared] Route DNS: $Hostname"
& $cloudflared tunnel route dns $TunnelName $Hostname

if ($InstallService) {
  Write-Host '[cloudflared] Installing Windows service...'
  & $cloudflared service install
}

Write-Host ''
Write-Host 'Next run command:'
Write-Host "  $cloudflared tunnel --config `"$ConfigPath`" run $TunnelName"