# ARGOS QUICKSTART
Protocolo operativo condensado para sesion diaria.

## Inicio (cada sesion)
1. Leer `work_packets/inbox/`.
2. Leer tail de `ARGOS_GLOBAL_LOG.md`.
3. Leer `state/argos.state.json`.
4. Leer `inbox_deposits/` y `inbox_deposits/processed/` (actividad de agentes chat).
5. Confirmar al Capitan: `"[N] paquetes en inbox. [observacion propia en tu voz.]"`.

## Al tomar una tarea (MOMENTO 2 — START)

```http
POST http://localhost:8080/api/ia/start-task
{
  "packetId": "ARG-XXXX",
  "actor": "Claude|Codex|Pi|ChatGPT|DeepSeek|Qwen",
  "summary": "Frase concreta de lo que harás (~80 chars)"
}
```

El servidor emite automáticamente al feed: `"[Actor] tomando misión: [summary]"`.
**No enviar nada más al feed durante la ejecución. Los hitos van al log, no al feed.**

Fallback si API caída: deposit en `inbox_deposits/` con `[STATE] status: working`.

## Cierre (MOMENTO 3 — CLOSE, obligatorio)

Endpoint único para todos los agentes:

```http
POST http://localhost:8080/api/remote/closure
Headers: X-Argos-Agent-Token: <token-agente>
{
  "agent": "Claude|Codex|Pi|ChatGPT|DeepSeek|Qwen",
  "interface": "claude-code|codex|pi.ai|chatgpt.com|...",
  "timestamp": "2026-04-24T15:00:00.000Z",
  "packet_id": "ARG-XXXX",
  "trigger": "task_completed|session_close|handoff",
  "sections": {
    "log":    "Qué se hizo y resultado concreto — OBLIGATORIO, no puede estar vacío",
    "shadow": "Reflexión interna: tensiones, riesgos percibidos — OBLIGATORIO",
    "glitch": "",
    "state": {
      "status":     "idle",
      "summary":    "Estado tras el cierre",
      "handoff_to": "Codex|Claude|Pi|null",
      "next_step":  "Qué sigue"
    },
    "captain": "Mensaje al Capitán en voz propia del agente — OBLIGATORIO"
  },
  "mark_packet_done": false
}
```

El servidor escribe log+shadow+glitch en los canónicos, actualiza ia_status a idle,
y emite sections.captain al feed. **Un solo mensaje al feed: el caption.**

Fallback si API falla (timeout/5xx/sin red):
```
ARGOS_RUNTIME/inbox_deposits/<agente>_<YYYY-MM-DD_HH-MM>.md
```
con secciones `[LOG] [SHADOW] [GLITCH] [STATE] [CAPTAIN]`.
El `packet_id` y el actor canónico son OBLIGATORIOS en el deposit o irá a ORPHAN.

**Transcript (opcional — recomendado para Claude Code y Codex):**
Solo si hay razonamiento que no cabe en sections.log:
```http
POST http://localhost:8080/api/transcript
Headers: X-Argos-Agent-Token: <token-agente>
{
  "agent": "Claude|Codex|Pi|ChatGPT|DeepSeek",
  "role": "agent",
  "content": "Razonamiento que NO está en sections.log",
  "packetId": "ARG-XXXX"
}
```
No duplicar lo que ya está en sections.log ni en el feed.

**Agentes sin acceso HTTP directo (ChatGPT, Pi):**
Dictar este JSON al Capitán o a OpenClaw para que haga el POST:
```json
{
  "agent": "ChatGPT",
  "role": "agent",
  "content": "<razonamiento interno o decisiones no obvias>",
  "packetId": "ARG-XXXX"
}
```

**Lectura de transcripts (cualquier agente, sin token):**
```http
GET http://localhost:8080/api/transcript/ARG-XXXX
```
Devuelve todas las entradas de todos los agentes para ese packet, ordenadas cronológicamente.

**Agentes locales (Claude Code, Codex CLI):** también pueden usar `POST /api/trilog` como alternativa equivalente a `/api/remote/closure`.

## Rollover de sesion (inicio/fin de jornada)
Evita que global/shadow/glitch/transcripts crezcan indefinidamente en contexto vivo.

```http
POST http://localhost:8080/api/session/archive
{
  "mode": "start_of_day",
  "actor": "NOMBRE",
  "reason": "inicio de jornada",
  "archiveDonePackets": true,
  "compactState": true,
  "reorganizeLegacy": true
}
```

