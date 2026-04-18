[WORK_PACKET]
ID: ARG-CLOUDFLARE-TUNNEL-001
TYPE: task
TAG: infra, cloudflare, tunnel, remote
SUBJECT: Activar tunnel Cloudflare para exponer /api/remote/* al exterior
ROLE_REQUESTED: Antigravity
OWNER: Antigravity
STATUS: open
PRIORITY: P2
REPORTED_BY: Claude (claude.ai)
REPORTED_AT: 2026-04-18 21:00 Atlantic/Canary
DEPENDS_ON: —

## Contexto

Codex implementó POST /api/remote/closure con auth por token, idempotencia y mark_packet_done.
El endpoint está operativo localmente (confirmado: /api/health → remote_closure.enabled=true).

El toolkit de Cloudflare también fue creado por Codex y está en ARGOS_RUNTIME/tools/:
- setup_cloudflared_tunnel.ps1
- cloudflared_config.example.yml  (expone /api/remote/.* y /api/health)
- start_cloudflared_hidden.vbs

cloudflared NO está corriendo. El túnel nunca se ha activado.

## Objetivo

Levantar el túnel Cloudflare de modo que /api/remote/closure sea accesible
desde agentes cloud (Claude chat, ChatGPT, Gemini) sin VPN.

## Tareas

1. Verificar que cloudflared está instalado en la máquina:
   - Ruta esperada: %LOCALAPPDATA%\Microsoft\WinGet\Packages\Cloudflare.cloudflared_*\cloudflared.exe
   - Si no está: winget install --id Cloudflare.cloudflared -e

2. Opción A — Túnel temporal (URL aleatoria, sin DNS, para prueba rápida):
   ```powershell
   tools/setup_cloudflared_tunnel.ps1 -Quick
   ```
   Anota la URL trycloudflare.com que aparece y reporta al Capitán.

3. Opción B — Túnel permanente (si el Capitán dispone de dominio):
   ```powershell
   tools/setup_cloudflared_tunnel.ps1 -Hostname argos.<dominio> -InstallService
   ```
   Requiere: login en Cloudflare, DNS delegado.

4. Smoke test tras activar:
   ```bash
   curl https://<url-tunnel>/api/health
   # Esperado: {"status":"ok","remote_closure":{"enabled":true,...}}

   curl -X POST https://<url-tunnel>/api/remote/closure \
     -H "X-Argos-Agent-Token: <token>" \
     -H "Content-Type: application/json" \
     -d '{"agent":"Claude","interface":"claude.ai","timestamp":"2026-04-18T21:00:00.000Z","packet_id":"ARG-CLOUDFLARE-TUNNEL-001","trigger":"task_completed","sections":{"log":"smoke test","shadow":"ok","glitch":"","state":{"status":"idle","summary":"tunnel activo","handoff_to":null,"next_step":""},"captain":"Túnel verificado"},"mark_packet_done":false}'
   ```

5. Reportar al Capitán: URL pública del túnel + resultado del smoke test.

## Entregable

- Túnel activo y accesible desde el exterior.
- URL pública documentada (depositarla en ARGOS_RUNTIME/state/ o similar).
- Smoke test exitoso contra /api/health y /api/remote/closure.

[/WORK_PACKET]
