# ARGOS STARTUP SCRIPT
# Recreado por Antigravity tras perdida de archivo original.

$ErrorActionPreference = 'SilentlyContinue'

$ARGOS_ROOT = "C:\Users\Widox\Desktop\ARGOS"
$API_DIR = "$ARGOS_ROOT\argos-api"
$STDOUT_LOG = "$API_DIR\api.stdout.log"
$STDERR_LOG = "$API_DIR\api.stderr.log"

Write-Host "== INICIANDO SISTEMAS DEL NAVIO ARGOS ==" -ForegroundColor Cyan

# 1. Limpieza de procesos previos en puerto 8080
$oldProcess = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
if ($oldProcess) {
    Write-Host "[1/3] Liberando puerto 8080 (PID $oldProcess)..."
    Stop-Process -Id $oldProcess -Force
    Start-Sleep -Seconds 2
} else {
    Write-Host "[1/3] Puerto 8080 despejado."
}

# 2. Verificar existencia de build
if (-not (Test-Path "$API_DIR\dist\index.js")) {
    Write-Host "[!] Error: No se encuentra el build en $API_DIR\dist\index.js" -ForegroundColor Red
    exit 1
}

# 3. Lanzar API bajo PM2
Write-Host "[2/3] Elevando anclas de la API..."
Set-Location $API_DIR

# Ejecutar bajo PM2 para auto-restart y redirigir logs canonicos
$pm2 = Get-Command "pm2" -ErrorAction SilentlyContinue
if (-not $pm2) {
    Write-Host "[!] Error: pm2 no esta disponible en PATH. Instale pm2 o revise el entorno Node." -ForegroundColor Red
    exit 1
}

& $pm2.Source delete "argos-api" | Out-Null
& $pm2.Source start "dist/index.js" --name "argos-api" --output $STDOUT_LOG --error $STDERR_LOG --time
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error: pm2 no pudo lanzar argos-api." -ForegroundColor Red
    exit 1
}

Write-Host "[3/3] API lanzada bajo pm2 con auto-restart." -ForegroundColor Green
Write-Host "Logs disponibles en: $STDOUT_LOG"

Start-Sleep -Seconds 3

# Verificar salud
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -Method Get
    Write-Host ">> ESTADO: $($health.status) - $($health.message)" -ForegroundColor Cyan
} catch {
    Write-Host ">> AVISO: La API esta tardando en responder, revise los logs." -ForegroundColor Yellow
}

Write-Host "== NAVEGACION ACTIVA ==" -ForegroundColor Green
