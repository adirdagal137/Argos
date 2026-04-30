# ARGOS STARTUP SCRIPT v2
# Lanza: API (pm2) + Gemini Drive Bridge (pm2) + ngrok tunnel

$ErrorActionPreference = 'SilentlyContinue'

$ARGOS_ROOT   = "C:\Users\Widox\Desktop\ARGOS"
$API_DIR      = "$ARGOS_ROOT\argos-api"
$RUNTIME_DIR  = "$ARGOS_ROOT\ARGOS_RUNTIME"

$STDOUT_LOG        = "$API_DIR\api.stdout.log"
$STDERR_LOG        = "$API_DIR\api.stderr.log"

$BRIDGE_SCRIPT     = "$RUNTIME_DIR\tools\gemini_drive_bridge.js"
$BRIDGE_LOG_DIR    = "$RUNTIME_DIR\logs"
$BRIDGE_STDOUT_LOG = "$BRIDGE_LOG_DIR\gemini_bridge.stdout.log"
$BRIDGE_STDERR_LOG = "$BRIDGE_LOG_DIR\gemini_bridge.stderr.log"

$NGROK_URL    = "aids-prevail-unguarded.ngrok-free.app"
$NGROK_PORT   = 8080

Write-Host "== INICIANDO SISTEMAS DEL NAVIO ARGOS ==" -ForegroundColor Cyan

# --------------------------------------------------------------------------
# 1. Limpiar puerto 8080
# --------------------------------------------------------------------------
$oldProcess = Get-NetTCPConnection -LocalPort $NGROK_PORT -ErrorAction SilentlyContinue |
              Select-Object -ExpandProperty OwningProcess -Unique
if ($oldProcess) {
    Write-Host "[1/5] Liberando puerto $NGROK_PORT (PID $oldProcess)..."
    Stop-Process -Id $oldProcess -Force
    Start-Sleep -Seconds 2
} else {
    Write-Host "[1/5] Puerto $NGROK_PORT despejado."
}

# --------------------------------------------------------------------------
# 2. Verificar build
# --------------------------------------------------------------------------
if (-not (Test-Path "$API_DIR\dist\index.js")) {
    Write-Host "[!] Error: No se encuentra el build en $API_DIR\dist\index.js" -ForegroundColor Red
    exit 1
}

# --------------------------------------------------------------------------
# 3. Verificar pm2
# --------------------------------------------------------------------------
$pm2 = Get-Command "pm2" -ErrorAction SilentlyContinue
if (-not $pm2) {
    Write-Host "[!] Error: pm2 no esta disponible en PATH." -ForegroundColor Red
    exit 1
}

# --------------------------------------------------------------------------
# 4. Lanzar API bajo PM2
# --------------------------------------------------------------------------
Write-Host "[2/5] Elevando anclas de la API..."
Set-Location $API_DIR

& $pm2.Source delete "argos-api" 2>$null | Out-Null
& $pm2.Source start "dist/index.js" --name "argos-api" --output $STDOUT_LOG --error $STDERR_LOG --time
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Error: pm2 no pudo lanzar argos-api." -ForegroundColor Red
    exit 1
}
Write-Host "[2/5] API lanzada bajo pm2." -ForegroundColor Green

# --------------------------------------------------------------------------
# 5. Lanzar Gemini Drive Bridge bajo PM2
# --------------------------------------------------------------------------
if (Test-Path $BRIDGE_SCRIPT) {
    New-Item -ItemType Directory -Force -Path $BRIDGE_LOG_DIR | Out-Null
    & $pm2.Source delete "gemini-append-bridge" 2>$null | Out-Null
    & $pm2.Source delete "gemini-drive-bridge"  2>$null | Out-Null
    & $pm2.Source start $BRIDGE_SCRIPT --name "gemini-drive-bridge" --output $BRIDGE_STDOUT_LOG --error $BRIDGE_STDERR_LOG --time
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[3/5] AVISO: pm2 no pudo lanzar gemini-drive-bridge." -ForegroundColor Yellow
    } else {
        Write-Host "[3/5] Gemini Drive Bridge activo." -ForegroundColor Green
    }
} else {
    Write-Host "[3/5] AVISO: no se encontro gemini_drive_bridge.js en $BRIDGE_SCRIPT" -ForegroundColor Yellow
}

# --------------------------------------------------------------------------
# 6. Esperar que la API responda antes de abrir tunnel
# --------------------------------------------------------------------------
Write-Host "[4/5] Esperando que la API levante..."
$apiReady = $false
for ($i = 0; $i -lt 10; $i++) {
    Start-Sleep -Seconds 2
    try {
        $health = Invoke-RestMethod -Uri "http://localhost:$NGROK_PORT/api/health" -Method Get -ErrorAction Stop
        if ($health.status -eq "ok") {
            Write-Host "    API OK: $($health.message)" -ForegroundColor Green
            $apiReady = $true
            break
        }
    } catch {}
    Write-Host "    ...intento $($i+1)/10"
}

if (-not $apiReady) {
    Write-Host "[!] AVISO: La API no respondio a tiempo. Revisa los logs:" -ForegroundColor Yellow
    Write-Host "    $STDERR_LOG"
}

# --------------------------------------------------------------------------
# 7. Lanzar ngrok tunnel
# --------------------------------------------------------------------------
$ngrok = Get-Command "ngrok" -ErrorAction SilentlyContinue
if (-not $ngrok) {
    Write-Host "[!] Error: ngrok no encontrado en PATH. Descargalo de https://ngrok.com/download" -ForegroundColor Red
    Write-Host "    Tunnel NO activo. Lanzalo manualmente:"
    Write-Host "    ngrok http $NGROK_PORT --url $NGROK_URL"
    Write-Host "== NAVEGACION PARCIAL (sin tunnel remoto) ==" -ForegroundColor Yellow
    exit 0
}

Write-Host "[5/5] Abriendo tunnel ngrok -> $NGROK_URL ..."
# Lanzar ngrok en ventana separada para que no bloquee este proceso
Start-Process -FilePath $ngrok.Source `
              -ArgumentList "http $NGROK_PORT --url $NGROK_URL" `
              -WindowStyle Normal

Start-Sleep -Seconds 4

# Verificar tunnel via API local de ngrok
try {
    $tunnels = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -ErrorAction Stop
    $publicUrl = $tunnels.tunnels[0].public_url
    Write-Host "    Tunnel activo: $publicUrl" -ForegroundColor Green
} catch {
    Write-Host "    AVISO: No se pudo verificar el tunnel via localhost:4040." -ForegroundColor Yellow
    Write-Host "    Si ngrok arranco correctamente, el tunnel deberia estar en $NGROK_URL"
}

Write-Host ""
Write-Host "== NAVEGACION ACTIVA ==" -ForegroundColor Green
Write-Host "   API local:  http://localhost:$NGROK_PORT"
Write-Host "   Tunnel:     https://$NGROK_URL"
Write-Host "   PM2 status: pm2 list"
Write-Host "   API logs:   pm2 logs argos-api"