# ARGOS STARTUP SCRIPT
# Recreado por Antigravity tras perdida de archivo original.

$ErrorActionPreference = 'SilentlyContinue'

$ARGOS_ROOT = "C:\Users\Widox\Desktop\ARGOS"
$API_DIR = "$ARGOS_ROOT\argos-api"
$STDOUT_LOG = "$API_DIR\api.stdout.log"
$STDERR_LOG = "$API_DIR\api.stderr.log"
$BRIDGE_SCRIPT = "$ARGOS_ROOT\ARGOS_RUNTIME\tools\gemini_drive_bridge.js"
$BRIDGE_LOG_DIR = "$ARGOS_ROOT\ARGOS_RUNTIME\logs"
$BRIDGE_STDOUT_LOG = "$BRIDGE_LOG_DIR\gemini_bridge.stdout.log"
$BRIDGE_STDERR_LOG = "$BRIDGE_LOG_DIR\gemini_bridge.stderr.log"

Write-Host "== INICIANDO SISTEMAS DEL NAVIO ARGOS ==" -ForegroundColor Cyan

# 1. Limpieza de procesos previos en puerto 8080
$oldProcess = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess -Unique
if ($oldProcess) {
    Write-Host "[1/4] Liberando puerto 8080 (PID $oldProcess)..."
    Stop-Process -Id $oldProcess -Force
    Start-Sleep -Seconds 2
} else {
    Write-Host "[1/4] Puerto 8080 despejado."
}

# 2. Verificar existencia de build
if (-not (Test-Path "$API_DIR\dist\index.js")) {
    Write-Host "[!] Error: No se encuentra el build en $API_DIR\dist\index.js" -ForegroundColor Red
    exit 1
}

# 3. Lanzar API bajo PM2
Write-Host "[2/4] Elevando anclas de la API..."
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

Write-Host "[3/4] API lanzada bajo pm2 con auto-restart." -ForegroundColor Green
Write-Host "Logs disponibles en: $STDOUT_LOG"

# 4. Lanzar Gemini Drive Bridge bajo PM2
if (Test-Path $BRIDGE_SCRIPT) {
    New-Item -ItemType Directory -Force -Path $BRIDGE_LOG_DIR | Out-Null
    & $pm2.Source delete "gemini-append-bridge" | Out-Null
    & $pm2.Source delete "gemini-drive-bridge" | Out-Null
    & $pm2.Source start $BRIDGE_SCRIPT --name "gemini-drive-bridge" --output $BRIDGE_STDOUT_LOG --error $BRIDGE_STDERR_LOG --time
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[!] AVISO: pm2 no pudo lanzar gemini-drive-bridge." -ForegroundColor Yellow
    } else {
        Write-Host "[4/4] Gemini Drive Bridge activo." -ForegroundColor Green
        Write-Host "Logs del bridge: $BRIDGE_STDOUT_LOG"
    }
} else {
    Write-Host "[4/4] AVISO: no se encontro gemini_drive_bridge.js." -ForegroundColor Yellow
}

Start-Sleep -Seconds 3

# Verificar salud
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -Method Get
    Write-Host ">> ESTADO: $($health.status) - $($health.message)" -ForegroundColor Cyan
} catch {
    Write-Host ">> AVISO: La API esta tardando en responder, revise los logs." -ForegroundColor Yellow
}

Write-Host "== NAVEGACION ACTIVA ==" -ForegroundColor Green