```http
POST http://localhost:8080/api/session/archive
{
  "mode": "end_of_day",
  "actor": "NOMBRE",
  "reason": "cierre de jornada",
  "archiveDonePackets": true,
  "compactState": true,
  "reorganizeLegacy": true
}
```

Atajo PowerShell:
```powershell
tools/session_rollover.ps1 -Mode start_of_day
tools/session_rollover.ps1 -Mode end_of_day
```

## Tokens (captura automática)

Los tokens reales se capturan solos — no hace falta estimarlos.

**Agentes cloud** (Claude, Antigravity, Codex): el proxy de argos-api intercepta cada llamada y lee el campo `usage` de la respuesta. Requiere que el entorno de cada IA tenga configuradas estas variables antes de arrancar:
```
ANTHROPIC_BASE_URL=http://localhost:8080/proxy/anthropic   # Claude Code
GOOGLE_AI_BASE_URL=http://localhost:8080/proxy/gemini       # Antigravity
OPENAI_BASE_URL=http://localhost:8080/proxy/openai          # Codex
```

**Qwen/DeepSeek (Ollama)**: `callOllama()` devuelve `prompt_eval_count` + `eval_count` reales. Se registran automáticamente en el ledger como agente `DeepSeek`.

**`processTokens` en el trilog**: sigue siendo un campo válido pero es ahora un fallback manual (proxy offline, sesión sin env var). Si el proxy está activo, el valor se ignora en el panel — los reales ya están en el ledger.

**Sync horario**: cada hora argos-api publica `tokens:hourly-sync` con los totales por agente. No hay coste asociado — es solo lectura del ledger.

**Reinicio de argos-api**: el proceso resiste `taskkill` desde bash. Usar:
```powershell
powershell -Command "Stop-Process -Id <PID> -Force"
```
**Ruta canónica de argos-api** (desde 2026-04-22):
```
C:\Users\Widox\Desktop\ARGOS\argos-api\
```
Arranque: `cd C:\Users\Widox\Desktop\ARGOS\argos-api && node dist/index.js`

## Protocolo de commits y ramas (OBLIGATORIO para cambios de codigo)

**Por que:** varios agentes pueden tocar `argos-api/src/index.ts` en paralelo.
Sin commits frecuentes, una escritura posterior borra el trabajo anterior silenciosamente.

### Regla general
Cada agente ejecuta `argos_commit.ps1` al **cerrar sesion** si modifico archivos constitutivos.
Claude Code lo hace **automaticamente** via hook Stop. Codex y Antigravity deben llamarlo en su ritual de cierre.

```powershell
# Cierre de sesion — commit basico
.\ARGOS_RUNTIME\tools\argos_commit.ps1 -Agent Codex -PacketId ARG-XXXX

# Inicio de tarea de mejora del sistema — crear rama
.\ARGOS_RUNTIME\tools\argos_commit.ps1 -Agent Codex -PacketId ARG-XXXX -Branch
```

### Cuando crear rama vs commitear en main

| Situacion | Accion |
|-----------|--------|
| Fix rapido, < 50 lineas, bajo riesgo | Commit directo en `main` |
| Packet TYPE: build o maintenance que toca `index.ts` | **Rama obligatoria** |
| Refactor grande o cambio de arquitectura | **Rama obligatoria** |
| Docs, scripts PS1, work packets | Commit directo en `main` |

### Nombre de rama
Formato automatico: `<agente>/<packet-id>` (ej. `codex/arg-1776816000001`).
Se puede forzar con `-BranchName <nombre>`.

### Merge a main
Una vez verificado el trabajo en la rama:
```powershell
git checkout main
git merge <rama> --no-ff -m "[<Agente>] merge <packet-id>: <descripcion>"
```

### Archivos constitutivos (los que se commitean)
- `argos-api/src/` — codigo fuente del servidor
- `argos-api/dist/index.js` — build compilado
- `argos-dashboard/` — frontend
- `ARGOS_RUNTIME/ARGOS_QUICKSTART.md`, `INTER_AI_PROTOCOL.md`, `ARGOS_VECTOR.md`
- `ARGOS_RUNTIME/agents/` — instrucciones de agentes
- `ARGOS_RUNTIME/tools/` — scripts del navio
- `ARGOS_RUNTIME/work_packets/inbox/` — packets activos

**NO se commitean:** `state/`, `events/`, `secrets/`, `views/`, `transcripts/` (en .gitignore).

## Reglas rapidas
- UTF-8 sin BOM en todo runtime.
- No usar `Set-Content -Encoding UTF8` en PowerShell 5.
- No duplicar en transcript lo ya presente en trilog/feed.
- No cerrar tareas sin `shadow`.
