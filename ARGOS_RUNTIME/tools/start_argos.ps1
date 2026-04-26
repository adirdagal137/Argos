# ARGOS STARTUP SCRIPT
# Recreado por Antigravity tras perdida de archivo original.

$ErrorActionPreference = 'SilentlyContinue'

$ARGOS_ROOT = "C:\Users\Widox\Desktop\ARGOS"
$API_DIR = "$ARGOS_ROOT\argos-api"
$STDOUT_LOG = "$API_DIR\api.stdout.log"
$STDERR_LOG = "$API_DIR\api.stderr.log"
$NGROK_URL = "https://aids-prevail-unguarded.ngrok-free.dev"
$NGROK_STDOUT_LOG = "$API_DIR\ngrok.stdout.log"
$NGROK_STDERR_LOG = "$API_DIR\ngrok.stderr.log"

function Get-ArgosNgrokTunnel {
    param([string]$ExpectedUrl)

    try {
        $tunnels = Invoke-RestMethod -Uri "http://127.0.0.1:4040/api/tunnels" -Method Get -TimeoutSec 2
        return $tunnels.tunnels |
            Where-Object { $_.public_url -eq $ExpectedUrl -and $_.config.addr -match "8080" } |
            Select-Object -First 1
    } catch {
        return $null
    }
}

function Stop-ExistingNgrok {
    $ngrokProcesses = Get-Process "ngrok" -ErrorAction SilentlyContinue
    if ($ngrokProcesses) {
        $ngrokPids = ($ngrokProcesses | Select-Object -ExpandProperty Id) -join ", "
        Write-Host ">> NGROK: cerrando instancia previa (PID $ngrokPids)..."
        $ngrokProcesses | Stop-Process -Force
        Start-Sleep -Seconds 2
    }
}

function Start-ArgosNgrok {
    param(
        [string]$NgrokCommand,
        [string]$ExpectedUrl
    )

    if (Test-Path $NGROK_STDOUT_LOG) { Remove-Item -LiteralPath $NGROK_STDOUT_LOG -Force }
    if (Test-Path $NGROK_STDERR_LOG) { Remove-Item -LiteralPath $NGROK_STDERR_LOG -Force }

    $args = @("http", "8080", "--url", $ExpectedUrl)
    Write-Host ">> NGROK: lanzando $NgrokCommand $($args -join ' ')"

    try {
        $process = Start-Process -FilePath $NgrokCommand `
            -ArgumentList $args `
            -RedirectStandardOutput $NGROK_STDOUT_LOG `
            -RedirectStandardError $NGROK_STDERR_LOG `
            -WindowStyle Hidden `
            -PassThru `
            -ErrorAction Stop
    } catch {
        Write-Host ">> NGROK: Start-Process fallo con redireccion; reintentando sin redireccion..." -ForegroundColor Yellow
        $process = Start-Process -FilePath $NgrokCommand `
            -ArgumentList $args `
            -WindowStyle Hidden `
            -PassThru `
            -ErrorAction Stop
    }

    Start-Sleep -Seconds 5
    if ($process.HasExited) {
        Write-Host ">> NGROK: el proceso salio inmediatamente con codigo $($process.ExitCode)." -ForegroundColor Yellow
        if (Test-Path $NGROK_STDERR_LOG) { Get-Content -LiteralPath $NGROK_STDERR_LOG -Tail 20 }
        return $null
    }

    return Get-ArgosNgrokTunnel -ExpectedUrl $ExpectedUrl
}

Write-Host "== INICIANDO SISTEMAS DEL NAVIO ARGOS ==" -ForegroundColor Cyan

# 1. Limpieza de procesos previos en puerto 8080
$oldProcess = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue |
    Where-Object { $_.OwningProcess -gt 0 } |
    Select-Object -ExpandProperty OwningProcess -Unique
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

# 3. Lanzar API en segundo plano
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

Start-Sleep -Seconds 3

# Verificar salud
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -Method Get
    Write-Host ">> ESTADO: $($health.status) - $($health.message)" -ForegroundColor Cyan
} catch {
    Write-Host ">> AVISO: La API esta tardando en responder, revise los logs." -ForegroundColor Yellow
}

# 4. Lanzar ngrok si no existe ya el tunel canonico
Write-Host "[4/4] Verificando tunel ngrok..."
$ngrok = Get-Command "ngrok" -ErrorAction SilentlyContinue
if (-not $ngrok) {
    Write-Host ">> AVISO: ngrok no esta disponible en PATH. Tunel remoto no iniciado." -ForegroundColor Yellow
} else {
    $activeTunnel = Get-ArgosNgrokTunnel -ExpectedUrl $NGROK_URL

    if ($activeTunnel) {
        Write-Host ">> NGROK: tunel ya activo en $NGROK_URL" -ForegroundColor Cyan
    } else {
        Stop-ExistingNgrok
        $activeTunnel = Start-ArgosNgrok -NgrokCommand $ngrok.Source -ExpectedUrl $NGROK_URL
        if (-not $activeTunnel) {
            Write-Host ">> NGROK: segundo intento usando resolucion por PATH..." -ForegroundColor Yellow
            Stop-ExistingNgrok
            $activeTunnel = Start-ArgosNgrok -NgrokCommand "ngrok" -ExpectedUrl $NGROK_URL
        }

        if ($activeTunnel) {
            Write-Host ">> NGROK: tunel activo en $NGROK_URL" -ForegroundColor Cyan
        } else {
            Write-Host ">> ERROR: ngrok no pudo levantar el tunel esperado. Revise $NGROK_STDERR_LOG" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host "== NAVEGACION ACTIVA ==" -ForegroundColor Green
